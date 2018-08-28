variable "aws_ip_assumeRole_name" {}
variable "aws_key_pair_auth_id" {}
variable "aws_number_pki_crl" {}
variable "aws_number_pki_ica" {}
variable "aws_number_pki_rca" {}
variable "aws_region" {}
variable "cidr" {}
variable "aws_amis" {
  type = "map"
}

variable "aws_subnet_id" {}

variable "azs" {
  type = "list"
}
