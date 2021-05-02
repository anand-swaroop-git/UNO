##################################################################################
# COGNITO
##################################################################################


resource "aws_cognito_user_pool" "uno-users-pool" {
  name = "uno-users-pool"
  lambda_config {
    pre_sign_up = aws_lambda_function.presignup_v1.arn
  }
  password_policy {
    require_symbols = false
    require_uppercase = false
    require_numbers = false
    minimum_length = 6
  }
  tags = {
      Name        = "${var.app_name}-user-pool"
      Environment = var.app_environment
  }
}

resource "aws_cognito_user_pool_client" "uno-app-client" {
  name = "uno-app-client"

  user_pool_id = aws_cognito_user_pool.uno-users-pool.id
  generate_secret = true

  explicit_auth_flows = [
      "ALLOW_ADMIN_USER_PASSWORD_AUTH",
      "ALLOW_CUSTOM_AUTH",
      "ALLOW_USER_SRP_AUTH",
      "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}