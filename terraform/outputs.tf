output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.compute.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.compute.cluster_endpoint
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.integration.api_gateway_url
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.integration.cognito_user_pool_id
}

output "cognito_client_id" {
  description = "Cognito App Client ID"
  value       = module.integration.cognito_client_id
}

output "cognito_client_secret" {
  description = "Cognito App Client Secret"
  value       = module.integration.cognito_client_secret
  sensitive   = true
}

output "cognito_issuer_url" {
  description = "Cognito Issuer URL"
  value       = module.integration.cognito_issuer_url
}

output "nlb_dns_name" {
  description = "The DNS name of the Network Load Balancer"
  value       = var.nlb_dns_name
}

output "cognito_login_url" {
  description = "Direct link to the Cognito Hosted UI Login page"
  value       = module.integration.cognito_login_url
}