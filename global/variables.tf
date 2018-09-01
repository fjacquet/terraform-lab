variable "access_key" {}
variable "aws_region" {}
variable "secret_key" {}
variable "public_key" {}

variable "key_name" {}

variable "azs" {
  type = "list"
}

variable "cidr" {
  type = "map"
}
