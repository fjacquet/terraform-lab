

module "global" {
  # dhcpops    = aws_vpc_dhcp_options.dns_resolver.id
  access_key    = var.access_key
  aws_number    = var.aws_number
  aws_region    = var.aws_region
  azs           = var.azs
  cidrbyte      = var.cidrbyte
  dns_suffix    = var.dns_suffix
  public_dns_id = var.public_dns_id
  key_name      = var.key_name
  public_key    = var.public_key
  secret_key    = var.secret_key
  source        = "./global"
}

module "unix" {
  # aws_amis               = var.aws_amis
  aws_disks_size           = var.aws_disks_size
  aws_iip_assumerole_name  = module.global.aws_iip_assumerole
  aws_key_pair_auth_id     = aws_key_pair.auth.id
  aws_number               = var.aws_number
  aws_region               = var.aws_region
  aws_sg_simpana_client_id = module.microsoft.aws_sg_simpana_client_id
  aws_subnet_back_id       = module.global.aws_subnet_back_id
  aws_subnet_backup_id     = module.global.aws_subnet_backup_id
  aws_subnet_mgmt_id       = module.global.aws_subnet_mgmt_id
  aws_subnet_web_id        = module.global.aws_subnet_web_id
  aws_vpc_id               = module.global.aws_vpc_id
  azs                      = var.azs
  cidrbyte                 = var.cidrbyte
  dns_suffix               = var.dns_suffix
  dns_zone_id              = module.global.dns_zone_id
  dns_public_zone_id       = var.public_dns_id
  source                   = "./unix"
  vpc_cidr                 = module.global.vpc_cidr
}

module "microsoft" {
  # aws_amis                = var.aws_amis
  aws_iip_assumerole_name = module.global.aws_iip_assumerole
  aws_key_pair_auth_id    = aws_key_pair.auth.id
  aws_number              = var.aws_number
  aws_region              = var.aws_region
  aws_sg_nbuclient_ids    = module.unix.aws_sg_nbuclient_ids
  aws_subnet_back_id      = module.global.aws_subnet_back_id
  aws_subnet_backup_id    = module.global.aws_subnet_backup_id
  aws_subnet_exchange_id  = module.global.aws_subnet_exchange_id
  aws_subnet_mgmt_id      = module.global.aws_subnet_mgmt_id
  aws_subnet_web_id       = module.global.aws_subnet_web_id
  aws_vpc_id              = module.global.aws_vpc_id
  azs                     = var.azs
  cidrbyte                = var.cidrbyte
  dns_suffix              = var.dns_suffix
  dns_zone_id             = module.global.dns_zone_id
  dns_public_zone_id      = var.public_dns_id
  source                  = "./microsoft"
  vpc_cidr                = module.global.vpc_cidr
}

# resource "aws_vpc_dhcp_options" "dns_resolver" {
#   ntp_servers          = [module.microsoft.dc_private_ip]
#   netbios_name_servers = [module.microsoft.dc_private_ip]
#   netbios_node_type    = 2
#   domain_name          = var.dns_suffix

#   domain_name_servers = [ module.microsoft.dc_private_ip,  "8.8.8.8" ]
# }
