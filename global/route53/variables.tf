variable "aws_vpc_id" {
  description = "VPC ID for private hosted zone"
  type        = string
}

variable "dns_suffix" {
  description = "DNS domain name for the hosted zone"
  type        = string
}

variable "public_dns_id" {
  description = "Route 53 public hosted zone ID (optional)"
  type        = string
  default     = ""
}
