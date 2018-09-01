resource "aws_instance" "sql" {
  ami                  = "${var.aws_ami}"
  availability_zone    = "${element(var.azs, count.index)}"
  count                = "${var.aws_number}"
  ebs_optimized        = "true"
  iam_instance_profile = "${var.aws_iip_assumerole_name}"
  instance_type        = "m4.large"
  key_name             = "${var.aws_key_pair_auth_id}"
  subnet_id            = "${var.aws_subnet_id}"
  user_data            = "${file("user_data/config-sql.ps1")}"

  lifecycle {
    ignore_changes = ["user_data"]
  }

  tags {
    Name = "sql-${count.index}"
  }

  # Our Security group to allow RDP access
  vpc_security_group_ids = [
    "${var.aws_sg_ids}",
  ]
}

resource "aws_security_group" "sql" {
  name        = "tf_evlab_sql"
  description = "Used in the terraform"
  vpc_id      = "${var.aws_vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 1433
    to_port     = 1433
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
