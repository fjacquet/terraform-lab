variable "aws_iip_assumerole_name" {}
variable "aws_key_pair_auth_id" {}
variable "aws_number_guacamole" {}
variable "aws_number_nbumaster" {}
variable "aws_number_oracle" {}
variable "aws_region" {}
variable "aws_sg_cvltclient_id" {}
variable "aws_sg_nbuclient_id" {}
variable "aws_sg_ssh_id" {}
variable "aws_size_nbu_backups" {}
variable "aws_size_nbu_openv" {}

variable "aws_subnet_web_id" {
  type = "list"
}

variable "aws_subnet_back_id" {
  type = "list"
}

variable "aws_vpc_id" {}

variable "cidr_back" {
  type = "list"
}

variable "cidr_mgmt" {
  type = "list"
}

variable "cidr_exch" {
  type = "list"
}

variable "cidr_web" {
  type = "list"
}

variable "azs" {
  type = "list"
}

variable "aws_amis_guacamole" {
  type = "map"
}

variable "aws_amis_oracle" {
  type = "map"
}

variable "aws_amis_nbu" {
  type = "map"
}
