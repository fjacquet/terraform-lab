
#  BSD Amazon instance
variable "aws_amis_bsd" {
  default = {
    eu-west-1 = "ami-048e0d77"
  }
}

#  guacamole Amazon instance
variable "aws_amis_guacamole" {
  default = {
    eu-west-1 = "ami-7c491f05"
  }
}

#  RHEL 75
variable "aws_amis_lnx" {
  default = {
    eu-west-1 = "ami-7c491f05"
  }
}

variable "aws_amis_jumpbox" {
  default = {
    eu-west-1 = "ami-088f9db67b4afec52"
  }
}

#  Netbackup Amazon instance
variable "aws_amis_nbu" {
  default = {
    eu-west-1 = "ami-7c491f05"
  }
}

#  Oracle Amazon instance
variable "aws_amis_oracle" {
  default = {
    eu-west-1 = "ami-7c491f05"
  }
}

#  Sharepoint Amazon instance
variable "aws_amis_sharepoint" {
  default = {
    eu-west-1 = "ami-056d4676"
  }
}

#  SQL 2016
variable "aws_amis_sql" {
  default = {
    eu-west-1 = "ami-05b9370efd1cefcf4"
  }
}

#  Win 2012R2
variable "aws_amis_win2012r2" {
  default = {
    eu-west-1 = "ami-04191f05759452cfa"
  }
}

#  Win 2016
variable "aws_amis_win2016" {
  default = {
    eu-west-1 = "ami-088f9db67b4afec52"
  }
}
