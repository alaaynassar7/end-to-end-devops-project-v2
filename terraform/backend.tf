terraform {
  backend "s3" {
    bucket       = "alaa-devops-project-tf-state-v2"
    key          = "eks-platform/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = false
  }
}