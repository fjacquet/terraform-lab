variable "aws_amis" {
  type = "map"
}

variable "azs" {
  type = "list"
}

variable "aws_sg_ids" {
  type = "list"
}

variable "aws_number" {}
variable "aws_region" {}
variable "aws_key_pair_auth_id" {}
variable "aws_iip_assumerole_name" {}
variable "aws_subnet_id" {}
variable "aws_vpc_id" {}
