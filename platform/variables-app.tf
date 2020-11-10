variable "app_name" {
    type = string
    description = "Application Name"
}

variable "app_environment" {
    type = string
    description = "Application Environment"
}

variable "admin_sources_cidr" {
  type = list(string)
  description = "List of IPv4 CIDR blocks from which to allow admin access"
}

variable "app_sources_cidr" {
  type = list(string)
  description = "List of IPv4 CIDR blocks from which to allow application access"
}


