# Create a VPC to launch our instances into
resource "aws_vpc" "evlab" {
  cidr_block           = "${lookup(var.cidr, "vpc.${var.aws_region}")}"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
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
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.evlab.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.evlab.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.gw.*.id, 0)}"
  depends_on    = ["aws_internet_gateway.gw"]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.evlab.id}"

  tags {
    Name = "Private route table"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

# Associate subnet public_subnet_eu_west_1a to public route table
resource "aws_route_table_association" "public_subnet_web_association" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.web.*.id, count.index)}"
  route_table_id = "${aws_vpc.evlab.main_route_table_id}"
}

resource "aws_route_table_association" "public_subnet_mgmt_association" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.mgmt.*.id, count.index)}"
  route_table_id = "${aws_vpc.evlab.main_route_table_id}"
}

resource "aws_route_table_association" "private_back_association" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.back.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_route_table_association" "private_exch_association" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.exch.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_route_table_association" "private_backup_association" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.backup.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

###########################################################################
# Network
###########################################################################

# Create a subnet to launch our instances into
resource "aws_subnet" "back" {
  vpc_id                  = "${aws_vpc.evlab.id}"
  count                   = "${length(var.azs)}"
  cidr_block              = "${element(var.subnet_back, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "backup" {
  vpc_id                  = "${aws_vpc.evlab.id}"
  count                   = "${length(var.azs)}"
  cidr_block              = "${element(var.subnet_backup, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false
}

# Create a subnet to launch our instances into
resource "aws_subnet" "mgmt" {
  vpc_id                  = "${aws_vpc.evlab.id}"
  cidr_block              = "${element(var.subnet_mgmt, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "exch" {
  vpc_id                  = "${aws_vpc.evlab.id}"
  count                   = "${length(var.azs)}"
  cidr_block              = "${element(var.subnet_exch, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "web" {
  vpc_id                  = "${aws_vpc.evlab.id}"
  count                   = "${length(var.azs)}"
  cidr_block              = "${element(var.subnet_web, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "gw" {
  vpc_id                  = "${aws_vpc.evlab.id}"
  count                   = "${length(var.azs)}"
  cidr_block              = "${element(var.subnet_gw, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false
}
