resource "aws_route53_record" "fs" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "fs-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.fs.*.private_ip, count.index)]
}

# resource "aws_route53_record" "fs-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "fs-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.fs.*.ipv6_addresses}"]
# }

resource "aws_instance" "fs" {
  ami                  = var.aws_ami
  availability_zone    = element(var.azs, count.index)
  count                = var.aws_number
  iam_instance_profile = var.aws_iip_assumerole_name
  instance_type        = "t3.medium"
  ipv6_address_count   = 1
  key_name             = var.aws_key_pair_auth_id
  subnet_id            = element(var.aws_subnet_id, count.index)
  user_data            = file("user_data/config-win.ps1")

  tags = {
    Name        = "fs-${count.index}"
    Environment = "lab"
    type        = "fs"
    system      = "windows"
  }

  lifecycle {
    ignore_changes = [user_data]
  }
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = "1"
  }

  root_block_device {
    encrypted = true
  }


  # Our Security group to allow RDP access
  vpc_security_group_ids = var.aws_sg_ids
}

resource "aws_volume_attachment" "ebs_fs_d" {
  device_name = "/dev/xvdb"
  count       = var.aws_number
  volume_id   = element(aws_ebs_volume.fs_d.*.id, count.index)
  instance_id = element(aws_instance.fs.*.id, count.index)
}

resource "aws_ebs_volume" "fs_d" {
  count             = var.aws_number
  availability_zone = element(var.azs, count.index)
  size              = 100
  type              = "gp2"
}

resource "aws_security_group" "fs" {
  name        = "tf_ezlab_fs"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  ingress {
    description     = "file Server"
    from_port       = 445
    to_port         = 445
    protocol        = "tcp"
    security_groups = [var.aws_sg_domain_members]
  }

  ingress {
    description = "ping"
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
    self        = true
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
