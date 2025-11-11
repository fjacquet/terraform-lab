locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = "terraform-lab"
    ManagedBy   = "Terraform"
    Environment = "lab"
    Repository  = "github.com/fjacquet/terraform-lab"
  }

  # Admin CIDR blocks - use public access if enabled, otherwise use restricted blocks
  admin_cidr_blocks = var.enable_public_admin_access ? ["0.0.0.0/0"] : var.admin_cidr_blocks

  # Computed CIDR blocks for all subnet types
  # These are dynamically generated based on the number of availability zones
  cidr_blocks = {
    back = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["back${i + 1}.${var.aws_region}"])
    ]

    backup = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["backup${i + 1}.${var.aws_region}"])
    ]

    web = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["web${i + 1}.${var.aws_region}"])
    ]

    exchange = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["exchange${i + 1}.${var.aws_region}"])
    ]

    mgmt = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["mgmt${i + 1}.${var.aws_region}"])
    ]

    sql = [
      for i in range(length(var.azs)) :
      cidrsubnet(module.global.vpc_cidr, 8, var.cidrbyte["sql${i + 1}.${var.aws_region}"])
    ]
  }

  # Common instance metadata options (IMDSv2 enforcement)
  common_instance_metadata_options = {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  # Common instance root block device configuration
  common_instance_root_block_device = {
    encrypted = true
  }

  # Common egress rules for all security groups
  common_egress_rules = [
    {
      description      = "Allow all outbound IPv4 traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
    },
    {
      description      = "Allow all outbound IPv6 traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  # ============================================================================
  # UNIFIED SERVICE CONFIGURATION
  # Single source of truth for ALL services (Windows + Unix)
  # ============================================================================

  # Windows Services Configuration
  windows_services = {
    # Active Directory Domain Services - Primary domain controller
    adds = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      # Service creates its own security group with DC-specific rules
      creates_sg       = true
      # Requires domain-member security group reference
      needs_domain_sg  = true
    }

    # Active Directory Federation Services - SSO and federation
    adfs = {
      instance_type    = "t3.medium"
      subnet_type      = "web"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      needs_dc_sg      = true
    }

    # DHCP Server - Dynamic IP address management
    dhcp = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
    }

    # DirectAccess - Remote access VPN solution
    da = {
      instance_type    = "t3.medium"
      subnet_type      = "mgmt"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      # DA uses web CIDR blocks for routing
      cidr_override    = "web"
    }

    # Exchange Server - Email and collaboration
    exchange = {
      instance_type    = "t3.large"
      subnet_type      = "exchange"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
    }

    # File Server - SMB/CIFS file sharing
    fs = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      needs_domain_sg  = true
    }

    # IP Address Management - IPAM server
    ipam = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
    }

    # Management Server - General Windows management
    mgmt = {
      instance_type    = "t3.medium"
      subnet_type      = "mgmt"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = true
      creates_sg       = false
      # mgmt doesn't use cidr parameter
      skip_cidr        = true
    }

    # Network Policy Server - RADIUS authentication
    nps = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
    }

    # Remote Desktop Session Host - Terminal services
    rdsh = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      needs_domain_sg  = true
    }

    # SharePoint Server - Collaboration platform
    sharepoint = {
      instance_type    = "t3.medium"
      subnet_type      = "web"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
    }

    # SQL Server - Database server
    sql = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "sql2019"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      # SQL uses sql CIDR blocks
      cidr_override    = "sql"
    }

    # Commvault Simpana - Backup server
    simpana = {
      instance_type    = "t3.medium"
      subnet_type      = "backup"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      # Simpana uses back CIDR blocks
      cidr_override    = "back"
      # Simpana doesn't include its own client SG in the list
      skip_own_sg      = true
    }

    # Scale-Out File Server - Clustered file services
    sofs = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      needs_domain_sg  = true
    }

    # Windows Admin Center - Web-based management
    wac = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      # WAC uses mgmt CIDR blocks
      cidr_override    = "mgmt"
    }

    # Windows Deployment Services - OS deployment
    wds = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      # WDS uses backup CIDR blocks
      cidr_override    = "backup"
    }

    # Windows Server Update Services - Patch management
    wsus = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      # WSUS uses backup CIDR blocks
      cidr_override    = "backup"
    }
  }

  # Unix/Linux Services Configuration
  unix_services = {
    # Apache Guacamole - Clientless remote desktop gateway (bastion host)
    guacamole = {
      instance_type    = "t3.medium"
      subnet_type      = "mgmt"
      os_type          = "debian"
      ami_type         = "debian"
      user_data        = "user_data/config-linux.sh"
      root_volume_size = 80
      has_public_dns   = true
      creates_sg       = true
      # Guacamole doesn't use cidr parameter
      skip_cidr        = true
      # Additional public DNS records for bastion
      extra_dns_names  = ["bastion"]
    }

    # GLPI - IT asset management and helpdesk
    glpi = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "debian"
      ami_type         = "debian"
      user_data        = "user_data/config-linux.sh"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      skip_cidr        = true
    }

    # HashiCorp Vault - Secrets management
    vault = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "debian"
      ami_type         = "debian"
      user_data        = "user_data/config-linux.sh"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      skip_cidr        = true
    }

    # Veritas NetBackup - Enterprise backup solution
    nbu = {
      instance_type    = "t3.medium"
      subnet_type      = "backup"
      os_type          = "rhel"
      ami_type         = "rhel9"
      user_data        = "user_data/config-linux.sh"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = false
      # NBU has additional disk volumes
      extra_volumes = {
        nbu_backups = 500
        nbu_openv   = 50
      }
    }

    # Oracle Database - Enterprise database
    oracle = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "rhel"
      ami_type         = "rhel9"
      user_data        = "user_data/config-linux.sh"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      # Oracle needs NBU client SG
      needs_nbu_sg     = true
    }

    # Redis - In-memory data store
    redis = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "debian"
      ami_type         = "debian"
      user_data        = "user_data/config-linux.sh"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = true
      skip_cidr        = true
    }

    # FreeBSD - BSD Unix system
    bsd = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "bsd"
      ami_type         = "bsd"
      user_data        = "user_data/config-linux.sh"
      root_volume_size = 30
      has_public_dns   = false
      creates_sg       = false
      skip_cidr        = true
    }
  }

  # PKI Services - Special handling for multiple instance types
  # ADCS module handles 4 different PKI roles
  pki_services = {
    "pki-rca" = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      pki_role         = "rca"
    }
    "pki-ica" = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      pki_role         = "ica"
    }
    "pki-crl" = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      pki_role         = "crl"
    }
    "pki-ndes" = {
      instance_type    = "t3.medium"
      subnet_type      = "back"
      os_type          = "windows"
      ami_type         = "windows2022"
      user_data        = "user_data/config-win.ps1"
      root_volume_size = 30
      has_public_dns   = false
      pki_role         = "ndes"
    }
  }

  # Combined services map for easy iteration
  all_services = merge(local.windows_services, local.unix_services)
}
