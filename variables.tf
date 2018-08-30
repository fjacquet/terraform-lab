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

variable "aws_size_nbu_backups" {
  default = 100
}

variable "aws_size_nbu_openv" {
  default = 20
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "cidr_vpc" {
  default = "10.0.0.0/16"
}

variable "cidr_back" {
  type = "list"

  default = [
    "10.0.41.0/24",
    "10.0.42.0/24",
    "10.0.43.0/24",
  ]
}

variable "cidr_exch" {
  type = "list"

  default = [
    "10.0.31.0/24",
    "10.0.32.0/24",
    "10.0.33.0/24",
  ]
}

variable "cidr_gw" {
  default = "10.0.100.0/24"
}

variable "cidr_mgmt" {
  type = "list"

  default = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
  ]
}

variable "cidr_web" {
  type = "list"

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
}

variable "aws_number_bsd" {
  default = 0
}

# Number of Direct Access instances
variable "aws_number_da" {
  default = 1
}

# Number of Active Directory instances
variable "aws_number_dc" {
  default = 2
}

# Number of DHCP instances
variable "aws_number_dhcp" {
  default = 0
}

# Number of Exchange server instances
variable "aws_number_exch" {
  default = 0
}

# Number of Guacamole server instances
variable "aws_number_guacamole" {
  default = 1
}

# Number of IPAM instances
variable "aws_number_ipam" {
  default = 0
}

# Number of mgmt server instances
variable "aws_number_jumpbox" {
  default = 1
}

# Number of Netbackup master server instances
variable "aws_number_nbumaster" {
  default = 0
}

# Number of Netbackup opscenter server instances
variable "aws_number_opscenter" {
  default = 0
}

# Number of Oracle server instances
variable "aws_number_oracle" {
  default = 0
}

# Number of PKI instances
variable "aws_number_pki_ica" {
  default = 0
}

variable "aws_number_pki_crl" {
  default = 0
}

variable "aws_number_pki_rca" {
  default = 0
}

# Number of Sharepoint server instances
variable "aws_number_sharepoint" {
  default = 0
}

# Number of Simpana server instances
variable "aws_number_simpana" {
  default = 0
}

# Number of SQL server instances
variable "aws_number_sql" {
  default = 0
}

# Number of Datacore instances
variable "aws_number_symv" {
  default = 0
}

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

resource "aws_security_group" "cvltclient" {
  name        = "terraform_evlab_cvltclient"
  description = "Used in the terraform"
  vpc_id      = "${module.global.aws_vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # netbios access from subnet
  ingress {
    from_port   = 137
    to_port     = 137
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr_back, count.index)}"]
  }

  # Simpana access from subnet
  ingress {
    from_port   = 8400
    to_port     = 8403
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr_back, count.index)}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nbuclient" {
  name        = "terraform_evlab_nbuclient"
  description = "Used in the terraform"
  vpc_id      = "${module.global.aws_vpc_id}"

  # access from media/master
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${module.linux.aws_sg_nbumaster_id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rdp" {
  name        = "terraform_evlab_rdp"
  description = "Used in the terraform"
  vpc_id      = "${module.global.aws_vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "terraform_evlab_lssh"
  description = "Used in the terraform"
  vpc_id      = "${module.global.aws_vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
