# Global Infrastructure Module

## Overview

The global module provisions core AWS infrastructure components that are shared across all services in the terraform-lab environment. This includes VPC networking, IAM roles, DNS zones, and DynamoDB tables for state management.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Submodules

This module orchestrates the following submodules:

- **vpc**: Virtual Private Cloud with multi-tier subnet architecture
- **iam**: IAM roles and instance profiles for EC2 instances
- **route53**: Private and public DNS hosted zones
- **dynamodb**: DynamoDB tables for Terraform state locking
- **demand**: On-demand capacity reservations

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access_key | AWS access key (prefer IAM roles or AWS SSO) | `string` | n/a | yes |
| secret_key | AWS secret key (prefer IAM roles or AWS SSO) | `string` | n/a | yes |
| aws_region | AWS region for infrastructure deployment | `string` | n/a | yes |
| public_key | SSH public key for EC2 instance access | `string` | n/a | yes |
| key_name | Name for the AWS key pair | `string` | n/a | yes |
| azs | List of AWS availability zones for resource distribution | `list(string)` | n/a | yes |
| cidrbyte | Map of third octet values for subnet CIDR blocks | `map(string)` | n/a | yes |
| dns_suffix | DNS domain name for the hosted zone | `string` | n/a | yes |
| public_dns_id | Route 53 public hosted zone ID (optional) | `string` | n/a | yes |
| aws_number | Map of instance counts per service type | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws_iip_assumerole | IAM instance profile name for EC2 instances |
| aws_vpc_id | VPC ID |
| vpc_cidr | VPC CIDR block |
| dns_zone_id | Route 53 private hosted zone ID |
| dns_public_zone_id | Route 53 public hosted zone ID |
| aws_subnet_back_id | List of backend subnet IDs |
| aws_subnet_backup_id | List of backup subnet IDs |
| aws_subnet_web_id | List of web tier subnet IDs |
| aws_subnet_exchange_id | List of Exchange subnet IDs |
| aws_subnet_mgmt_id | List of management subnet IDs |

## Usage Example

```hcl
module "global" {
  source = "./global"
  
  access_key    = var.access_key
  secret_key    = var.secret_key
  aws_region    = "us-east-1"
  public_key    = var.public_key
  key_name      = "lab-key"
  azs           = ["us-east-1a", "us-east-1b", "us-east-1c"]
  dns_suffix    = "ez-lab.xyz"
  public_dns_id = "Z1234567890ABC"
  
  cidrbyte = {
    "back1.us-east-1"     = 51
    "back2.us-east-1"     = 52
    "back3.us-east-1"     = 53
    "backup1.us-east-1"   = 61
    "backup2.us-east-1"   = 62
    "backup3.us-east-1"   = 63
    "web1.us-east-1"      = 1
    "web2.us-east-1"      = 2
    "web3.us-east-1"      = 3
    "exchange1.us-east-1" = 11
    "exchange2.us-east-1" = 12
    "exchange3.us-east-1" = 13
    "mgmt1.us-east-1"     = 21
    "mgmt2.us-east-1"     = 22
    "mgmt3.us-east-1"     = 23
    "sql1.us-east-1"      = 31
    "sql2.us-east-1"      = 32
    "sql3.us-east-1"      = 33
    "gw1.us-east-1"       = 254
    "gw2.us-east-1"       = 253
    "gw3.us-east-1"       = 252
  }
  
  aws_number = {
    dc         = 0
    guacamole  = 1
    # ... other services
  }
}
```

## VPC Submodule

### Overview

Creates a VPC with multi-tier subnet architecture across multiple availability zones. Includes public and private subnets for different service tiers (web, backend, database, management, backup).

### Resources Created

- VPC with DNS support enabled
- Internet Gateway for public internet access
- Egress-only Internet Gateway for IPv6
- NAT Gateways for private subnet internet access
- Multiple subnet types across availability zones:
  - Web tier (public subnets)
  - Backend tier (private subnets)
  - Backup tier (private subnets)
  - Exchange tier (private subnets)
  - Management tier (public subnets)
  - SQL tier (private subnets)
- Route tables for each subnet type
- VPC endpoints for AWS services (S3, SSM, EC2 Messages, Secrets Manager)
- Security group for VPC endpoints
- VPC Flow Logs for network monitoring

### Key Features

- Multi-AZ deployment for high availability
- Separate subnets for different service tiers
- VPC endpoints to reduce data transfer costs
- IPv4 and IPv6 support
- Dynamic CIDR block calculation using for expressions

## IAM Submodule

### Overview

Creates IAM roles and instance profiles for EC2 instances to access AWS services securely without embedding credentials.

### Resources Created

- IAM role with assume role policy for EC2
- IAM instance profile
- IAM policies for:
  - EC2 read-only access
  - S3 bucket access
  - Secrets Manager access
  - Systems Manager access

### Key Features

- Least privilege access policies
- Secure credential management via IAM roles
- Support for Systems Manager Session Manager

## Route53 Submodule

### Overview

Creates private and public DNS hosted zones for service discovery and external access.

### Resources Created

- Private Route 53 hosted zone associated with VPC
- Optional public Route 53 hosted zone lookup

### Key Features

- Private DNS for internal service discovery
- Integration with VPC for split-horizon DNS
- Support for external DNS delegation

## DynamoDB Submodule

### Overview

Creates DynamoDB tables for Terraform state locking to prevent concurrent modifications.

### Resources Created

- DynamoDB table with LockID as hash key
- Server-side encryption enabled

### Key Features

- State locking for safe concurrent Terraform operations
- Pay-per-request billing mode

## Demand Submodule

### Overview

Manages on-demand capacity reservations for EC2 instances.

### Resources Created

- On-demand capacity reservations (when configured)

## Network Architecture

```
VPC (10.0.0.0/16)
├── Web Tier (Public Subnets)
│   ├── AZ1: 10.0.1.0/24
│   ├── AZ2: 10.0.2.0/24
│   └── AZ3: 10.0.3.0/24
├── Backend Tier (Private Subnets)
│   ├── AZ1: 10.0.51.0/24
│   ├── AZ2: 10.0.52.0/24
│   └── AZ3: 10.0.53.0/24
├── Backup Tier (Private Subnets)
│   ├── AZ1: 10.0.61.0/24
│   ├── AZ2: 10.0.62.0/24
│   └── AZ3: 10.0.63.0/24
├── Exchange Tier (Private Subnets)
│   ├── AZ1: 10.0.11.0/24
│   ├── AZ2: 10.0.12.0/24
│   └── AZ3: 10.0.13.0/24
├── Management Tier (Public Subnets)
│   ├── AZ1: 10.0.21.0/24
│   ├── AZ2: 10.0.22.0/24
│   └── AZ3: 10.0.23.0/24
└── SQL Tier (Private Subnets)
    ├── AZ1: 10.0.31.0/24
    ├── AZ2: 10.0.32.0/24
    └── AZ3: 10.0.33.0/24
```

## Notes

- The VPC uses a /16 CIDR block (10.0.0.0/16) providing 65,536 IP addresses
- Each subnet uses a /24 CIDR block providing 256 IP addresses (251 usable)
- NAT Gateways are deployed in each availability zone for high availability
- VPC endpoints reduce data transfer costs for AWS service access
- The module uses dynamic CIDR block generation with for expressions for maintainability
- All resources are tagged for cost allocation and management
