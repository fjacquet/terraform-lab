variable "azs" {
  type = "list"
}

# variable "cidr" {
#   type = "map"
# }

variable "dhcpops" {}

variable "cidrbyte" {
  type = "map"
}

variable "aws_region" {}

variable "cidrbyte_back" {
  type = "list"
}

variable "cidrbyte_backup" {
  type = "list"
}

variable "cidrbyte_exchange" {
  type = "list"
}

variable "cidrbyte_mgmt" {
  type = "list"
}

variable "cidrbyte_sql" {
  type = "list"
}

variable "cidrbyte_web" {
  type = "list"
}

variable "cidrbyte_gw" {
  type = "list"
}
