resource "aws_instance" "ipam" {
  instance_type        = "t2.medium"
  count                = "${var.aws_number}"
  availability_zone    = "${element(var.azs, count.index)}"
  subnet_id            = "${element(var.aws_subnet_id, count.index)}"
  ami                  = "${var.aws_ami}"
  user_data            = "${file("user_data/config-ipam.ps1")}"
  key_name             = "${var.aws_key_pair_auth_id}"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"

  tags {
    Name = "ipam-${count.index}"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
  ]
}

resource "aws_security_group" "ipam" {
  name        = "tf_evlab_ipam"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
