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

variable "cidr" {
  type = "map"

  default = {
    back1.eu-west-1   = "10.0.51.0/24"
    back2.eu-west-1   = "10.0.52.0/24"
    back3.eu-west-1   = "10.0.53.0/24"
    backup1.eu-west-1 = "10.0.41.0/24"
    backup2.eu-west-1 = "10.0.42.0/24"
    backup3.eu-west-1 = "10.0.43.0/24"
    exch1.eu-west-1   = "10.0.31.0/24"
    exch2.eu-west-1   = "10.0.32.0/24"
    exch3.eu-west-1   = "10.0.33.0/24"
    gw1.eu-west-1     = "10.0.100.0/24"
    gw2.eu-west-1     = "10.0.101.0/24"
    gw3.eu-west-1     = "10.0.102.0/24"
    mgmt1.eu-west-1   = "10.0.11.0/24"
    mgmt2.eu-west-1   = "10.0.12.0/24"
    mgmt3.eu-west-1   = "10.0.13.0/24"
    sql1.eu-west-1    = "10.0.61.0/24"
    sql2.eu-west-1    = "10.0.62.0/24"
    sql3.eu-west-1    = "10.0.63.0/24"
    vpc.eu-west-1     = "10.0.0.0/16"
    web1.eu-west-1    = "10.0.1.0/24"
    web2.eu-west-1    = "10.0.2.0/24"
    web3.eu-west-1    = "10.0.3.0/24"
  }
}

variable "aws_number" {
  type = "map"

  default = {
    bsd        = 0
    da         = 0
    dc         = 2
    dhcp       = 2
    exch       = 0
    fs         = 2
    guacamole  = 0
    ipam       = 1
    jumpbox    = 1
    nbu        = 0
    nps        = 2
    opscenter  = 0
    oracle     = 0
    pki_crl    = 1
    pki_ica    = 1
    pki_rca    = 1
    sharepoint = 0
    simpana    = 0
    sql        = 0
    symv       = 2
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
