# --- Cognito ---
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-user-pool-${var.environment}"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${var.project_name}-client"

  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = true

  callback_urls = ["${aws_apigatewayv2_api.main.api_endpoint}/oauth2/callback"]
  logout_urls   = ["${aws_apigatewayv2_api.main.api_endpoint}/"]

  supported_identity_providers = ["COGNITO"]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-${var.environment}-auth"
  user_pool_id = aws_cognito_user_pool.main.id
}

# --- API Gateway ---

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
  security_group_ids = [var.cluster_security_group_id]
  subnet_ids         = var.private_subnet_ids

  tags = {
    Project = var.project_name
  }
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "CognitoJWT"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.client.id]
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
  }
}

resource "aws_apigatewayv2_integration" "nlb_proxy" {
  count = var.nlb_listener_arn == "" ? 0 : 1

  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "HTTP_PROXY"

  integration_uri = var.nlb_listener_arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.main.id

  lifecycle {
    ignore_changes = [integration_uri]
  }
}

resource "aws_apigatewayv2_route" "default" {
  count = var.nlb_listener_arn == "" ? 0 : 1

  api_id    = aws_apigatewayv2_api.main.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.nlb_proxy[0].id}"

  authorization_type = "NONE"
}