variable "aws_key_pair_auth_id" {
}

variable "aws_number" {
}

variable "dns_zone_id" {
}

variable "aws_subnet_id" {
  type = list(string)
}

variable "aws_ami" {
}

variable "aws_sg_ids" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "dns_suffix" {
}
