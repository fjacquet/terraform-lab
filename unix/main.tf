module "bsd" {
  source        = "./bsd"
  aws_ami       = var.aws_number["bsd"] > 0 ? data.aws_ami.bsd[0].id : ""
  aws_number    = var.aws_number["bsd"]
  aws_subnet_id = var.aws_subnet_back_id

  # Common Unix configuration
  aws_key_pair_auth_id = local.common_unix_config.aws_key_pair_auth_id
  azs                  = local.common_unix_config.azs
  dns_zone_id          = local.common_unix_config.dns_zone_id
  dns_suffix           = local.common_unix_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Common security groups
  aws_sg_ids = local.common_unix_sg_ids
}

module "glpi" {
  source        = "./glpi"
  aws_ami       = data.aws_ami.debian.id
  aws_number    = var.aws_number["glpi"]
  aws_subnet_id = var.aws_subnet_back_id

  # Common Unix configuration
  aws_iip_assumerole_name = local.common_unix_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_unix_config.aws_key_pair_auth_id
  aws_vpc_id              = local.common_unix_config.aws_vpc_id
  azs                     = local.common_unix_config.azs
  dns_zone_id             = local.common_unix_config.dns_zone_id
  dns_suffix              = local.common_unix_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific security groups
  aws_sg_ids = flatten([
    aws_security_group.ssh.id,
    module.glpi.aws_sg_glpi_id,
  ])
}
module "vault" {
  source        = "./vault"
  aws_ami       = data.aws_ami.debian.id
  aws_number    = var.aws_number["vault"]
  aws_subnet_id = var.aws_subnet_back_id

  # Common Unix configuration
  aws_iip_assumerole_name = local.common_unix_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_unix_config.aws_key_pair_auth_id
  aws_vpc_id              = local.common_unix_config.aws_vpc_id
  azs                     = local.common_unix_config.azs
  dns_zone_id             = local.common_unix_config.dns_zone_id
  dns_suffix              = local.common_unix_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific security groups
  aws_sg_ids = flatten([
    aws_security_group.ssh.id,
    module.vault.aws_sg_vault_id,
  ])
}

module "guacamole" {
  source        = "./guacamole"
  aws_ami       = data.aws_ami.debian.id
  aws_number    = var.aws_number["guacamole"]
  aws_subnet_id = var.aws_subnet_mgmt_id

  # Common Unix configuration
  aws_iip_assumerole_name = local.common_unix_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_unix_config.aws_key_pair_auth_id
  aws_vpc_id              = local.common_unix_config.aws_vpc_id
  azs                     = local.common_unix_config.azs
  dns_zone_id             = local.common_unix_config.dns_zone_id
  dns_public_zone_id      = local.common_unix_config.dns_public_zone_id

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device
  dns_suffix              = local.common_unix_config.dns_suffix

  # Service-specific security groups
  aws_sg_ids = flatten([
    aws_security_group.ssh.id,
    module.guacamole.aws_sg_guacamole_id,
  ])
}

module "nbu" {
  source               = "./nbu"
  aws_ami              = (var.aws_number["nbu"] + var.aws_number["oracle"]) > 0 ? data.aws_ami.rhel9[0].id : ""
  aws_number           = var.aws_number["nbu"]
  aws_size_nbu_backups = var.aws_disks_size["nbu_backups"]
  aws_size_nbu_openv   = var.aws_disks_size["nbu_openv"]
  aws_subnet_id        = var.aws_subnet_backup_id

  # Common Unix configuration
  aws_iip_assumerole_name = local.common_unix_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_unix_config.aws_key_pair_auth_id
  aws_vpc_id              = local.common_unix_config.aws_vpc_id
  azs                     = local.common_unix_config.azs
  dns_zone_id             = local.common_unix_config.dns_zone_id
  dns_suffix              = local.common_unix_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.backup

  # Service-specific security groups
  aws_sg_ids = flatten([
    aws_security_group.ssh.id,
  ])
}

module "oracle" {
  source        = "./oracle"
  aws_ami       = (var.aws_number["nbu"] + var.aws_number["oracle"]) > 0 ? data.aws_ami.rhel9[0].id : ""
  aws_number    = var.aws_number["oracle"]
  aws_subnet_id = var.aws_subnet_back_id

  # Common Unix configuration
  aws_iip_assumerole_name = local.common_unix_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_unix_config.aws_key_pair_auth_id
  aws_vpc_id              = local.common_unix_config.aws_vpc_id
  azs                     = local.common_unix_config.azs
  dns_zone_id             = local.common_unix_config.dns_zone_id
  dns_suffix              = local.common_unix_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Use computed CIDR blocks from root locals
  cidr = local.cidr_blocks.back

  # Service-specific security groups
  aws_sg_ids = flatten([
    aws_security_group.ssh.id,
    module.nbu.aws_sg_client_ids,
    module.oracle.aws_sg_oracle_id,
    # var.aws_sg_simpana_client_id,
  ])
}

module "redis" {
  source        = "./redis"
  aws_ami       = data.aws_ami.debian.id
  aws_number    = var.aws_number["redis"]
  aws_subnet_id = var.aws_subnet_back_id

  # Common Unix configuration
  aws_iip_assumerole_name = local.common_unix_config.aws_iip_assumerole_name
  aws_key_pair_auth_id    = local.common_unix_config.aws_key_pair_auth_id
  aws_vpc_id              = local.common_unix_config.aws_vpc_id
  azs                     = local.common_unix_config.azs
  dns_zone_id             = local.common_unix_config.dns_zone_id
  dns_suffix              = local.common_unix_config.dns_suffix

  # Common instance configuration
  common_instance_metadata_options    = local.common_instance_metadata_options
  common_instance_root_block_device   = local.common_instance_root_block_device

  # Service-specific security groups
  aws_sg_ids = flatten([
    aws_security_group.ssh.id,
    module.redis.aws_sg_redis_id,
  ])
}

resource "aws_security_group" "ssh" {
  name        = "tf_ezlab_lssh"
  description = "Security group for Unix/Linux administrative access (SSH)"
  vpc_id      = var.aws_vpc_id

  # SSH access from restricted CIDR blocks
  ingress {
    description = "Allow SSH from admin CIDR blocks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
  }

  # Cockpit web console access from VPC
  ingress {
    description = "Allow Cockpit web console from VPC"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Dynamic egress rules - eliminates code duplication
  dynamic "egress" {
    for_each = local.common_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }
}


data "aws_ami" "bsd" {
  count       = var.aws_number["bsd"] > 0 ? 1 : 0
  most_recent = true
  filter {
    name   = "name"
    values = ["FreeBSD 13.*-RELEASE-amd64*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["118940168514"] # FreeBSD official
}

data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["136693071363"] # Debian official
}

data "aws_ami" "amazon" {
  count       = var.aws_number["oracle"] > 0 ? 1 : 0
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"] # Amazon
}

data "aws_ami" "rhel9" {
  count       = (var.aws_number["nbu"] + var.aws_number["oracle"]) > 0 ? 1 : 0
  most_recent = true
  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*-x86_64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["309956199498"] # Red Hat
}
