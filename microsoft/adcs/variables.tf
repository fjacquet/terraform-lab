variable "aws_iip_assumerole_name" {
}

variable "aws_key_pair_auth_id" {
}

variable "aws_number_pki-crl" {
}

variable "aws_number_pki-ica" {
}

variable "aws_number_pki-rca" {
}

variable "aws_number_pki-ndes" {
}

variable "aws_vpc_id" {
}

variable "dns_zone_id" {
}

variable "cidr" {
  type = list(string)
}

variable "aws_sg_ids" {
  type = list(string)
}

variable "aws_ami" {
}

variable "aws_subnet_id" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "dns_suffix" {
}
