variable "access_key" {}
variable "aws_region" {}

variable "azs" {
  type = "list"
}

variable "cidr_back" {
  type = "list"
}

variable "cidr_exch" {
  type = "list"
}

variable "cidr_gw" {}

variable "cidr_mgmt" {
  type = "list"
}

variable "cidr_vpc" {}

variable "cidr_web" {
  type = "list"
}

variable "secret_key" {}
