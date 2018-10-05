#-----------------------------------------------------------------------------
# Create a VPC and GW
#-----------------------------------------------------------------------------
resource "aws_vpc" "evlab" {
  cidr_block                       = "10.0.0.0/16"
  enable_dns_hostnames             = "true"
  enable_dns_support               = "true"
  assign_generated_ipv6_cidr_block = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.evlab.id}"
}

resource "aws_egress_only_internet_gateway" "egw6" {
  vpc_id = "${aws_vpc.evlab.id}"
}

#-----------------------------------------------------------------------------
# private Nat Gateways
#-----------------------------------------------------------------------------
resource "aws_eip" "natip" {
  count = "${length(var.azs)}"
  vpc   = true
}

resource "aws_nat_gateway" "natgw" {
  count = "${length(var.azs)}"

  allocation_id = "${element(aws_eip.natip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.gw.*.id, count.index)}"

  depends_on = ["aws_internet_gateway.gw"]

  tags {
    Name = "natgw-${count.index}"
  }
}

#-----------------------------------------------------------------------------
# Create public traffic 
#-----------------------------------------------------------------------------

resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.evlab.id}"

  route {
    ipv6_cidr_block = "::/0"
    egress_only_gateway_id = "${aws_egress_only_internet_gateway.egw6.id}"
    
  }

  route {
    cidr_block             = "0.0.0.0/0"
    gateway_id      = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "public-rt"
  }
}

resource "aws_subnet" "gw" {
  vpc_id                          = "${aws_vpc.evlab.id}"
  count                           = "${length(var.azs)}"
  cidr_block                      = "${cidrsubnet(aws_vpc.evlab.cidr_block,8,element(var.cidrbyte_gw, count.index))}"
  availability_zone               = "${element(var.azs, count.index)}"
  map_public_ip_on_launch         = true
  ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.evlab.ipv6_cidr_block,8,element(var.cidrbyte_gw, count.index))}"
  assign_ipv6_address_on_creation = true

  tags {
    Name = "subnet-gw-${count.index}"
  }
}

# Create a subnet to launch our instances into
resource "aws_subnet" "mgmt" {
  vpc_id                          = "${aws_vpc.evlab.id}"
  cidr_block                      = "${cidrsubnet(aws_vpc.evlab.cidr_block,8,element(var.cidrbyte_mgmt, count.index))}"
  availability_zone               = "${element(var.azs, count.index)}"
  map_public_ip_on_launch         = false
  ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.evlab.ipv6_cidr_block,8,element(var.cidrbyte_mgmt, count.index))}"
  assign_ipv6_address_on_creation = true

  tags {
    Name = "subnet-mgmt-${count.index}"
  }
}

resource "aws_route_table_association" "public_gw_association" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.gw.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

resource "aws_route_table_association" "public_subnet_mgmt_association" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.mgmt.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public-rt.*.id, count.index)}"
}

#-----------------------------------------------------------------------------
# Create private traffic 
#-----------------------------------------------------------------------------

# Create a subnet to launch our instances into
resource "aws_subnet" "back" {
  vpc_id                          = "${aws_vpc.evlab.id}"
  count                           = "${length(var.azs)}"
  cidr_block                      = "${cidrsubnet(aws_vpc.evlab.cidr_block,8,element(var.cidrbyte_back, count.index))}"
  availability_zone               = "${element(var.azs, count.index)}"
  map_public_ip_on_launch         = false
  ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.evlab.ipv6_cidr_block,8,element(var.cidrbyte_back, count.index))}"
  assign_ipv6_address_on_creation = true

  tags {
    Name = "subnet-back-${count.index}"
  }
}

resource "aws_subnet" "backup" {
  vpc_id                          = "${aws_vpc.evlab.id}"
  count                           = "${length(var.azs)}"
  cidr_block                      = "${cidrsubnet(aws_vpc.evlab.cidr_block,8,element(var.cidrbyte_backup, count.index))}"
  availability_zone               = "${element(var.azs, count.index)}"
  map_public_ip_on_launch         = false
  ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.evlab.ipv6_cidr_block,8,element(var.cidrbyte_backup, count.index))}"
  assign_ipv6_address_on_creation = true

  tags {
    Name = "subnet-backup-${count.index}"
  }
}

resource "aws_subnet" "exchange" {
  vpc_id                          = "${aws_vpc.evlab.id}"
  count                           = "${length(var.azs)}"
  cidr_block                      = "${cidrsubnet(aws_vpc.evlab.cidr_block,8,element(var.cidrbyte_exchange, count.index))}"
  availability_zone               = "${element(var.azs, count.index)}"
  map_public_ip_on_launch         = false
  ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.evlab.ipv6_cidr_block,8,element(var.cidrbyte_exchange, count.index))}"
  assign_ipv6_address_on_creation = true

  tags {
    Name = "subnet-exchange-${count.index}"
  }
}

resource "aws_subnet" "web" {
  vpc_id                          = "${aws_vpc.evlab.id}"
  count                           = "${length(var.azs)}"
  cidr_block                      = "${cidrsubnet(aws_vpc.evlab.cidr_block,8,element(var.cidrbyte_web, count.index))}"
  availability_zone               = "${element(var.azs, count.index)}"
  map_public_ip_on_launch         = true
  ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.evlab.ipv6_cidr_block,8,element(var.cidrbyte_web, count.index))}"
  assign_ipv6_address_on_creation = true

  tags {
    Name = "subnet-web-${count.index}"
  }
}

resource "aws_route_table" "private-rt" {
  count  = "${length(var.azs)}"
  vpc_id = "${aws_vpc.evlab.id}"

  tags {
    Name = "private-rt-${count.index}"
  }
}

resource "aws_route" "private" {
  count                  = "${length(var.azs)}"
  route_table_id         = "${element(aws_route_table.private-rt.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.natgw.*.id, count.index)}"
}

resource "aws_route" "private-v6" {
  count                       = "${length(var.azs)}"
  route_table_id              = "${element(aws_route_table.private-rt.*.id, count.index)}"
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = "${aws_egress_only_internet_gateway.egw6.id}"
}

resource "aws_route_table_association" "private_subnet_web_association" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.web.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private-rt.*.id, count.index)}"
}

resource "aws_route_table_association" "private_back_association" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.back.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private-rt.*.id, count.index)}"
}

resource "aws_route_table_association" "private_exchange_association" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.exchange.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private-rt.*.id, count.index)}"
}

resource "aws_route_table_association" "private_backup_association" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.backup.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private-rt.*.id, count.index)}"
}

#-----------------------------------------------------------------------------
# Create VPC endpoint
#-----------------------------------------------------------------------------
# Declare the end point to S3 (no cost)
resource "aws_vpc_endpoint" "private-s3" {
  vpc_id       = "${aws_vpc.evlab.id}"
  service_name = "com.amazonaws.eu-west-1.s3"
  policy       = "${file("./policy_json/vpc-policy-s3endpoint.json")}"
}
