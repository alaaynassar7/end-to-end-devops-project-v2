variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "environment" {
  description = "Deployment environment (prod or dev)"
  type        = string
  default     = "nonprod"
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "ealaa-devops-final" 
}

variable "environment" { type = string }
variable "vpc_cidr" { type = string }
variable "public_cidrs" { type = list(string) }
variable "private_cidrs" { type = list(string) }
variable "azs" { type = list(string) }

variable "cluster_version" { type = string }
variable "instance_type" { type = string }

variable "principal_arn" {
  description = "IAM User/Role ARN for EKS Admin access"
  type        = string
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
  default     = {}
}