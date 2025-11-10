# Security Documentation

This document outlines the security improvements, best practices, and configurations implemented in the terraform-lab infrastructure.

## Table of Contents

- [Security Overview](#security-overview)
- [Network Security](#network-security)
- [Access Control](#access-control)
- [Secrets Management](#secrets-management)
- [Instance Security](#instance-security)
- [VPC Endpoints](#vpc-endpoints)
- [Monitoring and Auditing](#monitoring-and-auditing)
- [Best Practices](#best-practices)
- [Security Checklist](#security-checklist)

## Security Overview

The infrastructure implements defense-in-depth security with multiple layers:

1. **Network Layer**: Restricted security groups, private subnets, VPC endpoints
2. **Access Layer**: IAM roles, MFA, restricted CIDR blocks
3. **Data Layer**: Secrets Manager, encryption at rest and in transit
4. **Instance Layer**: IMDSv2, minimal attack surface, security updates
5. **Monitoring Layer**: CloudTrail, VPC Flow Logs, CloudWatch

### Security Improvements

This version includes the following security enhancements:

| Improvement | Benefit | Impact |
|-------------|---------|--------|
| Restricted Admin Access | Prevents unauthorized access | High |
| Secrets Manager Integration | Eliminates hardcoded credentials | High |
| IMDSv2 Enforcement | Protects against SSRF attacks | High |
| VPC Endpoints | Reduces internet exposure | Medium |
| Enhanced Error Handling | Improves security visibility | Medium |
| Resource Tagging | Enables security auditing | Low |

## Network Security

### Security Groups

Security groups implement the principle of least privilege with explicit allow rules.

#### Administrative Access Security Group

Controls access to management interfaces:

```hcl
resource "aws_security_group" "rdp" {
  name        = "tf_ezlab_rdp"
  description = "Administrative access for Windows servers"
  vpc_id      = var.aws_vpc_id

  ingress {
    description = "RDP access from authorized networks"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }

  ingress {
    description = "SSH access from authorized networks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }

  ingress {
    description = "WinRM HTTP from authorized networks"
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }

  ingress {
    description = "WinRM HTTPS from authorized networks"
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = local.admin_cidr_blocks
  }
}
```

**Security Features:**
- Explicit CIDR block restrictions
- Descriptive rule comments
- No 0.0.0.0/0 by default
- Separate security groups per tier

#### Application Security Groups

Application-specific security groups reference each other instead of using CIDR blocks:

```hcl
resource "aws_security_group" "web" {
  ingress {
    description     = "HTTPS from load balancer"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
}
```

### Network Segmentation

The VPC is segmented into multiple subnet types:

| Subnet Type | Purpose | Internet Access | NAT Gateway |
|-------------|---------|-----------------|-------------|
| Public (web) | Load balancers, bastion | Direct via IGW | N/A |
| Private (back) | Application servers | Via NAT Gateway | Yes |
| Private (mgmt) | Management tools | Via NAT Gateway | Yes |
| Private (sql) | Databases | Via NAT Gateway | Yes |
| Private (exchange) | Exchange servers | Via NAT Gateway | Yes |
| Private (backup) | Backup systems | Via NAT Gateway | Yes |

**Security Benefits:**
- Application servers not directly accessible from internet
- Database servers isolated in dedicated subnets
- Management tools in separate network segment
- Controlled egress through NAT Gateway

### VPC Flow Logs

Enable VPC Flow Logs for network traffic analysis:

```hcl
resource "aws_flow_log" "vpc" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
}
```

## Access Control

### Administrative Access Variables

Two variables control administrative access:

#### admin_cidr_blocks

Defines allowed IP ranges for administrative access:

```hcl
variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for administrative access (RDP, SSH, WinRM)"
  type        = list(string)
  default     = ["10.0.0.0/16"]  # VPC CIDR only
  
  validation {
    condition     = alltrue([for cidr in var.admin_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "All admin_cidr_blocks must be valid CIDR notation."
  }
}
```

**Recommended Configurations:**

```hcl
# Production: Corporate network only
admin_cidr_blocks = ["203.0.113.0/24"]

# Staging: Corporate network + VPN
admin_cidr_blocks = ["203.0.113.0/24", "198.51.100.0/24"]

# Development: VPC only
admin_cidr_blocks = ["10.0.0.0/16"]

# Lab: Multiple trusted networks
admin_cidr_blocks = ["10.0.0.0/16", "192.168.1.0/24"]
```

#### enable_public_admin_access

Emergency override for public access (use with caution):

```hcl
variable "enable_public_admin_access" {
  description = "Allow administrative access from internet (not recommended for production)"
  type        = bool
  default     = false
}
```

**Security Impact:**

| Setting | CIDR Blocks Used | Risk Level | Use Case |
|---------|------------------|------------|----------|
| `false` (default) | `admin_cidr_blocks` | Low | Production, normal operations |
| `true` | `0.0.0.0/0` | High | Emergency access, initial setup |

**Warning**: Never set `enable_public_admin_access = true` in production environments.

### IAM Roles and Policies

EC2 instances use IAM roles instead of access keys:

```hcl
resource "aws_iam_role" "ec2_role" {
  name = "ec2-application-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "secrets_access" {
  name = "secrets-manager-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = [
        "arn:aws:secretsmanager:*:*:secret:ez-lab.xyz/*",
        "arn:aws:secretsmanager:*:*:secret:ezlab/*"
      ]
    }]
  })
}
```

**Security Benefits:**
- No long-term credentials on instances
- Automatic credential rotation
- Fine-grained permissions
- Audit trail via CloudTrail

## Secrets Management

### AWS Secrets Manager Integration

All sensitive credentials are stored in AWS Secrets Manager:

**Architecture:**

```
User Data Script → IAM Role → VPC Endpoint → Secrets Manager → KMS → Secret Value
```

### Secret Naming Convention

Secrets follow a hierarchical naming structure:

```
ez-lab.xyz/
├── ansible/
│   └── localadmin          # Local admin password
└── ...

ezlab/
├── ad/
│   ├── joinuser           # Domain join credentials
│   └── fjacquet           # User accounts
├── guacamole/
│   ├── mysqlroot          # Database passwords
│   └── mysqluser
├── sql/
│   └── svc-sql            # Service accounts
└── pki/
    └── svc-ndes           # PKI service accounts
```

### Secret Encryption

All secrets are encrypted at rest using AWS KMS:

```hcl
resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Secrets Manager"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### Secret Retrieval in PowerShell

User data scripts retrieve secrets with comprehensive error handling:

```powershell
function Get-SecretSafely {
    param(
        [string]$SecretId,
        [string]$Region
    )
    
    try {
        $secret = (Get-SECSecretValue -SecretId $SecretId -Region $Region -ErrorAction Stop).SecretString
        
        if ([string]::IsNullOrEmpty($secret)) {
            throw "Secret value is empty for $SecretId"
        }
        
        return $secret
    }
    catch {
        Write-EventLog -LogName Application -Source "EC2Config" `
            -EntryType Error -EventId 1001 `
            -Message "Failed to retrieve secret $SecretId : $_"
        throw
    }
}

# Usage
$password = Get-SecretSafely -SecretId "ez-lab.xyz/ansible/localadmin" -Region $region
```

**Security Features:**
- Error handling prevents script continuation on failure
- Logging to Windows Event Log for audit trail
- Validation of retrieved values
- No secrets in script output or logs

### Secret Rotation

Implement automatic secret rotation for enhanced security:

```bash
# Enable automatic rotation (30 days)
aws secretsmanager rotate-secret \
    --secret-id "ez-lab.xyz/ansible/localadmin" \
    --rotation-lambda-arn "arn:aws:lambda:region:account:function:rotation-function" \
    --rotation-rules AutomaticallyAfterDays=30
```

## Instance Security

### IMDSv2 Enforcement

All EC2 instances enforce Instance Metadata Service Version 2:

```hcl
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = "t3.medium"

  metadata_options {
    http_tokens                 = "required"  # Enforce IMDSv2
    http_put_response_hop_limit = 1           # Prevent forwarding
    http_endpoint               = "enabled"   # Keep metadata enabled
  }
}
```

### Security Benefits of IMDSv2

| Attack Vector | IMDSv1 | IMDSv2 |
|---------------|--------|--------|
| SSRF attacks | Vulnerable | Protected |
| Open firewalls | Vulnerable | Protected |
| Container escape | Vulnerable | Protected |
| Forwarded requests | Vulnerable | Protected |

### How IMDSv2 Works

1. **Request Session Token**:
   ```bash
   TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
       -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
   ```

2. **Use Token for Metadata Access**:
   ```bash
   INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
       http://169.254.169.254/latest/meta-data/instance-id)
   ```

3. **Token Expires**: After TTL (default 6 hours), request new token

### EBS Encryption

All EBS volumes should be encrypted:

```hcl
resource "aws_instance" "example" {
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    kms_key_id            = aws_kms_key.ebs.arn
    delete_on_termination = true
  }
}
```

### Systems Manager Session Manager

Use Session Manager instead of SSH for secure access:

**Benefits:**
- No open inbound ports required
- No SSH keys to manage
- Full audit trail in CloudTrail
- Session recording capability
- IAM-based access control

**Configuration:**

```hcl
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
```

## VPC Endpoints

### Interface Endpoints

Private connectivity to AWS services without internet gateway:

```hcl
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}
```

### VPC Endpoint Security Group

```hcl
resource "aws_security_group" "vpc_endpoints" {
  name        = "tf_ezlab_vpc_endpoints"
  description = "Security group for VPC interface endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Security Benefits

| Benefit | Description |
|---------|-------------|
| **No Internet Exposure** | Traffic stays within AWS network |
| **Reduced Attack Surface** | No NAT Gateway required for AWS services |
| **Cost Optimization** | Reduced data transfer costs |
| **Enhanced Privacy** | Traffic doesn't traverse public internet |
| **Compliance** | Meets data residency requirements |

## Monitoring and Auditing

### CloudTrail

Enable CloudTrail for all API activity:

```hcl
resource "aws_cloudtrail" "main" {
  name                          = "terraform-lab-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}
```

**Monitor for:**
- Unauthorized API calls
- Failed authentication attempts
- Security group changes
- IAM policy modifications
- Secrets Manager access

### CloudWatch Alarms

Set up alarms for security events:

```hcl
resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "unauthorized-api-calls"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnauthorizedAPICalls"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Alert on unauthorized API calls"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
}
```

### VPC Flow Logs

Analyze network traffic patterns:

```hcl
resource "aws_flow_log" "vpc" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn

  tags = {
    Name = "vpc-flow-logs"
  }
}
```

**Use cases:**
- Detect unusual traffic patterns
- Investigate security incidents
- Troubleshoot connectivity issues
- Compliance reporting

## Best Practices

### Production Deployment

1. **Network Security**
   - [ ] Use private subnets for application and database tiers
   - [ ] Restrict security groups to minimum required access
   - [ ] Enable VPC Flow Logs
   - [ ] Use VPC endpoints for AWS services
   - [ ] Implement Network ACLs for additional protection

2. **Access Control**
   - [ ] Set `admin_cidr_blocks` to corporate network only
   - [ ] Keep `enable_public_admin_access = false`
   - [ ] Use IAM roles instead of access keys
   - [ ] Enable MFA for privileged accounts
   - [ ] Implement least privilege access

3. **Secrets Management**
   - [ ] Store all credentials in Secrets Manager
   - [ ] Enable automatic secret rotation
   - [ ] Use KMS encryption for secrets
   - [ ] Audit secret access regularly
   - [ ] Never log or output secrets

4. **Instance Security**
   - [ ] Enforce IMDSv2 on all instances
   - [ ] Enable EBS encryption
   - [ ] Use Systems Manager Session Manager
   - [ ] Keep systems patched and updated
   - [ ] Implement host-based firewalls

5. **Monitoring**
   - [ ] Enable CloudTrail in all regions
   - [ ] Set up CloudWatch alarms for security events
   - [ ] Review logs regularly
   - [ ] Implement automated alerting
   - [ ] Conduct regular security audits

### Development/Lab Environments

1. **Relaxed but Secure**
   - Use VPC CIDR for `admin_cidr_blocks`
   - Keep `enable_public_admin_access = false`
   - Still use Secrets Manager (good practice)
   - Enforce IMDSv2 (no reason not to)
   - Use smaller instance types

2. **Cost Optimization**
   - Use Spot Instances where appropriate
   - Stop instances when not in use
   - Use smaller EBS volumes
   - Consider removing VPC endpoints if cost is concern

3. **Testing**
   - Test security configurations before production
   - Verify secret retrieval works
   - Test IMDSv2 compatibility
   - Validate network connectivity

### Security Hardening Checklist

- [ ] All security groups follow least privilege
- [ ] No 0.0.0.0/0 in production security groups
- [ ] All secrets stored in Secrets Manager
- [ ] IMDSv2 enforced on all instances
- [ ] EBS volumes encrypted
- [ ] CloudTrail enabled and monitored
- [ ] VPC Flow Logs enabled
- [ ] IAM roles used instead of access keys
- [ ] MFA enabled for privileged accounts
- [ ] Regular security audits scheduled
- [ ] Incident response plan documented
- [ ] Backup and recovery tested
- [ ] Patch management process in place
- [ ] Security training for team members

## Security Checklist

Use this checklist to verify security configuration:

### Network Security
- [ ] Security groups restrict admin access to specific CIDRs
- [ ] No security group rules allow 0.0.0.0/0 for admin ports
- [ ] VPC Flow Logs enabled
- [ ] Network ACLs configured appropriately
- [ ] Private subnets used for application/database tiers

### Access Control
- [ ] `admin_cidr_blocks` configured for environment
- [ ] `enable_public_admin_access` set to `false` in production
- [ ] IAM roles assigned to all EC2 instances
- [ ] No hardcoded AWS credentials in code
- [ ] MFA enabled for privileged accounts

### Secrets Management
- [ ] All required secrets created in Secrets Manager
- [ ] Secrets encrypted with KMS
- [ ] IAM policies grant minimal Secrets Manager access
- [ ] VPC endpoint for Secrets Manager configured
- [ ] No secrets in code, logs, or outputs

### Instance Security
- [ ] IMDSv2 enforced on all instances
- [ ] EBS volumes encrypted
- [ ] Systems Manager agent installed
- [ ] Security updates applied
- [ ] Unnecessary services disabled

### VPC Endpoints
- [ ] VPC endpoints created for required services
- [ ] VPC endpoint security groups configured
- [ ] Private DNS enabled for interface endpoints
- [ ] Endpoints in correct subnets

### Monitoring
- [ ] CloudTrail enabled in all regions
- [ ] CloudWatch alarms configured
- [ ] Log retention policies set
- [ ] Security alerts configured
- [ ] Regular log review process established

### Documentation
- [ ] Security configurations documented
- [ ] Incident response plan created
- [ ] Runbooks updated
- [ ] Team trained on security practices
- [ ] Compliance requirements documented

## Incident Response

### Security Incident Procedure

1. **Detection**
   - Monitor CloudWatch alarms
   - Review CloudTrail logs
   - Check security group changes
   - Investigate unusual activity

2. **Containment**
   - Isolate affected resources
   - Revoke compromised credentials
   - Update security groups
   - Snapshot affected instances

3. **Investigation**
   - Review CloudTrail logs
   - Analyze VPC Flow Logs
   - Check application logs
   - Document findings

4. **Remediation**
   - Patch vulnerabilities
   - Rotate credentials
   - Update security configurations
   - Apply lessons learned

5. **Recovery**
   - Restore from backups if needed
   - Verify system integrity
   - Resume normal operations
   - Update documentation

### Emergency Contacts

Document emergency contacts and escalation procedures:

- Security team contact
- AWS support contact
- Management escalation
- Legal/compliance contact

## Compliance

### Compliance Frameworks

This infrastructure can support various compliance frameworks:

- **PCI DSS**: Payment card industry standards
- **HIPAA**: Healthcare data protection
- **SOC 2**: Service organization controls
- **ISO 27001**: Information security management
- **GDPR**: Data protection and privacy

### Compliance Features

| Requirement | Implementation |
|-------------|----------------|
| Data encryption | KMS encryption for EBS, Secrets Manager |
| Access control | IAM roles, security groups, MFA |
| Audit logging | CloudTrail, VPC Flow Logs, CloudWatch |
| Network isolation | VPC, private subnets, security groups |
| Secrets management | AWS Secrets Manager with rotation |
| Incident response | CloudWatch alarms, automated alerts |

## Additional Resources

- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
- [AWS Well-Architected Framework - Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [Terraform Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## Conclusion

This infrastructure implements comprehensive security controls following AWS and industry best practices. Regular review and updates of security configurations are essential to maintain a strong security posture.

For questions or concerns about security, please refer to the [MIGRATION.md](MIGRATION.md) guide or open an issue in the repository.
