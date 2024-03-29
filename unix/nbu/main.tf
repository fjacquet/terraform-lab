resource "aws_route53_record" "nbumaster" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "nbu-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.nbumaster.*.private_ip, count.index)]
}

resource "aws_instance" "nbumaster" {
  instance_type        = "m4.xlarge"
  ipv6_address_count   = 1
  count                = var.aws_number
  availability_zone    = element(var.azs, count.index)
  ami                  = var.aws_ami
  key_name             = var.aws_key_pair_auth_id
  ebs_optimized        = "true"
  subnet_id            = element(var.aws_subnet_id, count.index)
  user_data            = file("user_data/config-linux.sh")
  iam_instance_profile = var.aws_iip_assumerole_name

  vpc_security_group_ids = var.aws_sg_ids

  root_block_device {
    volume_size = 80
    encrypted   = true
  }
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = "1"
  }


  tags = {
    Name        = "nbu-${count.index}"
    Environment = "lab"
    type        = "netbackup"
    system      = "rhel"
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "aws_volume_attachment" "ebs_openv" {
  device_name = "/dev/xvdb"
  count       = var.aws_number
  volume_id   = element(aws_ebs_volume.openv.*.id, count.index)
  instance_id = element(aws_instance.nbumaster.*.id, count.index)
}

resource "aws_ebs_volume" "openv" {
  availability_zone = element(var.azs, count.index)
  count             = var.aws_number
  type              = "gp2"
  size              = var.aws_size_nbu_openv
}

resource "aws_volume_attachment" "ebs_backups" {
  device_name = "/dev/xvdc"
  count       = var.aws_number
  volume_id   = element(aws_ebs_volume.backups.*.id, count.index)
  instance_id = element(aws_instance.nbumaster.*.id, count.index)
}

resource "aws_ebs_volume" "backups" {
  count             = var.aws_number
  availability_zone = element(var.azs, count.index)
  type              = "sc1"
  size              = var.aws_size_nbu_backups
}

resource "aws_security_group" "master" {
  count       = var.aws_number
  name        = "tf_ezlab_master"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  # pbx for clients
  ingress {
    from_port = 1556
    to_port   = 1556
    protocol  = "tcp"

    security_groups = flatten([
      aws_security_group.client.*.id,
    ])
  }

  # novnc
  ingress {
    from_port   = 6080
    to_port     = 6080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # vnetd
  ingress {
    from_port   = 13724
    to_port     = 13724
    protocol    = "tcp"
    cidr_blocks = var.cidr
  }

  # at port
  ingress {
    from_port   = 2821
    to_port     = 2821
    protocol    = "tcp"
    cidr_blocks = var.cidr
  }

  # auth-port
  ingress {
    from_port   = 4032
    to_port     = 4032
    protocol    = "tcp"
    cidr_blocks = var.cidr
  }

  # spad port
  ingress {
    from_port   = 10102
    to_port     = 10102
    protocol    = "tcp"
    cidr_blocks = var.cidr
  }

  # spoold port
  ingress {
    from_port   = 10082
    to_port     = 10082
    protocol    = "tcp"
    cidr_blocks = var.cidr
  }

  # portmapper nfs port
  ingress {
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = var.cidr
  }

  # portmapper nfs port
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.cidr
  }

  # portmapper nfs port
  ingress {
    from_port   = 29588
    to_port     = 29588
    protocol    = "tcp"
    cidr_blocks = var.cidr
  }

  # nbfsd nfs port
  ingress {
    from_port   = 7394
    to_port     = 7394
    protocol    = "tcp"
    cidr_blocks = var.cidr
  }

  # access from media/master
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr
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

resource "aws_security_group" "client" {
  count       = var.aws_number
  name        = "tf_ezlab_client"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  # access from media/master
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr
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
