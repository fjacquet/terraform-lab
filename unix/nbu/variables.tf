variable "azs" {
  type = "list"
}

variable "dns_suffix" {}
variable "aws_ami" {}

# Size of Netbackup backups disks
variable "aws_size_nbu_backups" {
  default = 100
}

variable "aws_size_nbu_openv" {
  default = 20
}

variable "aws_sg_ids" {
  type = "list"
}

variable "aws_iip_assumerole_name" {}
variable "aws_key_pair_auth_id" {}
variable "aws_number" {}

variable "aws_subnet_id" {
  type = "list"
}

variable "dns_zone_id" {}
variable "aws_vpc_id" {}

variable "cidr" {
  type = "list"
}
