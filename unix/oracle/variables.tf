variable "aws_iip_assumerole_name" {}
variable "aws_key_pair_auth_id" {}

variable "cidr" {
  type = "list"
}

variable "aws_number" {}

variable "aws_vpc_id" {}

variable "aws_subnet_id" {
  type = "list"
}

variable "aws_sg_ids" {
  type = "list"
}

variable "aws_ami" {}

variable "azs" {
  type = "list"
}

# Size of Oracle data disks
variable "aws_size_oracle_u01" {
  default = 100
}

variable "dns_zone_id" {}
