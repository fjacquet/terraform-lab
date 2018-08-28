variable "access_key" {}
variable "aws_region" {}
variable "secret_key" {}
variable "azs" {
    type="list"
}
variable "cidr_vpc" {}

variable "cidr_back" {
  type = "list"
}

variable "cidr_exch" {
  type = "list"
}

variable "cidr_gw" {}
variable "cidr_mgmt" {}
variable "cidr_web" {
    type="list"
}
