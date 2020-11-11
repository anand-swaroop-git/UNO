##################################################################################
# OUTPUT
##################################################################################

output "aws_alb_arn" {
    description = "The ARN of ALB"
    value = aws_lb.uno-application-lb.arn
}
output "aws_http_80_listener_arn" {
    description = "The ARN of HTTP 80 listener"
    value = aws_lb_listener.uno-application-lb-listener-unified.arn
}

output "aws_target_groups_arn_create" {
    description = "Target group ARNs"
    value = aws_lb_target_group.uno-application-lb-tg-create.arn
}
output "aws_target_groups_arn_read" {
    description = "Target group ARNs"
    value = aws_lb_target_group.uno-application-lb-tg-read.arn
}
output "aws_target_groups_arn_update" {
    description = "Target group ARNs"
    value = aws_lb_target_group.uno-application-lb-tg-update.arn
}
output "api_gateway_invoke_url" {
    description = "API gateway invoke URL"
    value = aws_api_gateway_deployment.UnoProxyDeployment.invoke_url
}

