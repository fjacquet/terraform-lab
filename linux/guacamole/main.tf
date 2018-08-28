resource "aws_instance" "guacamole" {
  instance_type          = "t2.medium"
  count                  = "${var.aws_number}"
  subnet_id              = "${var.aws_subnet_id}"
  user_data              = "${file("user_data/config-guacamole.sh")}"
  iam_instance_profile   = "${var.aws_ip_assumeRole_name}"
  ami                    = "${lookup(var.aws_amis, var.aws_region)}"
  key_name               = "${var.aws_key_pair_auth_id}"
  vpc_security_group_ids = ["${var.aws_sg_id}","${aws_security_group.guacamole.id}"]

  root_block_device = {
    volume_size = 80
  }

  tags {
    Name = "guacamole-${count.index}"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

resource "aws_eip" "guacamole" {
  vpc      = true
  instance = "${aws_instance.guacamole.id}"
}

resource "aws_security_group" "guacamole" {
  name        = "terraform_evlab_guacamole"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  # novnc
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # novnc
  ingress {
    from_port   = 6080
    to_port     = 6080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
