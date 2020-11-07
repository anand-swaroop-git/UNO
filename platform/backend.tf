##################################################################################
# Terraform Backend
##################################################################################

terraform {
  backend "s3" {
    bucket  = "uno-tf-state"
    key     = "terraform-platform-backend/terraform_state"
    region  = "ap-southeast-2"
    profile = "personal"
  }
}
