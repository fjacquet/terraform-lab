#-----------------------------------------------------------------------------
# Create a VPC and GW
#-----------------------------------------------------------------------------
resource "aws_vpc" "ezlab" {
  cidr_block                       = "10.0.0.0/16"
  enable_dns_hostnames             = "true"
  enable_dns_support               = "true"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name        = "ezlab-vpc"
    Environment = "lab"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ezlab.id

  tags = {
    Name        = "ezlab-igw"
    Environment = "lab"
  }
}

resource "aws_egress_only_internet_gateway" "egw6" {
  vpc_id = aws_vpc.ezlab.id

  tags = {
    Name        = "ezlab-egw6"
    Environment = "lab"
  }
}

#-----------------------------------------------------------------------------
# private Nat Gateways
#-----------------------------------------------------------------------------
resource "aws_eip" "natip" {
  count  = length(var.azs)
  domain = "vpc"

  tags = {
    Name        = "natip-${count.index}"
    Environment = "lab"
  }
}

resource "aws_nat_gateway" "natgw" {
  count = length(var.azs)

  // allocation_id = element(aws_eip.natip.*.id, count.index)
  // subnet_id     = element(aws_subnet.gw.*.id, count.index)
  allocation_id = aws_eip.natip[count.index].id
  subnet_id     = aws_subnet.gw[count.index].id

  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name        = "natgw-${count.index}"
    Environment = "lab"
  }
}

#-----------------------------------------------------------------------------
# Create public traffic
#-----------------------------------------------------------------------------

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.ezlab.id

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.egw6.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "public-rt"
    Environment = "lab"
  }
}

resource "aws_subnet" "gw" {
  assign_ipv6_address_on_creation = true
  availability_zone               = element(var.azs, count.index)
  cidr_block                      = cidrsubnet(aws_vpc.ezlab.cidr_block, 8, element(var.cidrbyte_gw, count.index), )
  count                           = length(var.azs)
  map_public_ip_on_launch         = true
  vpc_id                          = aws_vpc.ezlab.id

  ipv6_cidr_block = cidrsubnet(
    aws_vpc.ezlab.ipv6_cidr_block,
    8,
    element(var.cidrbyte_gw, count.index),
  )

  tags = {
    Name        = "subnet-gw-${count.index}"
    Environment = "lab"
  }
}

# Create a subnet to launch our instances into
resource "aws_subnet" "mgmt" {
  assign_ipv6_address_on_creation = true
  availability_zone               = element(var.azs, count.index)
  cidr_block                      = cidrsubnet(aws_vpc.ezlab.cidr_block, 8, element(var.cidrbyte_mgmt, count.index), )
  count                           = 1
  map_public_ip_on_launch         = true
  vpc_id                          = aws_vpc.ezlab.id
  ipv6_cidr_block = cidrsubnet(
    aws_vpc.ezlab.ipv6_cidr_block,
    8,
    element(var.cidrbyte_mgmt, count.index),
  )

  tags = {
    Name        = "subnet-mgmt-${count.index}"
    Environment = "lab"
  }
}

resource "aws_route_table_association" "public_subnet_gw_association" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.gw.*.id, count.index)
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public_subnet_mgmt_association" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.mgmt.*.id, count.index)
  route_table_id = aws_route_table.public-rt.id
}

#-----------------------------------------------------------------------------
# Create private traffic
#-----------------------------------------------------------------------------

# Create a subnet to launch our instances into
resource "aws_subnet" "back" {
  assign_ipv6_address_on_creation = true
  availability_zone               = element(var.azs, count.index)
  cidr_block                      = cidrsubnet(aws_vpc.ezlab.cidr_block, 8, element(var.cidrbyte_back, count.index), )
  count                           = length(var.azs)
  map_public_ip_on_launch         = false
  vpc_id                          = aws_vpc.ezlab.id
  ipv6_cidr_block = cidrsubnet(
    aws_vpc.ezlab.ipv6_cidr_block,
    8,
    element(var.cidrbyte_back, count.index),
  )
  tags = {
    Name        = "subnet-back-${count.index}"
    Environment = "lab"
  }
}

