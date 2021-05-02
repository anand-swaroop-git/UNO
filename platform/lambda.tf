##################################################################################
# LAMBDA, IAM ROLE, IAM POLICY
##################################################################################


# --------------------------------------------------------
# Location Variables
# --------------------------------------------------------

locals {
  lambda_zip_location_presignup = "lambda/presignup.zip"
}

locals {
  lambda_zip_location_signin = "lambda/unosignin.zip"
}

# --------------------------------------------------------
# ZIPPING THE LAMBDA CODE
# --------------------------------------------------------

data "archive_file" "archive-file-presignup" {
  type        = "zip"
  source_file = "lambda/presignup.py"
  output_path = local.lambda_zip_location_presignup
}

data "archive_file" "archive-file-signin" {
  type        = "zip"
  source_file = "lambda/unosignin.py"
  output_path = local.lambda_zip_location_signin
}

# --------------------------------------------------------
# IAM POLICY AND ROLE
# --------------------------------------------------------

resource "aws_iam_role_policy" "uno-lambda-policy" {
  name = "uno-lambda-policy"
  role = aws_iam_role.uno-lambda-role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "logs:CreateLogGroup",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cognito-identity:*",
          "cognito-idp:*",
          "cognito-sync:*",
          "iam:ListRoles",
          "iam:ListOpenIdConnectProviders",
          "sns:ListPlatformApplications",
          "kms:*"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "uno-lambda-role" {
  name = "uno-lambda-role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF

}

# --------------------------------------------------------
# PRESIGNUP LAMBDA 
# --------------------------------------------------------

resource "aws_lambda_function" "presignup_v1" {
  filename      = local.lambda_zip_location_presignup
  function_name = "presignup_v1"
  role          = aws_iam_role.uno-lambda-role.arn
  handler       = "presignup.lambda_handler"
  runtime       = "python3.7"
}

# --------------------------------------------------------
# MAIN SIGIN LAMBDA
# --------------------------------------------------------

resource "aws_lambda_function" "uno-signin_v1" {
  filename      = local.lambda_zip_location_signin
  function_name = "uno-signin_v1"
  role          = aws_iam_role.uno-lambda-role.arn
  handler       = "unosignin.lambda_handler"
  runtime       = "python3.7"

  environment {
    variables = {
      USER_POOL_ID_UNO  = aws_cognito_user_pool.uno-users-pool.id
      CLIENT_ID_UNO     = aws_cognito_user_pool_client.uno-app-client.id
      CLIENT_SECRET_UNO = aws_cognito_user_pool_client.uno-app-client.client_secret
    }
  }
}
