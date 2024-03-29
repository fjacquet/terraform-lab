resource "aws_route53_record" "oracle" {
  count   = var.aws_number
  zone_id = var.dns_zone_id
  name    = "oracle-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.oracle.*.private_ip, count.index)]
}

# resource "aws_route53_record" "oracle-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "oracle-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.oracle.*.ipv6_addresses}"]
# }

resource "aws_instance" "oracle" {
  instance_type          = "m5.xlarge"
  ipv6_address_count     = 1
  count                  = var.aws_number
  availability_zone      = element(var.azs, count.index)
  iam_instance_profile   = var.aws_iip_assumerole_name
  ami                    = var.aws_ami
  key_name               = var.aws_key_pair_auth_id
  ebs_optimized          = "true"
  subnet_id              = element(var.aws_subnet_id, count.index)
  user_data              = file("user_data/config-ora18.sh")
  vpc_security_group_ids = var.aws_sg_ids

  lifecycle {
    ignore_changes = [user_data]
  }
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = "1"
  }

  root_block_device {
    encrypted   = true
    volume_size = 80
  }


  tags = {
    Name        = "oracle-${count.index}"
    Environment = "lab"
    type        = "oracle"
    system      = "rhel"
  }
}

resource "aws_volume_attachment" "ebs_u01" {
  device_name = "/dev/xvdb"
  count       = var.aws_number
  volume_id   = element(aws_ebs_volume.oracle_u01.*.id, count.index)
  instance_id = element(aws_instance.oracle.*.id, count.index)
}

resource "aws_ebs_volume" "oracle_u01" {
  count             = var.aws_number
  availability_zone = element(var.azs, count.index)
  type              = "gp2"
  size              = var.aws_size_oracle_u01
}

resource "aws_security_group" "oracle" {
  name        = "tf_ezlab_oracle"
  description = "Used in the terraform"
  vpc_id      = var.aws_vpc_id

  # listener for clients
  ingress {
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 5500
    to_port     = 5500
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
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
