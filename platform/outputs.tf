##################################################################################
# OUTPUT
##################################################################################

output "aws_alb_endpoint" {
    description = "The name of ALB"
    value = aws_lb.uno-application-lb.dns_name
}