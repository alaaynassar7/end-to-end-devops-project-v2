locals {
  instance_count = var.environment == "prod" ? 2 : 1
  oidc_issuer_url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# --- Security Group ---
resource "aws_security_group" "node" {
  name   = "${var.project_name}-node-sg"
  vpc_id = var.vpc_id
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = { Name = "${var.project_name}-node-sg", "kubernetes.io/cluster/${var.project_name}-cluster" = "owned" }
}

# --- IAM Roles ---
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "eks.amazonaws.com" } }]
  })
}
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role" "eks_nodes" {
  name = "${var.project_name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  ])
  policy_arn = each.value
  role       = aws_iam_role.eks_nodes.name
}

# --- Cluster ---
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version
  vpc_config {
    subnet_ids         = concat(var.public_subnets, var.private_subnets)
    security_group_ids = [aws_security_group.node.id]
    endpoint_public_access = true
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
  tags = { Project = var.project_name }
}

# --- Node Group ---
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "general"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.private_subnets
  scaling_config {
    desired_size = local.instance_count
    max_size     = local.instance_count + 1
    min_size     = 1
  }
  ami_type       = "AL2023_x86_64_STANDARD"
  instance_types = [var.instance_type]
  depends_on     = [aws_iam_role_policy_attachment.node_policies]
  tags = { Name = "${var.project_name}-node-group", Project = var.project_name }
}

# --- Access Entry (Admin) ---
resource "aws_eks_access_entry" "root" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.principal_arn
  type          = "STANDARD"
}
resource "aws_eks_access_policy_association" "root" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.root.principal_arn
  access_scope { type = "cluster" }
}

# --- OIDC & IRSA Logic (من ملف irsa.tf) ---
data "tls_certificate" "eks_oidc" { url = aws_eks_cluster.main.identity[0].oidc[0].issuer }
resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  tags            = var.tags
}

data "aws_iam_policy_document" "irsa_assume" {
  for_each = var.irsa_roles
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.service_account_name}"]
    }
  }
}

resource "aws_iam_role" "irsa" {
  for_each           = var.irsa_roles
  name               = "${aws_eks_cluster.main.name}-${each.key}-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume[each.key].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each = { for item in flatten([ for k, v in var.irsa_roles : [ for arn in v.policy_arns : { key = "${k}|${arn}", role_key = k, policy_arn = arn } ] ]) : item.key => item }
  role       = aws_iam_role.irsa[each.value.role_key].name
  policy_arn = each.value.policy_arn
}