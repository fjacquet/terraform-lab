# Create a VPC to launch our instances into
resource "aws_vpc" "evlab" {
  cidr_block           = "${var.cidr_vpc}"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Declare the data source
resource "aws_vpc_endpoint" "private-s3" {
  vpc_id       = "${aws_vpc.evlab.id}"
  service_name = "com.amazonaws.eu-west-1.s3"

  policy = <<POLICY
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
POLICY
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "evlab" {
  vpc_id = "${aws_vpc.evlab.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.evlab.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.evlab.id}"
}

###########################################################################
# Network
###########################################################################

# Create a subnet to launch our instances into
resource "aws_subnet" "back" {
  vpc_id                  = "${aws_vpc.evlab.id}"
  count                   = "${length(var.azs)}"
  cidr_block              = "${element(var.cidr_back, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false
}

# Create a subnet to launch our instances into
resource "aws_subnet" "mgmt" {
  vpc_id                  = "${aws_vpc.evlab.id}"
  cidr_block              = "${element(var.cidr_mgmt, count.index)}"
  availability_zone       = "${element(var.azs, 0)}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "exch" {
  vpc_id                  = "${aws_vpc.evlab.id}"
  count                   = "${length(var.azs)}"
  cidr_block              = "${element(var.cidr_exch, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "web" {
  vpc_id                  = "${aws_vpc.evlab.id}"
  count                   = "${length(var.azs)}"
  cidr_block              = "${element(var.cidr_web, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false
}
