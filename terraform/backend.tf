terraform {
  backend "s3" {
    bucket       = "final-project-alaa-bucket"
    key          = "eks-platform/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
  # use_lockfile = false
  }
}