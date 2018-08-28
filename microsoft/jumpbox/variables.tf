variable "aws_region" {}
variable "aws_subnet_id" {}
variable "aws_ip_assumeRole_name" {}

variable "aws_number" {}
variable "azs" {
    type="list"
}
variable "aws_amis" {
  type = "map"
}
variable "aws_key_pair_auth_id" {}

variable "aws_sg_id" {
  type="list"
}
