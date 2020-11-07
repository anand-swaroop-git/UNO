##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "ap-southeast-2"
}

##################################################################################
# RESOURCES
##################################################################################

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "unouserdb"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "userId"

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "userId"
    type = "S"
  }
  
#   attribute {
#     name = "lastName"
#     type = "S"
#   }

#   attribute {
#     name = "mobileNumber"
#     type = "S"
#   }
  
  tags = {
    Name        = "uno-table"
    Environment = "development"
  }
}