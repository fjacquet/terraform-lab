variable "aws_iip_assumerole_name" {}
variable "aws_key_pair_auth_id" {}
variable "aws_number_pki_crl" {}
variable "aws_number_pki_ica" {}
variable "aws_number_pki_rca" {}
variable "aws_number_pki_nde" {}

variable "aws_vpc_id" {}
variable "dns_zone_id" {}

variable "cidr" {
  type = "list"
}

variable "aws_sg_ids" {
  type = "list"
}

variable "aws_ami" {}

variable "aws_subnet_id" {
  type = "list"
}

variable "azs" {
  type = "list"
}

variable "dns_suffix" {}
