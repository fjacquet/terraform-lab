# ============================================================================
# ROOT MODULE OUTPUTS (REFACTORED)
# Maintains backward compatibility with existing output structure
# ============================================================================

# ============================================================================
# WINDOWS SERVICE OUTPUTS
# ============================================================================

output "dc_private_ip" {
  description = "DC DNS IPs"
  value       = try(module.services["adds"].private_ips, [])
}

output "aws_sg_da_id" {
  description = "DirectAccess security group ID"
  value       = try(module.services["da"].security_group_id, "")
}

output "aws_sg_dc_id" {
  description = "Domain Controller security group ID"
  value       = try(module.services["adds"].security_group_id, "")
}

output "aws_sg_dhcp_id" {
  description = "DHCP security group ID"
  value       = try(module.services["dhcp"].security_group_id, "")
}

output "aws_sg_exchange_id" {
  description = "Exchange security group ID"
  value       = try(module.services["exchange"].security_group_id, "")
}

output "aws_sg_fs_id" {
  description = "File Server security group ID"
  value       = try(module.services["fs"].security_group_id, "")
}

output "aws_sg_ipam_id" {
  description = "IPAM security group ID"
  value       = try(module.services["ipam"].security_group_id, "")
}

# PKI security groups (these would need special handling in the unified module)
# For now, these will be empty until PKI is migrated
output "aws_sg_pki-crl_ids" {
  description = "PKI CRL security group IDs"
  value       = []
}

output "aws_sg_pki-ica_ids" {
  description = "PKI ICA security group IDs"
  value       = []
}

output "aws_sg_pki-rca_ids" {
  description = "PKI RCA security group IDs"
  value       = []
}

output "aws_sg_sharepoint_id" {
  description = "SharePoint security group ID"
  value       = try(module.services["sharepoint"].security_group_id, "")
}

output "aws_sg_simpana_master_id" {
  description = "Simpana master security group ID"
  value       = try(module.services["simpana"].security_group_id, "")
}

output "aws_sg_simpana_client_id" {
  description = "Simpana client security group ID"
  value       = try(module.services["simpana"].security_group_id, "")
}

output "aws_sg_rdp_id" {
  description = "RDP security group ID"
  value       = aws_security_group.rdp.id
}

output "aws_sg_sql_id" {
  description = "SQL Server security group ID"
  value       = try(module.services["sql"].security_group_id, "")
}

# ============================================================================
# UNIX SERVICE OUTPUTS
# ============================================================================

output "aws_sg_oracle_id" {
  description = "Oracle security group ID"
  value       = try(module.services["oracle"].security_group_id, "")
}

output "aws_sg_nbumaster_ids" {
  description = "NetBackup master security group IDs"
  value       = try([module.services["nbu"].security_group_id], [])
}

output "aws_sg_nbuclient_ids" {
  description = "NetBackup client security group IDs"
  value       = try([module.services["nbu"].security_group_id], [])
}

output "aws_sg_guacamole_id" {
  description = "Guacamole security group ID"
  value       = try(module.services["guacamole"].security_group_id, "")
}

output "aws_sg_ssh_id" {
  description = "SSH security group ID"
  value       = aws_security_group.ssh.id
}

# ============================================================================
# ADDITIONAL OUTPUTS FOR VISIBILITY
# ============================================================================

output "deployed_services" {
  description = "Map of deployed services with their instance counts"
  value = {
    for k, v in module.services : k => {
      instance_count = length(v.instance_ids)
      instance_ids   = v.instance_ids
      private_ips    = v.private_ips
      dns_names      = v.dns_names
    }
  }
}

output "service_security_groups" {
  description = "Map of service names to their security group IDs"
  value = {
    for k, v in module.services : k => v.security_group_id
    if v.security_group_id != null
  }
}
