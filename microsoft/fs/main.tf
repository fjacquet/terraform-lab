resource "aws_instance" "fs" {
  ami                  = "${var.aws_ami}"
  availability_zone    = "${element(var.azs, count.index)}"
  count                = "${var.aws_number}"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"
  instance_type        = "t2.medium"
  key_name             = "${var.aws_key_pair_auth_id}"
  subnet_id            = "${element(var.aws_subnet_id, count.index)}"
  user_data            = "${file("user_data/config-fs.ps1")}"

  tags {
    Name = "fs-${count.index}"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
  ]
}

resource "aws_volume_attachment" "ebs_fs_d" {
  device_name = "/dev/xvdb"
  count       = "${var.aws_number}"
  volume_id   = "${element(aws_ebs_volume.fs_d.*.id, count.index)}"
  instance_id = "${element(aws_instance.fs.*.id, count.index)}"
}

resource "aws_ebs_volume" "fs_d" {
  count             = "${var.aws_number}"
  availability_zone = "${element(var.azs, count.index)}"
  size              = 100
  type              = "gp2"
}

resource "aws_security_group" "fs" {
  name        = "fs"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    description     = "file Server"
    from_port       = 445
    to_port         = 445
    protocol        = "tcp"
    security_groups = ["${var.aws_sg_domain_members}"]
  }

  ingress {
    description = "ping"
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
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
