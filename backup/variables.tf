variable "azs" {
    type="list"
}
variable "aws_region" {}


variable "aws_win2016_amis" {
     type="map"
}

variable "aws_key_pair_auth_id" {}
variable "aws_sg_ssh_id" {}

variable "aws_sg_rdp_id" {}
variable "aws_ip_assumeRole_name" {}
variable "aws_subnet_mgmt_id" {}
