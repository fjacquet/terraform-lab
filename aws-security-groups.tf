resource "aws_security_group" "ssh" {
  name        = "terraform_evlab_lssh"
  description = "Used in the terraform"
  vpc_id      = "${module.global.aws_vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
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

# A security group for basic windows box
resource "aws_security_group" "rdp" {
  name        = "terraform_evlab_rdp"
  description = "Used in the terraform"
  vpc_id      = "${module.global.aws_vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
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

resource "aws_security_group" "cvltclient" {
  name        = "terraform_evlab_cvltclient"
  description = "Used in the terraform"
  vpc_id      = "${module.global.aws_vpc_id}"

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
    cidr_blocks = ["${element(var.cidr_back, count.index)}"]
  }

  # Simpana access from subnet
  ingress {
    from_port   = 8400
    to_port     = 8403
    protocol    = "tcp"
    cidr_blocks = ["${element(var.cidr_back, count.index)}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nbuclient" {
  name        = "terraform_evlab_nbuclient"
  description = "Used in the terraform"
  vpc_id      = "${module.global.aws_vpc_id}"

  # access from media/master
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.nbumaster.id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
