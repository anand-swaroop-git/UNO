##################################################################################
# OUTPUT
##################################################################################

output "api_gateway_invoke_url" {
    description = "API gateway invoke URL"
    value = aws_api_gateway_deployment.UnoProxyDeployment.invoke_url
}

