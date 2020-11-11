##################################################################################
# API GATEWAY
##################################################################################

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
  authorization      = "NONE"
  request_parameters = { "method.request.path.proxy" = true }
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
