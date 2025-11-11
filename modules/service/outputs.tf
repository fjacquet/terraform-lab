# ============================================================================
# UNIFIED SERVICE MODULE OUTPUTS
# ============================================================================

output "instance_ids" {
  description = "List of EC2 instance IDs for this service"
  value       = aws_instance.service[*].id
}

output "private_ips" {
  description = "List of private IP addresses for this service"
  value       = aws_instance.service[*].private_ip
}

output "public_ips" {
  description = "List of public IP addresses for this service (if applicable)"
  value       = aws_instance.service[*].public_ip
}

output "security_group_id" {
  description = "Security group ID created by this service (if applicable)"
  value       = lookup(var.config, "creates_sg", false) ? aws_security_group.service[0].id : null
}

output "dns_names" {
  description = "List of private DNS names for this service"
  value       = aws_route53_record.private[*].fqdn
}

output "public_dns_names" {
  description = "List of public DNS names for this service (if applicable)"
  value       = lookup(var.config, "has_public_dns", false) ? aws_route53_record.public[*].fqdn : []
}
