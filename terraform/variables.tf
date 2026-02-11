variable "aws_region" {
  description = "The AWS Region to deploy the cluster into"
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Name prefix for resources"
  default     = "alaa-devops-project"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS Cluster"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EKS worker nodes"
  type        = string
}

variable "principal_arn" {
  description = "IAM Principal ARN to grant cluster access"
  type        = string
}

variable "environment" {
  description = "Deployment environment (prod or dev)"
  type        = string
  default     = "prod"
}

variable "nlb_dns_name" {
  description = "The DNS name of the Network Load Balancer created by Ingress Controller"
  type        = string
  default     = "http://example.com"
}

variable "nlb_listener_arn" {
  description = "The ARN of the Network Load Balancer Listener for VPC Link"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "irsa_roles" {
  description = "Map of IRSA roles to create"
  type = map(object({
    namespace            = string
    service_account_name = string
    policy_arns          = list(string)
  }))
  default = {}
}