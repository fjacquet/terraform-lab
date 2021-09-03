variable "aws_iip_assumerole_name" {
}

variable "aws_key_pair_auth_id" {
}

variable "aws_region" {
}

variable "dns_zone_id" {
}

variable "aws_number" {
  type = map(string)
}

variable "aws_sg_simpana_client_id" {
}

variable "aws_disks_size" {
  type = map(string)
}

variable "aws_subnet_web_id" {
  type = list(string)
}

variable "aws_subnet_back_id" {
  type = list(string)
}

variable "aws_subnet_backup_id" {
  type = list(string)
}

variable "aws_subnet_mgmt_id" {
  type = list(string)
}

variable "aws_vpc_id" {
}

variable "vpc_cidr" {
}

variable "dns_suffix" {
}

variable "cidrbyte" {
  type = map(string)
}

variable "azs" {
  type = list(string)
}

# variable "aws_amis" {
#   type = map(string)
# }
