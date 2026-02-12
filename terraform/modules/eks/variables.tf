variable "project_name" {}
variable "cluster_version" {}
variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "instance_type" {}
variable "environment" {}
variable "principal_arn" {}
variable "tags" { 
  type    = map(string)
  default = {} 
}
variable "irsa_roles" { default = {} }