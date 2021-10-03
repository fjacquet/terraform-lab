variable "azs" {
  type = list(string)
}

variable "aws_number" {
  type = map(string)
}

# variable "cidr" {
#   type = "map"
# }

# variable "dhcpops" {
# }

variable "cidrbyte" {
  type = map(string)
}

variable "aws_region" {
}

variable "cidrbyte_back" {
  type = list(string)
}

variable "cidrbyte_backup" {
  type = list(string)
}

variable "cidrbyte_exchange" {
  type = list(string)
}

variable "cidrbyte_mgmt" {
  type = list(string)
}

variable "cidrbyte_sql" {
  type = list(string)
}

variable "cidrbyte_web" {
  type = list(string)
}

variable "cidrbyte_gw" {
  type = list(string)
}
