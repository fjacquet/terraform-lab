resource "aws_instance" "pki-rca" {
  instance_type        = "t2.medium"
  count                = "${var.aws_number_pki_rca}"
  availability_zone    = "${element(var.azs, count.index)}"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"
  subnet_id            = "${element(var.aws_subnet_id, count.index)}"
  ami                  = "${lookup(var.aws_amis, var.aws_region)}"
  user_data            = "${file("user_data/config-pki.ps1")}"
  key_name             = "${var.aws_key_pair_auth_id}"

  tags {
    Name = "pki-rca-${count.index}"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
    "${aws_security_group.pki_rca.id}",
  ]
}

# A security group for basic windows box
resource "aws_security_group" "pki_rca" {
  name        = "terraform_evlab_windows_pki"
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
