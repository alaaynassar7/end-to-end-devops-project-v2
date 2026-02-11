variable "project_name" { type = string }
variable "environment" { type = string }
variable "cluster_version" { type = string }
variable "instance_type" { type = string }
variable "principal_arn" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "tags" { type = map(string) }
variable "irsa_roles" {
  type = map(object({
    namespace            = string
    service_account_name = string
    policy_arns          = list(string)
  }))
}