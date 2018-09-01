resource "aws_instance" "oracle" {
  instance_type          = "m4.xlarge"
  count                  = "${var.aws_number}"
  availability_zone      = "${element(var.azs, count.index)}"
  iam_instance_profile   = "${var.aws_iip_assumerole_name}"
  ami                    = "${var.aws_ami}"
  key_name               = "${var.aws_key_pair_auth_id}"
  ebs_optimized          = "true"
  subnet_id              = "${var.aws_subnet_id}"
  user_data              = "${file("user_data/config-ora.sh")}"
  vpc_security_group_ids = ["${var.aws_sg_ids}"]

  lifecycle {
    ignore_changes = ["user_data"]
  }

  tags {
    Name = "oracle-${count.index}"
  }
}

resource "aws_volume_attachment" "ebs_u01" {
  device_name       = "/dev/xvdb"
  count             = "${var.aws_number}"
  availability_zone = "${element(var.azs, count.index)}"
  volume_id         = "${element(aws_ebs_volume.oracle_u01.*.id, count.index)}"
  instance_id       = "${element(aws_instance.oracle.*.id, count.index)}"
}

resource "aws_ebs_volume" "oracle_u01" {
  count             = "${var.aws_number}"
  availability_zone = "${element(var.azs, count.index)}"
  type              = "gp2"
  size              = "${var.aws_size_oracle_u01}"
}

resource "aws_security_group" "oracle" {
  name        = "tf_evlab_oracle"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  # listener for clients
  ingress {
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
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
