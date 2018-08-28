variable "public_key" {
  description = "openssh macbookpro"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeLAdDOiIivLR7n8J6A/KdqizTmVoBgglm7cdA8XK1q1fTimIbz73jwiYkFIdggn//fhL5ijTS/mFEF3X+GJ61W7Fczdzq9gt+o8h/wcrCI/Zm1tDxDCxRSXN87EvclVOM57yKTYLOzMXPTlhrR2JfbJRSHWZljO5HLcZm7WJgG/IZg1BFJovDRD4T2hpvQ37emJSUpvCq8+aTy6XPxCiHp5IwakIGm92l0vdope7eYLXaiXTTAghC8wABGLv885KZqg+uc3ao9oZXpdRbJR+xuBiiwx3R8R+/t8TnIw2cFLqRtUuB3CI33BX7h1P1bUoCOA6senaSLkQOZ5xRnJR/ fjacquet@fj-mbp"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "alfred"
}

variable "azs" {
  description = "AWS availability zone to launch servers."
  type        = "list"

  default = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c",
  ]
}

# Region
variable "aws_region" {
  type    = "string"
  default = "eu-west-1"
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "cidr_back" {
  type = "list"

  default = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
  ]
}

variable "cidr_exch" {
  type = "list"

  default = [
    "10.0.21.0/24",
    "10.0.22.0/24",
    "10.0.23.0/24",
  ]
}

variable "cidr_gw" {
  default = "10.0.100.0/24"
}

variable "cidr_mgmt" {
  default = "10.0.20.0/24"
}

variable "cidr_vpc" {
  default = "10.0.0.0/16"
}

variable "cidr_web" {
  type = "list"

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
}

variable "aws_size_nbu_backups" {
  default = 100
}

variable "aws_size_nbu_openv" {
  default = 20
}
