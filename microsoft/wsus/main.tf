resource "aws_route53_record" "wsus" {
  count   = "${var.aws_number}"
  zone_id = "${var.dns_zone_id}"
  name    = "wsus-${count.index}.${var.dns_suffix}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.wsus.*.private_ip, count.index)}"]
}

# resource "aws_route53_record" "wsus-v6" {
#   count   = "${var.aws_number}"
#   zone_id = "${var.dns_zone_id}"
#   name    = "wsus-${count.index}.${var.dns_suffix}"
#   type    = "AAAA"
#   ttl     = "300"
#   records = ["${aws_instance.wsus.*.ipv6_addresses}"]
# }

resource "aws_instance" "wsus" {
  ami                  = "${var.aws_ami}"
  availability_zone    = "${element(var.azs, count.index)}"
  count                = "${var.aws_number}"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"
  instance_type        = "m5.xlarge"
  ipv6_address_count   = 1
  key_name             = "${var.aws_key_pair_auth_id}"
  subnet_id            = "${element(var.aws_subnet_id, count.index)}"
  user_data            = "${file("user_data/config-wsus.ps1")}"

  tags {
    Name        = "wsus-${count.index}"
    Environment = "lab"
  }

  root_block_device = {
    volume_size = 100
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
  ]
}

resource "aws_volume_attachment" "ebs_wsus" {
  device_name = "/dev/xvdb"
  count       = "${var.aws_number}"
  volume_id   = "${element(aws_ebs_volume.wsus_d.*.id, count.index)}"
  instance_id = "${element(aws_instance.wsus.*.id, count.index)}"
}

resource "aws_ebs_volume" "wsus_d" {
  count             = "${var.aws_number}"
  availability_zone = "${element(var.azs, count.index)}"
  size              = 500
  type              = "st1"
}

resource "aws_security_group" "wsus" {
  name        = "tf_evlab_wsus"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
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
    from_port   = 8530
    to_port     = 8531
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 8530
    to_port          = 8531
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
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
