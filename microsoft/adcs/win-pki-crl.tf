resource "aws_instance" "pki-crl" {
  ami                  = "${var.aws_ami}"
  availability_zone    = "${element(var.azs, count.index)}"
  count                = "${var.aws_number_pki_crl}"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"
  instance_type        = "t2.medium"
  ipv6_address_count   = 1
  key_name             = "${var.aws_key_pair_auth_id}"
  subnet_id            = "${element(var.aws_subnet_id, count.index)}"
  user_data            = "${file("user_data/config-pki.ps1")}"

  tags {
    Name = "pki-crl-${count.index}"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
    "${aws_security_group.pki_crl.id}",
  ]
}

# A security group for basic windows box
resource "aws_security_group" "pki_crl" {
  name        = "tf_evlab_pki_crl"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
