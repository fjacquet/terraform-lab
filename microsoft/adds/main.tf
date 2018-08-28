resource "aws_instance" "dc" {
  instance_type        = "t2.medium"
  count                = "${var.aws_dc_number}"
  availability_zone    = "${element(var.azs, count.index)}"
  iam_instance_profile = "${var.aws_ip_assumeRole_name}"
  aws_subnet_id        = "${var.aws_subnet_id}"
  ami                  = "${lookup(var.aws_amis, var.aws_region)}"
  key_name             = "${var.aws_key_pair_auth_id}"
  user_data            = "${file("user_data/config-dc.ps1")}"

  tags {
    Name = "dc-${count.index}"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = [
    "${var.aws_sg_id}",
    "${aws_security_group.dc.id}",
  ]
}

resource "aws_security_group" "dc" {
  name        = "terraform_evlab_dc"
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
