variable "project_name" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "cluster_security_group_id" { type = string }
variable "nlb_dns_name" { type = string }
variable "nlb_listener_arn" { type = string }