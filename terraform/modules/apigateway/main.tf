resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-api-v2-${var.environment}"
  protocol_type = "HTTP"
  description   = "HTTP API Gateway with JWT Auth"
tags = {
    Project     = var.project_name
    Environment = var.environment
  }
  }

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_vpc_link" "main" {
  name               = "${var.project_name}-vpc-link"
  security_group_ids = [var.cluster_security_group]
  subnet_ids         = var.private_subnets
  tags               = { Project = var.project_name }
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "CognitoJWT"
  jwt_configuration {
    audience = [var.cognito_client_id]
    issuer   = var.cognito_issuer_url
  }
}

resource "aws_apigatewayv2_integration" "nlb_proxy" {
  count            = var.nlb_listener_arn == "" ? 0 : 1
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "HTTP_PROXY"
  integration_uri  = var.nlb_listener_arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.main.id
  lifecycle { ignore_changes = [integration_uri] }
}

resource "aws_apigatewayv2_route" "default" {
  count     = var.nlb_listener_arn == "" ? 0 : 1
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /{proxy+}" 
  target    = "integrations/${aws_apigatewayv2_integration.nlb_proxy[0].id}"
  # authorization_type = "JWT"
  # authorizer_id      = aws_apigatewayv2_authorizer.jwt.id
}