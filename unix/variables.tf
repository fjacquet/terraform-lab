variable "aws_iip_assumerole_name" {}
variable "aws_key_pair_auth_id" {}
variable "aws_region" {}

variable "aws_number" {
  type = "map"
}

variable "aws_sg_simpanaclient_id" {}

variable "aws_disks_size" {
  type = "map"
}

variable "aws_subnet_web_id" {
  type = "list"
}

variable "aws_subnet_back_id" {
  type = "list"
}

variable "aws_subnet_backup_id" {
  type = "list"
}

variable "aws_vpc_id" {}

variable "cidr" {
  type = "map"
}

variable "azs" {
  type = "list"
}

variable "aws_amis" {
  type = "map"
}
