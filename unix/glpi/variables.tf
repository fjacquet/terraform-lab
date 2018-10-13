variable "aws_ami" {}

variable "azs" {
  type = "list"
}

variable "aws_sg_ids" {
  type = "list"
}

variable "dns_suffix" {}
variable "aws_number" {}
variable "aws_key_pair_auth_id" {}
variable "aws_iip_assumerole_name" {}

variable "aws_subnet_id" {
  type = "list"
}

variable "aws_vpc_id" {}
variable "dns_zone_id" {}
