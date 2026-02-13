variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "alaa-devops-project"
}

variable "environment" {
  description = "Deployment environment (prod or nonprod)"
  type        = string
  default     = "nonprod"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_cidrs" {
  description = "Public Subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidrs" {
  description = "Private Subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS Cluster"
  type        = string
  default     = "1.30"
}

variable "instance_type" {
  description = "Instance type for the EKS worker nodes"
  type        = string
  default     = "t3.large"
}

variable "principal_arn" {
  description = "IAM User/Role ARN for EKS Admin access"
  type        = string
  default     = "arn:aws:iam::913524922392:root"
}

variable "nlb_listener_arn" {
  description = "ARN of the NLB Listener (passed dynamically)"
  type        = string
  default     = ""
}

variable "nlb_dns_name" {
  description = "DNS name of the NLB (passed dynamically)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common Tags"
  type        = map(string)
  default     = {
    Owner       = "Alaa-Nassar"
    Project     = "Graduation-Project-NTI"
    Environment = "nonprod"
  }
}

variable "irsa_roles" {
  description = "IRSA Roles Map"
  type        = any
  default     = {}
}
