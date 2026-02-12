terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "> 2.11"
    }
  }
 }
provider "aws" {
  region = "us-east-2"   
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}