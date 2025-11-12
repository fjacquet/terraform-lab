# ============================================================================
# UNIFIED SERVICE MODULE VARIABLES
# ============================================================================

variable "service_name" {
  description = "Name of the service (e.g., 'adds', 'guacamole', 'exchange')"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to create for this service"
  type        = number
}

variable "config" {
  description = "Service configuration from locals.all_services"
  type = object({
    instance_type    = string
    subnet_type      = string
    os_type          = string
    ami_type         = string
    user_data        = string
    root_volume_size = number
    has_public_dns   = bool
    creates_sg       = optional(bool, false)
    needs_domain_sg  = optional(bool, false)
    needs_dc_sg      = optional(bool, false)
    needs_nbu_sg     = optional(bool, false)
    skip_cidr        = optional(bool, false)
    skip_own_sg      = optional(bool, false)
    cidr_override    = optional(string, null)
    extra_dns_names  = optional(list(string), [])
    extra_volumes    = optional(map(number), {})
    ingress_rules = optional(list(object({
      description      = string
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string), null)
      ipv6_cidr_blocks = optional(list(string), null)
      self             = optional(bool, null)
      security_groups  = optional(list(string), null)
    })), [])
  })
}

# Common configuration passed from root
variable "ami_ids" {
  description = "Map of AMI types to AMI IDs"
  type        = map(string)
}

variable "common_metadata_options" {
  description = "Common metadata options for EC2 instances (IMDSv2 enforcement)"
  type = object({
    http_tokens                 = string
    http_put_response_hop_limit = number
    http_endpoint               = string
  })
}

variable "common_root_block_device" {
  description = "Common root block device configuration for EC2 instances"
  type = object({
    encrypted = bool
  })
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnets" {
  description = "Map of subnet types to subnet ID lists"
  type = object({
    back     = list(string)
    web      = list(string)
    mgmt     = list(string)
    exchange = list(string)
    backup   = list(string)
  })
}

variable "cidr_blocks" {
  description = "Map of subnet types to CIDR block lists"
  type = object({
    back     = list(string)
    web      = list(string)
    mgmt     = list(string)
    exchange = list(string)
    backup   = list(string)
    sql      = list(string)
  })
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

variable "key_pair_id" {
  description = "SSH key pair ID for EC2 instances"
  type        = string
}

variable "dns_zone_id" {
  description = "Route53 private hosted zone ID"
  type        = string
}

variable "dns_public_zone_id" {
  description = "Route53 public hosted zone ID"
  type        = string
}

variable "dns_suffix" {
  description = "DNS suffix for Route53 records"
  type        = string
}

variable "security_groups" {
  description = "Map of common security group IDs"
  type = object({
    rdp            = string
    ssh            = string
    domain_member  = string
    simpana_client = string
  })
}

variable "nbu_client_sg_ids" {
  description = "NetBackup client security group IDs"
  type        = list(string)
  default     = []
}
