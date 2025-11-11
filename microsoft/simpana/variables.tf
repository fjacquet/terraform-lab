variable "aws_ami" {
}

variable "aws_iip_assumerole_name" {
}

variable "aws_key_pair_auth_id" {
}

variable "aws_number" {
}

variable "aws_region" {
}

variable "aws_vpc_id" {
}

variable "dns_zone_id" {
}

variable "aws_subnet_id" {
  type = list(string)
}

variable "cidr" {
  type = list(string)
}

variable "aws_sg_ids" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "dns_suffix" {
}


variable "common_instance_metadata_options" {
  description = "Common metadata options for EC2 instances (IMDSv2 enforcement)"
  type = object({
    http_tokens                 = string
    http_put_response_hop_limit = number
    http_endpoint               = string
  })
}

variable "common_instance_root_block_device" {
  description = "Common root block device configuration for EC2 instances"
  type = object({
    encrypted = bool
  })
}
