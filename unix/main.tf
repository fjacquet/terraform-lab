module "bsd" {
  source               = "./bsd"
  aws_ami              = "${lookup(var.aws_amis , "bsd")}"
  aws_key_pair_auth_id = "${var.aws_key_pair_auth_id}"
  aws_number           = "${lookup(var.aws_number, "bsd")}"
  aws_subnet_id        = "${var.aws_subnet_back_id}"
  azs                  = "${var.azs}"
  dns_zone_id          = "${var.dns_zone_id}"
  dns_suffix           = "${var.dns_suffix}"

  aws_sg_ids = [
    "${module.nbu.aws_sg_client_id}",
    "${aws_security_group.ssh.id}",
    "${var.aws_sg_simpanaclient_id}",
  ]
}

module "guacamole" {
  source                  = "./guacamole"
  aws_ami                 = "${lookup(var.aws_amis , "guacamole")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "guacamole")}"
  aws_subnet_id           = "${var.aws_subnet_mgmt_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  dns_zone_id             = "${var.dns_zone_id}"
  dns_suffix              = "${var.dns_suffix}"

  aws_sg_ids = [
    "${aws_security_group.ssh.id}",
    "${module.guacamole.aws_sg_guacamole_id}",
  ]
}

module "nbu" {
  source                  = "./nbu"
  aws_ami                 = "${lookup(var.aws_amis , "nbu")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "nbu")}"
  aws_size_nbu_backups    = "${lookup(var.aws_disks_size, "nbu_backups")}"
  aws_size_nbu_openv      = "${lookup(var.aws_disks_size, "nbu_openv")}"
  aws_subnet_id           = "${var.aws_subnet_backup_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  dns_zone_id             = "${var.dns_zone_id}"
  dns_suffix              = "${var.dns_suffix}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "backup1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "backup2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "backup3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.ssh.id}",
  ]
}

module "oracle" {
  source                  = "./oracle"
  aws_ami                 = "${lookup(var.aws_amis , "oracle")}"
  aws_iip_assumerole_name = "${var.aws_iip_assumerole_name}"
  aws_key_pair_auth_id    = "${var.aws_key_pair_auth_id}"
  aws_number              = "${lookup(var.aws_number, "oracle")}"
  aws_subnet_id           = "${var.aws_subnet_back_id}"
  aws_vpc_id              = "${var.aws_vpc_id}"
  azs                     = "${var.azs}"
  dns_zone_id             = "${var.dns_zone_id}"
  dns_suffix              = "${var.dns_suffix}"

  cidr = [
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back1.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back2.${var.aws_region}"))}",
    "${cidrsubnet(var.vpc_cidr,8,lookup(var.cidrbyte, "back3.${var.aws_region}"))}",
  ]

  aws_sg_ids = [
    "${aws_security_group.ssh.id}",
    "${module.nbu.aws_sg_client_id}",
    "${module.oracle.aws_sg_oracle_id}",
    "${var.aws_sg_simpanaclient_id}",
  ]
}

resource "aws_security_group" "ssh" {
  name        = "tf_evlab_lssh"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

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

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }
}
