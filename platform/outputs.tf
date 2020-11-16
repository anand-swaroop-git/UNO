##################################################################################
# OUTPUT
##################################################################################

output "Application_Endpoint" {
    description = "API gateway invoke URL"
    value = aws_api_gateway_deployment.UnoProxyDeployment.invoke_url
}
output "Authentication_Endpoint" {
    description = "API gateway invoke URL"
    value = aws_api_gateway_deployment.UnoAuthenticationAPIDeployment.invoke_url
}

