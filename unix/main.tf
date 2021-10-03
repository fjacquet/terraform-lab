module "bsd" {
  source               = "./bsd"
  aws_ami              = data.aws_ami.bsd.id
  aws_key_pair_auth_id = var.aws_key_pair_auth_id
  aws_number           = var.aws_number["bsd"]
  aws_subnet_id        = var.aws_subnet_back_id
  azs                  = var.azs
  dns_zone_id          = var.dns_zone_id
  dns_suffix           = var.dns_suffix

  aws_sg_ids = flatten([
    module.nbu.aws_sg_client_ids,
    aws_security_group.ssh.id,
    var.aws_sg_simpana_client_id,
  ])
}

module "glpi" {
  source                  = "./glpi"
  aws_ami                 = data.aws_ami.debian.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["glpi"]
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  aws_sg_ids = flatten([
    aws_security_group.ssh.id,
    module.glpi.aws_sg_glpi_id,
  ])
}
module "vault" {
  source                  = "./vault"
  aws_ami                 = data.aws_ami.debian.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["vault"]
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  aws_sg_ids = flatten([
    aws_security_group.ssh.id,
    module.vault.aws_sg_vault_id,
  ])
}

module "guacamole" {
  source                  = "./guacamole"
  aws_ami                 = data.aws_ami.debian.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["guacamole"]
  aws_subnet_id           = var.aws_subnet_mgmt_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_public_zone_id      = var.dns_public_zone_id
  dns_suffix              = var.dns_suffix

  aws_sg_ids = flatten([
    aws_security_group.ssh.id,
    module.guacamole.aws_sg_guacamole_id,
  ])
}

module "nbu" {
  source                  = "./nbu"
  aws_ami                 = data.aws_ami.rhel8.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["nbu"]
  aws_size_nbu_backups    = var.aws_disks_size["nbu_backups"]
  aws_size_nbu_openv      = var.aws_disks_size["nbu_openv"]
  aws_subnet_id           = var.aws_subnet_backup_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["backup1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["backup2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["backup3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.ssh.id,
  ])
}

module "oracle" {
  source                  = "./oracle"
  aws_ami                 = data.aws_ami.rhel8.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["oracle"]
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  cidr = [
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back1.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back2.${var.aws_region}"]),
    cidrsubnet(var.vpc_cidr, 8, var.cidrbyte["back3.${var.aws_region}"]),
  ]

  aws_sg_ids = flatten([
    aws_security_group.ssh.id,
    module.nbu.aws_sg_client_ids,
    module.oracle.aws_sg_oracle_id,
    # var.aws_sg_simpana_client_id,
  ])
}

module "redis" {
  source                  = "./redis"
  aws_ami                 = data.aws_ami.debian.id
  aws_iip_assumerole_name = var.aws_iip_assumerole_name
  aws_key_pair_auth_id    = var.aws_key_pair_auth_id
  aws_number              = var.aws_number["redis"]
  aws_subnet_id           = var.aws_subnet_back_id
  aws_vpc_id              = var.aws_vpc_id
  azs                     = var.azs
  dns_zone_id             = var.dns_zone_id
  dns_suffix              = var.dns_suffix

  aws_sg_ids = flatten([
    aws_security_group.ssh.id,
    module.redis.aws_sg_redis_id,
  ])
}

resource "aws_security_group" "ssh" {
  name        = "tf_ezlab_lssh"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }
}


data "aws_ami" "bsd" {
  most_recent = true
  filter {
    name   = "name"
    values = ["FreeBSD 13.0-RELEASE-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["679593333241"] # aws-marketplace FreeBSD
}

data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-11-amd64*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["679593333241"] # aws-marketplace Debian
}

data "aws_ami" "amazon" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amazonlinux-2-base*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["766535289950"] # Canonical
}

data "aws_ami" "rhel8" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["801119661308"] # Canonical
}
