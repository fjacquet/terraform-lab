resource "aws_instance" "dhcp" {
  ami                  = "${var.aws_ami}"
  availability_zone    = "${element(var.azs, count.index)}"
  count                = "${var.aws_number}"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"
  instance_type        = "t2.medium"
  ipv6_address_count   = 1
  key_name             = "${var.aws_key_pair_auth_id}"
  subnet_id            = "${element(var.aws_subnet_id, count.index)}"
  user_data            = "${file("user_data/config-dhcp.ps1")}"

  tags {
    Name = "dhcp-${count.index}"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
  ]
}

resource "aws_security_group" "dhcp" {
  name        = "tf_evlab_dhcp"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    description = "DHCP Server"
    from_port   = 67
    to_port     = 67
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "MADCAP"
    from_port   = 2535
    to_port     = 2535
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "DHCP Failover"
    from_port   = 647
    to_port     = 647
    protocol    = "tcp"
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
