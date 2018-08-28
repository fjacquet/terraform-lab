resource "aws_instance" "simpana" {
  instance_type        = "m4.xlarge"
  count                = "${var.aws_number}"
  availability_zone    = "${element(var.azs, count.index)}"
  ami                  = "${lookup(var.aws_amis, var.aws_region)}"
  iam_instance_profile = "${var.aws_ip_assumeRole_name}"
  key_name             = "${var.aws_key_pair_auth_id}"
  ebs_optimized        = "true"
  user_data            = "${file("user_data/config-win.ps1")}"
  subnet_id            = "${var.aws_subnet_id}"

  vpc_security_group_ids = [
    "${var.aws_sg_simpana_id}",
    "${aws_security_group.simpana.id}",
  ]

  root_block_device = {
    volume_size = 80
  }

  tags {
    Name = "simpana-${count.index}"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

resource "aws_volume_attachment" "ebs_simpana_d" {
  device_name       = "/dev/xvdb"
  count             = "${var.aws_simpana_number}"
  availability_zone = "${element(var.azs, count.index)}"
  volume_id         = "${element(aws_ebs_volume.simpana_d.*.id, count.index)}"
  instance_id       = "${element(aws_instance.simpana.*.id, count.index)}"
}

resource "aws_ebs_volume" "simpana_d" {
  count             = "${var.aws_simpana_number}"
  availability_zone = "${element(var.azs, count.index)}"
  size              = 100
  type              = "gp2"
}

resource "aws_security_group" "simpana" {
  name        = "terraform_evlab_simpana"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # netbios access from subnet
  ingress {
    from_port   = 137
    to_port     = 137
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # Simpana access from subnet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
