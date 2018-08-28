variable "aws_ip_assumeRole_name" {}
variable "aws_key_pair_auth_id" {}
variable "aws_region" {}
variable "aws_sg_id" {}
variable "aws_sg_sql_id" {}
variable "aws_number" {}
variable "aws_amis" {
     type="map"
}
variable "aws_subnet_id" {}

variable "azs" {
  type = "list"
}
