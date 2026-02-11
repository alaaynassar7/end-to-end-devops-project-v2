module "network" {
  source = "./modules/network"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "compute" {
  source = "./modules/compute"

  project_name      = var.project_name
  environment       = var.environment
  cluster_version   = var.cluster_version
  instance_type     = var.instance_type
  principal_arn     = var.principal_arn
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  irsa_roles        = var.irsa_roles
  tags              = var.tags
}

module "integration" {
  source = "./modules/integration"

  project_name               = var.project_name
  environment                = var.environment
  aws_region                 = var.aws_region
  vpc_id                     = module.network.vpc_id
  private_subnet_ids         = module.network.private_subnet_ids
  cluster_security_group_id  = module.compute.cluster_security_group_id
  nlb_dns_name               = var.nlb_dns_name
  nlb_listener_arn           = var.nlb_listener_arn
}