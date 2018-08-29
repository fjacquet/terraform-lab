resource "aws_instance" "jumpbox" {
  instance_type        = "t2.medium"
  count                = "${var.aws_number}"
  availability_zone    = "${element(var.azs, count.index)}"
  key_name             = "${var.aws_key_pair_auth_id}"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"
  user_data            = "${file("user_data/config-win.ps1")}"
  ami                  = "${lookup(var.aws_amis, var.aws_region)}"
  subnet_id            = "${var.aws_subnet_id}"

  tags {
    Name = "mgmt-${count.index}"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
  ]
}
