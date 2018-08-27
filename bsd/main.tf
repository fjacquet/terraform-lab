resource "aws_instance" "bsd" {
  instance_type     = "t2.micro"
  count             = "${var.aws_bsd_number}"
  availability_zone = "${element(var.azs, count.index)}"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_bsd_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  tags {
    Name = "bsd-server-${count.index}"
  }

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = [
    "${aws_security_group.linux-ssh.id}",
    "${aws_security_group.nbuclient.id}",
    "${aws_security_group.cvltclient.id}",
  ]

  subnet_id = "${aws_subnet.default.id}"
}

