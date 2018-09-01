variable "azs" {
  type = "list"
}

variable "cidr" {
  type = "map"
}

variable "aws_region" {}

variable "subnet_back" {
  type = "list"
}

variable "subnet_backup" {
  type = "list"
}

variable "subnet_exch" {
  type = "list"
}

variable "subnet_mgmt" {
  type = "list"
}

variable "subnet_sql" {
  type = "list"
}

variable "subnet_web" {
  type = "list"
}
