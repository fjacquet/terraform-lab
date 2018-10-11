variable "public_key" {
  description = "openssh macbookpro"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeLAdDOiIivLR7n8J6A/KdqizTmVoBgglm7cdA8XK1q1fTimIbz73jwiYkFIdggn//fhL5ijTS/mFEF3X+GJ61W7Fczdzq9gt+o8h/wcrCI/Zm1tDxDCxRSXN87EvclVOM57yKTYLOzMXPTlhrR2JfbJRSHWZljO5HLcZm7WJgG/IZg1BFJovDRD4T2hpvQ37emJSUpvCq8+aTy6XPxCiHp5IwakIGm92l0vdope7eYLXaiXTTAghC8wABGLv885KZqg+uc3ao9oZXpdRbJR+xuBiiwx3R8R+/t8TnIw2cFLqRtUuB3CI33BX7h1P1bUoCOA6senaSLkQOZ5xRnJR/ fjacquet@fj-mbp"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "alfred"
}

variable "dns_suffix" {
  description = "name of DNS zone"
  default     = "evlab.ch"
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

variable "aws_disks_size" {
  type = "map"

  default = {
    nbu_backups = 100
    nbu_openv   = 20
  }
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "cidrbyte" {
  type = "map"

  default = {
    back1.eu-west-1     = "51"
    back2.eu-west-1     = "52"
    back3.eu-west-1     = "53"
    backup1.eu-west-1   = "41"
    backup2.eu-west-1   = "42"
    backup3.eu-west-1   = "43"
    exchange1.eu-west-1 = "31"
    exchange2.eu-west-1 = "32"
    exchange3.eu-west-1 = "33"
    gw1.eu-west-1       = "101"
    gw2.eu-west-1       = "102"
    gw3.eu-west-1       = "103"
    mgmt1.eu-west-1     = "11"
    mgmt2.eu-west-1     = "12"
    mgmt3.eu-west-1     = "13"
    sql1.eu-west-1      = "61"
    sql2.eu-west-1      = "62"
    sql3.eu-west-1      = "63"
    vpc.eu-west-1       = "0"
    web1.eu-west-1      = "1"
    web2.eu-west-1      = "2"
    web3.eu-west-1      = "3"
  }
}

variable "aws_number" {
  type = "map"

  default = {
    adfs       = 0
    bsd        = 0
    csv        = 0
    da         = 0
    dc         = 1
    dhcp       = 0
    exchange   = 0
    fs         = 2
    guacamole  = 1
    ipam       = 0
    jumpbox    = 1
    nbu        = 0
    nps        = 0
    opscenter  = 0
    oracle     = 0
    pki-crl    = 1
    pki-ica    = 0
    pki-rca    = 1
    pki-ndes   = 0
    csv        = 0
    sharepoint = 0
    simpana    = 1
    sql        = 0
    symv       = 0
    wac        = 0
    wds        = 0
    wsus       = 1
  }
}

variable "aws_amis" {
  type = "map"

  default = {
    bsd        = "ami-048e0d77"
    guacamole  = "ami-7c491f05"
    jumpbox    = "ami-088f9db67b4afec52"
    lnx        = "ami-7c491f05"
    nbu        = "ami-7c491f05"
    oracle     = "ami-7c491f05"
    sharepoint = "ami-056d4676"
    sql        = "ami-05b9370efd1cefcf4"
    win2012r2  = "ami-04191f05759452cfa"
    win2016    = "ami-088f9db67b4afec52"
    wsus       = "ami-088f9db67b4afec52"
  }
}
