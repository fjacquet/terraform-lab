variable "aws_key_pair_auth_id" {}
variable "aws_number" {}

variable "aws_subnet_id" {
  type = "list"
}

variable "aws_ami" {}

variable "aws_sg_ids" {
  type = "list"
}

variable "azs" {
  type = "list"
}
