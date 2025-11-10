output "dns_zone_id" {
  value = aws_route53_zone.ezlab.id
}

output "dns_public_zone_id" {
  value = length(data.aws_route53_zone.ezlab-public) > 0 ? data.aws_route53_zone.ezlab-public[0].id : ""
}
