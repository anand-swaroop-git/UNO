##################################################################################
# API GATEWAY
##################################################################################

# --------------------------------------------------------
# HTTP PROXY API
# --------------------------------------------------------

resource "aws_api_gateway_rest_api" "UnoAPI" {
  name        = "UnoAPI"
  description = "API for HTTP Proxy Integration with ALB"
}

resource "aws_api_gateway_resource" "ApiProxyResource" {
  rest_api_id = aws_api_gateway_rest_api.UnoAPI.id
  parent_id   = aws_api_gateway_rest_api.UnoAPI.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "ApiProxyMethod" {
  rest_api_id        = aws_api_gateway_rest_api.UnoAPI.id
  resource_id        = aws_api_gateway_resource.ApiProxyResource.id
  http_method        = "ANY"
  authorization      = "COGNITO_USER_POOLS"
  request_parameters = { "method.request.path.proxy" = true }
  authorizer_id      = aws_api_gateway_authorizer.UnoAPIAuthorizer.id
}


resource "aws_api_gateway_integration" "ApiProxyIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.UnoAPI.id
  resource_id             = aws_api_gateway_resource.ApiProxyResource.id
  http_method             = aws_api_gateway_method.ApiProxyMethod.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = format("%s/{proxy}", "http://${aws_lb.uno-application-lb.dns_name}")
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}


resource "aws_api_gateway_deployment" "UnoProxyDeployment" {
  depends_on = [aws_api_gateway_integration.ApiProxyIntegration]

  rest_api_id = aws_api_gateway_rest_api.UnoAPI.id
  stage_name  = "prod"


  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------------------------------
# AUTHENTICATION API
# --------------------------------------------------------

resource "aws_api_gateway_rest_api" "UnoAuthenticationAPI" {
  name        = "UnoAuthenticationAPI"
  description = "Authentication API"
}

resource "aws_api_gateway_resource" "UnoAuthAPIResource" {
  rest_api_id = aws_api_gateway_rest_api.UnoAuthenticationAPI.id
  parent_id   = aws_api_gateway_rest_api.UnoAuthenticationAPI.root_resource_id
  path_part   = "authentication"
}

resource "aws_api_gateway_method" "UnoAPIMethod" {
  rest_api_id   = aws_api_gateway_rest_api.UnoAuthenticationAPI.id
  resource_id   = aws_api_gateway_resource.UnoAuthAPIResource.id
  http_method   = "POST"
  authorization = "None"
}

resource "aws_api_gateway_integration" "UnoAPIIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.UnoAuthenticationAPI.id
  resource_id             = aws_api_gateway_resource.UnoAuthAPIResource.id
  http_method             = aws_api_gateway_method.UnoAPIMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:ap-southeast-2:lambda:path/2015-03-31/functions/${aws_lambda_function.uno-signin_v1.arn}/invocations"
  credentials             = aws_iam_role.uno-api-gateway-role.arn
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.UnoAuthenticationAPI.id
  resource_id = aws_api_gateway_resource.UnoAuthAPIResource.id
  http_method = aws_api_gateway_method.UnoAPIMethod.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}



resource "aws_api_gateway_authorizer" "UnoAPIAuthorizer" {
  name            = "UnoAPIAuthorizer"
  rest_api_id     = aws_api_gateway_rest_api.UnoAPI.id
  identity_source = "method.request.header.Authorization"
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [aws_cognito_user_pool.uno-users-pool.arn]
  authorizer_uri  = "arn:aws:apigateway:ap-southeast-2:lambda:path/2015-03-31/functions/${aws_lambda_function.uno-signin_v1.arn}/invocations"
}


resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presignup_v1.function_name
  # principal     = "apigateway.amazonaws.com"
  principal  = "cognito-idp.amazonaws.com"
  source_arn = aws_cognito_user_pool.uno-users-pool.arn
}
resource "aws_lambda_permission" "lambda_permission_presignup" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.uno-signin_v1.function_name
  # principal     = "apigateway.amazonaws.com"
  principal  = "cognito-idp.amazonaws.com"
  source_arn = aws_cognito_user_pool.uno-users-pool.arn
}

resource "aws_api_gateway_integration_response" "UnoAuthIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.UnoAuthenticationAPI.id
  resource_id = aws_api_gateway_resource.UnoAuthAPIResource.id
  http_method = aws_api_gateway_method.UnoAPIMethod.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  response_templates = {
    "application/json" = ""
  }
  depends_on = [ aws_api_gateway_integration.UnoAPIIntegration ]
}


# --------------------------------------------------------
# IAM POLICY AND ROLE
# --------------------------------------------------------

resource "aws_iam_role_policy" "uno-api-gateway-policy" {
  name = "uno-api-gateway-policy"
  role = aws_iam_role.uno-api-gateway-role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "*",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "uno-api-gateway-role" {
  name = "uno-api-gateway-role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "apigateway.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF

}


resource "aws_api_gateway_deployment" "UnoAuthenticationAPIDeployment" {
  depends_on = [aws_api_gateway_integration.UnoAPIIntegration]

  rest_api_id = aws_api_gateway_rest_api.UnoAuthenticationAPI.id
  stage_name  = "prod"


  lifecycle {
    create_before_destroy = true
  }
}
