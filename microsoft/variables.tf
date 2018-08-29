variable "aws_iip_assumerole_name" {}
variable "aws_key_pair_auth_id" {}
variable "aws_number_da" {}
variable "aws_number_dc" {}
variable "aws_number_dhcp" {}
variable "aws_number_exch" {}
variable "aws_number_ipam" {}
variable "aws_number_jumpbox" {}
variable "aws_number_pki_crl" {}
variable "aws_number_pki_ica" {}
variable "aws_number_pki_rca" {}
variable "aws_number_sharepoint" {}
variable "aws_number_simpana" {}
variable "aws_number_sql" {}
variable "aws_region" {}
variable "aws_sg_cvltclient_id" {}
variable "aws_sg_nbuclient_id" {}
variable "aws_sg_rdp_id" {}

variable "aws_subnet_back_id" {
  type = "list"
}

variable "aws_subnet_exch_id" {
  type = "list"
}

variable "aws_subnet_mgmt_id" {
  type = "list"
}

variable "aws_subnet_web_id" {
  type = "list"
}

variable "aws_vpc_id" {}

variable "cidr_back" {
  type = "list"
}

variable "cidr_exch" {
  type = "list"
}

variable "cidr_mgmt" {
  type = "list"
}

variable "cidr_web" {
  type = "list"
}

variable "aws_amis_jumpbox" {
  type = "map"
}

variable "aws_amis_sharepoint" {
  type = "map"
}

variable "aws_amis_sql" {
  type = "map"
}

variable "aws_amis_win2016" {
  type = "map"
}

variable "azs" {
  type = "list"
}
