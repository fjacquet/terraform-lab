resource "aws_instance" "nbumaster" {
  instance_type        = "m4.xlarge"
  count                = "${var.aws_number}"
  availability_zone    = "${element(var.azs, count.index)}"
  ami                  = "${var.aws_ami}"
  key_name             = "${var.aws_key_pair_auth_id}"
  ebs_optimized        = "true"
  subnet_id            = "${var.aws_subnet_id}"
  user_data            = "${file("user_data/config-nbu.sh")}"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"

  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
  ]

  root_block_device = {
    volume_size = 80
  }

  tags {
    Name = "nbu-${count.index}"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

resource "aws_volume_attachment" "ebs_openv" {
  device_name = "/dev/xvdb"
  count       = "${var.aws_number}"
  volume_id   = "${element(aws_ebs_volume.openv.*.id, count.index)}"
  instance_id = "${element(aws_instance.nbumaster.*.id, count.index)}"
}

resource "aws_ebs_volume" "openv" {
  availability_zone = "${element(var.azs, count.index)}"
  count             = "${var.aws_number}"
  type              = "gp2"
  size              = "${var.aws_size_nbu_openv}"
}

resource "aws_volume_attachment" "ebs_backups" {
  device_name = "/dev/xvdc"
  count       = "${var.aws_number}"
  volume_id   = "${element(aws_ebs_volume.backups.*.id, count.index)}"
  instance_id = "${element(aws_instance.nbumaster.*.id, count.index)}"
}

resource "aws_ebs_volume" "backups" {
  count             = "${var.aws_number}"
  availability_zone = "${element(var.azs, count.index)}"
  type              = "gp2"
  size              = "${var.aws_size_nbu_backups}"
}

resource "aws_security_group" "master" {
  name        = "tf_evlab_master"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  # pbx for clients
  ingress {
    from_port   = 1556
    to_port     = 1556
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # novnc
  ingress {
    from_port   = 6080
    to_port     = 6080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # vnetd
  ingress {
    from_port   = 13724
    to_port     = 13724
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # at port
  ingress {
    from_port   = 2821
    to_port     = 2821
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # auth-port
  ingress {
    from_port   = 4032
    to_port     = 4032
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # spad port
  ingress {
    from_port   = 10102
    to_port     = 10102
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # spoold port
  ingress {
    from_port   = 10082
    to_port     = 10082
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # spa port
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # portmapper nfs port
  ingress {
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # portmapper nfs port
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # portmapper nfs port
  ingress {
    from_port   = 29588
    to_port     = 29588
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # nbfsd nfs port
  ingress {
    from_port   = 7394
    to_port     = 7394
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr, count.index)}"]
  }

  # access from media/master
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

resource "aws_security_group" "client" {
  name        = "tf_evlab_client"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  # access from media/master
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.master.id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
