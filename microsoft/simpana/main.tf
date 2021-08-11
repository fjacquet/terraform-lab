resource "aws_route53_record" "simpana" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "simpana-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.simpana.*.private_ip, count.index)]
}

resource "aws_instance" "simpana" {
  ami                  = var.aws_ami
  availability_zone    = element(var.azs, count.index)
  count                = var.aws_number
  ebs_optimized        = "true"
  iam_instance_profile = var.aws_iip_assumerole_name
  instance_type        = "m5.xlarge"
  ipv6_address_count   = 1
  key_name             = var.aws_key_pair_auth_id
  subnet_id            = element(var.aws_subnet_id, count.index)
  user_data            = file("user_data/config-simpana.ps1")

  vpc_security_group_ids = var.aws_sg_ids

  root_block_device {
    volume_size = 80
  }

  tags = {
    Name        = "simpana-${count.index}"
    Environment = "lab"
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "aws_volume_attachment" "ebs_simpana_d" {
  device_name = "/dev/xvdb"
  count       = var.aws_number
  volume_id   = element(aws_ebs_volume.simpana_d.*.id, count.index)
  instance_id = element(aws_instance.simpana.*.id, count.index)
}

resource "aws_ebs_volume" "simpana_d" {
  count             = var.aws_number
  availability_zone = element(var.azs, count.index)
  size              = 100
  type              = "gp2"
}

resource "aws_volume_attachment" "ebs_simpana_e" {
  device_name = "/dev/xvdc"
  count       = var.aws_number
  volume_id   = element(aws_ebs_volume.simpana_e.*.id, count.index)
  instance_id = element(aws_instance.simpana.*.id, count.index)
}

resource "aws_ebs_volume" "simpana_e" {
  count             = var.aws_number
  availability_zone = element(var.azs, count.index)
  size              = 500
  type              = "st1"
}

resource "aws_security_group" "master" {
  name        = "tf_evlab_simpana_master"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  # HTTP access from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # netbios access from subnet
  ingress {
    from_port   = 137
    to_port     = 137
    protocol    = "tcp"
    cidr_blocks = var.cidr
  }

  # Simpana access from subnet
  ingress {
    from_port       = 8400
    to_port         = 8403
    protocol        = "tcp"
    security_groups = [aws_security_group.client.id]
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
  name        = "tf_evlab_simpanaclient"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  # HTTP access from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # netbios access from subnet
  ingress {
    from_port   = 137
    to_port     = 137
    protocol    = "tcp"
    cidr_blocks = var.cidr
  }

  # Simpana access from subnet
  ingress {
    from_port   = 8400
    to_port     = 8403
    protocol    = "tcp"
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
