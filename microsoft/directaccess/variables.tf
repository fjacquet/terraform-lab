variable "aws_number" {}
variable "aws_ip_assumeRole_name" {}
variable "aws_key_pair_auth_id" {}
variable "aws_region" {}
variable "aws_sg_id" {
    type="list"
}
variable "aws_subnet_id" {}

variable "aws_amis" {
  type = "map"
}

variable "azs" {
  type = "list"
}
