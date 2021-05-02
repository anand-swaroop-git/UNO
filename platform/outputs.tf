##################################################################################
# OUTPUT
##################################################################################

output "Create_API_Endpoint" {
    description = "API gateway invoke URL"
    value = "${aws_api_gateway_deployment.UnoProxyDeployment.invoke_url}/create"
}
output "Read_API_Endpoint" {
    description = "API gateway invoke URL"
    value = "${aws_api_gateway_deployment.UnoProxyDeployment.invoke_url}/read"
}
output "Update_API_Endpoint" {
    description = "API gateway invoke URL"
    value = "${aws_api_gateway_deployment.UnoProxyDeployment.invoke_url}/update"
}
output "Authentication_Endpoint" {
    description = "API gateway invoke URL"
    value = "${aws_api_gateway_deployment.UnoAuthenticationAPIDeployment.invoke_url}/authentication"
}

