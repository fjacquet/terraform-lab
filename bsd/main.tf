resource "aws_instance" "bsd" {
  instance_type          = "t2.micro"
  count                  = "${var.aws_number}"
  availability_zone      = "${element(var.azs, count.index)}"
  ami                    = "${lookup(var.aws_amis, var.aws_region)}"
  subnet_id              = "${var.aws_subnet_id}"
  key_name               = "${var.aws_key_pair_auth_id}"
  vpc_security_group_ids = "${var.aws_sg_ids}"

  tags {
    Name = "bsd-${count.index}"
  }
}
