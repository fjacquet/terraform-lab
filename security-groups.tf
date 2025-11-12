# ============================================================================
# SECURITY GROUPS
# Common security groups for administrative access and domain services
# ============================================================================

# Windows administrative access (RDP, SSH, WinRM)
resource "aws_security_group" "rdp" {
  name        = "tf_ezlab_rdp"
  description = "Security group for Windows administrative access (RDP, SSH, WinRM)"
  vpc_id      = module.global.aws_vpc_id

  ingress {
    description = "Allow RDP from admin CIDR blocks"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }

  ingress {
    description = "Allow SSH from admin CIDR blocks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }

  ingress {
    description = "Allow WinRM (HTTP and HTTPS) from admin CIDR blocks"
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }

  dynamic "egress" {
    for_each = local.common_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "tf_ezlab_rdp"
    }
  )
}

# Unix/Linux administrative access (SSH)
resource "aws_security_group" "ssh" {
  name        = "tf_ezlab_lssh"
  description = "Security group for Unix/Linux administrative access (SSH)"
  vpc_id      = module.global.aws_vpc_id

  ingress {
    description = "Allow SSH from admin CIDR blocks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }

  ingress {
    description = "Allow Cockpit web console from VPC"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  dynamic "egress" {
    for_each = local.common_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "tf_ezlab_lssh"
    }
  )
}

# Active Directory domain member traffic
resource "aws_security_group" "domain_member" {
  name        = "tf_ezlab_domain_member"
  description = "Security group for Active Directory domain member traffic"
  vpc_id      = module.global.aws_vpc_id

  # ICMP ping
  ingress {
    description = "Allow ICMP ping from domain members"
    from_port   = 8
    to_port     = 8
    protocol    = "icmp"
    self        = true
  }

  # DNS (TCP and UDP)
  ingress {
    description = "Allow DNS TCP from domain members"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow DNS UDP from domain members"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    self        = true
  }

  # Kerberos (TCP and UDP)
  ingress {
    description = "Allow Kerberos TCP from domain members"
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow Kerberos UDP from domain members"
    from_port   = 88
    to_port     = 88
    protocol    = "udp"
    self        = true
  }

  # NTP
  ingress {
    description = "Allow NTP from domain members"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    self        = true
  }

  # RPC endpoint mapper
  ingress {
    description = "Allow RPC endpoint mapper from domain members"
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    self        = true
  }

  # LDAP (TCP and UDP)
  ingress {
    description = "Allow LDAP TCP from domain members"
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow LDAP UDP from domain members"
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    self        = true
  }

  # SMB/CIFS (TCP and UDP)
  ingress {
    description = "Allow SMB TCP from domain members"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow SMB UDP from domain members"
    from_port   = 445
    to_port     = 445
    protocol    = "udp"
    self        = true
  }

  # LDAPS
  ingress {
    description = "Allow LDAPS TCP from domain members"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Allow LDAPS UDP from domain members"
    from_port   = 636
    to_port     = 636
    protocol    = "udp"
    self        = true
  }

  # Kerberos password change
  ingress {
    description = "Allow Kerberos password change from domain members"
    from_port   = 749
    to_port     = 749
    protocol    = "udp"
    self        = true
  }

  # LDAP Global Catalog
  ingress {
    description = "Allow LDAP Global Catalog from domain members"
    from_port   = 3268
    to_port     = 3269
    protocol    = "tcp"
    self        = true
  }

  # WinRM
  ingress {
    description = "Allow WinRM from domain members"
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    self        = true
  }

  # Dynamic RPC ports
  ingress {
    description = "Allow dynamic RPC ports from domain members"
    from_port   = 49152
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # FusionInventory agent
  ingress {
    description = "Allow FusionInventory agent from VPC"
    from_port   = 62354
    to_port     = 62354
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    description      = "Allow FusionInventory agent from IPv6"
    from_port        = 62354
    to_port          = 62354
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  dynamic "egress" {
    for_each = local.common_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "tf_ezlab_domain_member"
    }
  )
}

# Simpana/Commvault backup client
# Created separately to avoid circular dependency (clients need this before simpana server exists)
resource "aws_security_group" "simpana_client" {
  name        = "tf_ezlab_simpana_client"
  description = "Security group for Simpana/Commvault backup clients"
  vpc_id      = module.global.aws_vpc_id

  # Simpana client-to-server communication
  ingress {
    description = "Simpana client services (CVD)"
    from_port   = 8400
    to_port     = 8403
    protocol    = "tcp"
    self        = true
  }

  # Simpana data transfer
  ingress {
    description = "Simpana data transfer"
    from_port   = 8600
    to_port     = 8699
    protocol    = "tcp"
    self        = true
  }

  # Simpana web console
  ingress {
    description = "Simpana web console"
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  dynamic "egress" {
    for_each = local.common_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "tf_ezlab_simpana_client"
    }
  )
}
