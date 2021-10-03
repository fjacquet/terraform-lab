variable "access_key" {
}

variable "aws_region" {
}

variable "secret_key" {
}

variable "public_key" {
}

variable "key_name" {
}

variable "azs" {
  type = list(string)
}

# variable "cidr" {
#   type = "map"
# }

variable "cidrbyte" {
  type = map(string)
}

# variable "dhcpops" {
# }

variable "dns_suffix" {
}

variable "public_dns_id" {
}

variable "aws_number" {
  type = map(string)
}
