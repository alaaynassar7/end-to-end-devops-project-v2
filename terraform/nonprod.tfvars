environment     = "nonprod"
project_name    = "alaa-devops-project"
vpc_cidr        = "10.0.0.0/16"
cluster_version = "1.30"
instance_type   = "t3.large"
principal_arn   = "arn:aws:iam::344809605543:root"

tags = {
  Owner       = "Alaa-Nassar"
  Project     = "Graduation-Project"
  Environment = "nonprod"
}