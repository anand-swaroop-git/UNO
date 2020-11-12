##################################################################################
# Terraform Backend
##################################################################################

// Commenting out remote backend to make it easier to test
// terraform {
//   backend "s3" {
//     bucket  = "tf-state-conf-2020-random-11-random"
//     key     = "terraform-platform-backend/terraform_state"
//     region  = "ap-southeast-2"
//     profile = "default"
//   }
// }
