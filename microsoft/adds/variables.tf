variable "aws_ip_assumeRole_name" {}
variable "aws_key_pair_auth_id" {}
variable "aws_number" {}
variable "aws_region" {}
variable "aws_sg_id" {}
variable "aws_subnet_id" {}
variable "aws_vpc_id" {}
variable "cidr" {}
variable "aws_amis" {
     type="map"
}
variable "azs" {
    type="list"
}