resource "aws_subnet" "backup" {
  vpc_id = aws_vpc.ezlab.id
  count  = length(var.azs)
  cidr_block = cidrsubnet(
    aws_vpc.ezlab.cidr_block,
    8,
    element(var.cidrbyte_backup, count.index),
  )
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false
  ipv6_cidr_block = cidrsubnet(
    aws_vpc.ezlab.ipv6_cidr_block,
    8,
    element(var.cidrbyte_backup, count.index),
  )
  assign_ipv6_address_on_creation = true

  tags = {
    Name        = "subnet-backup-${count.index}"
    Environment = "lab"
  }
}

resource "aws_subnet" "exchange" {
  vpc_id = aws_vpc.ezlab.id
  count  = length(var.azs)
  cidr_block = cidrsubnet(
    aws_vpc.ezlab.cidr_block,
    8,
    element(var.cidrbyte_exchange, count.index),
  )
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false
  ipv6_cidr_block = cidrsubnet(
    aws_vpc.ezlab.ipv6_cidr_block,
    8,
    element(var.cidrbyte_exchange, count.index),
  )
  assign_ipv6_address_on_creation = true

  tags = {
    Name        = "subnet-exchange-${count.index}"
    Environment = "lab"
  }
}

resource "aws_subnet" "web" {
  vpc_id                          = aws_vpc.ezlab.id
  count                           = length(var.azs)
  availability_zone               = element(var.azs, count.index)
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true
  cidr_block = cidrsubnet(
    aws_vpc.ezlab.cidr_block,
    8,
    element(var.cidrbyte_web, count.index),
  )
  ipv6_cidr_block = cidrsubnet(
    aws_vpc.ezlab.ipv6_cidr_block,
    8,
    element(var.cidrbyte_web, count.index),
  )

  tags = {
    Name        = "subnet-web-${count.index}"
    Environment = "lab"
  }
}

resource "aws_route_table" "private-rt" {
  count  = length(var.azs)
  vpc_id = aws_vpc.ezlab.id

  tags = {
    Name        = "private-rt-${count.index}"
    Environment = "lab"
  }
}

resource "aws_route" "private" {
  count                  = length(var.azs)
  route_table_id         = element(aws_route_table.private-rt.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw.*.id, count.index)
}

resource "aws_route" "private-v6" {
  count                       = length(var.azs)
  route_table_id              = element(aws_route_table.private-rt.*.id, count.index)
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.egw6.id
}

resource "aws_route_table_association" "private_subnet_web_association" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.web.*.id, count.index)
  route_table_id = element(aws_route_table.private-rt.*.id, count.index)
}

resource "aws_route_table_association" "private_back_association" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.back.*.id, count.index)
  route_table_id = element(aws_route_table.private-rt.*.id, count.index)
}

resource "aws_route_table_association" "private_exchange_association" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.exchange.*.id, count.index)
  route_table_id = element(aws_route_table.private-rt.*.id, count.index)
}

resource "aws_route_table_association" "private_backup_association" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.backup.*.id, count.index)
  route_table_id = element(aws_route_table.private-rt.*.id, count.index)
}

#-----------------------------------------------------------------------------
# Create VPC endpoints
#-----------------------------------------------------------------------------

# Security group for VPC interface endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "tf_ezlab_vpc_endpoints"
  description = "Security group for VPC interface endpoints"
  vpc_id      = aws_vpc.ezlab.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.ezlab.cidr_block]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "vpc-endpoints-sg"
    Environment = "lab"
  }
}

# S3 Gateway endpoint (no cost)
resource "aws_vpc_endpoint" "private-s3" {
  vpc_id       = aws_vpc.ezlab.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  policy       = file("${path.root}/policy_json/vpc-policy-s3endpoint.json")

  tags = {
    Name        = "s3-endpoint"
    Environment = "lab"
  }
}

# SSM endpoint for Systems Manager
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.ezlab.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.back[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "ssm-endpoint"
    Environment = "lab"
  }
}

# EC2 Messages endpoint for Systems Manager
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.ezlab.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.back[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "ec2messages-endpoint"
    Environment = "lab"
  }
}

# SSM Messages endpoint for Systems Manager
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.ezlab.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.back[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "ssmmessages-endpoint"
    Environment = "lab"
  }
}

# Secrets Manager endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.ezlab.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.back[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "secretsmanager-endpoint"
    Environment = "lab"
  }
}
