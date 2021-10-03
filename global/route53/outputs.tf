output "dns_zone_id" {
  value = aws_route53_zone.ezlab.id
}
output "dns_public_zone_id" {
  value = data.aws_route53_zone.ezlab-public.id
}
