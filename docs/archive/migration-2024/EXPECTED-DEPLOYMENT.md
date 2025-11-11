# Expected Deployment with Current Configuration

## Configuration Summary

Based on `terraform.auto.tfvars`, you have requested:

### Windows Services (17 services × 3 instances = 51 VMs)
- **adds** (Active Directory): 3 instances
- **adfs** (AD Federation Services): 3 instances  
- **dhcp** (DHCP Server): 3 instances
- **da** (DirectAccess): 3 instances
- **exchange** (Exchange Server): 3 instances
- **fs** (File Server): 3 instances
- **ipam** (IP Address Management): 3 instances
- **mgmt** (Management Server): 3 instances
- **nps** (Network Policy Server): 3 instances
- **rdsh** (Remote Desktop Session Host): 3 instances
- **sharepoint** (SharePoint): 3 instances
- **sql** (SQL Server): 3 instances
- **simpana** (Commvault): 3 instances
- **sofs** (Scale-Out File Server): 3 instances
- **wac** (Windows Admin Center): 3 instances
- **wds** (Windows Deployment Services): 3 instances
- **wsus** (Windows Update Services): 3 instances

### Unix/Linux Services (7 services, 22 instances = 22 VMs)
- **guacamole** (Bastion): 1 instance
- **glpi** (IT Asset Management): 3 instances
- **vault** (HashiCorp Vault): 3 instances
- **nbu** (NetBackup): 3 instances
- **oracle** (Oracle Database): 3 instances
- **redis** (Redis): 3 instances
- **bsd** (FreeBSD): 3 instances

## Total Resources

### EC2 Instances
- **Total VMs**: 73 instances (51 Windows + 22 Unix)
- **Instance Type**: t3.medium (most services)
- **Availability Zone**: eu-west-1a (single AZ)

### Additional Resources
- **Security Groups**: ~25 (one per service + common groups)
- **Route53 Records**: ~146 (2 per instance: private + some public)
- **VPC Infrastructure**: 1 VPC, 5 subnet types, IGW, NAT, etc.
- **VPC Endpoints**: 4 (SSM, EC2Messages, SSMMessages, Secrets Manager)
- **IAM Roles**: From global module

## Estimated Monthly Cost

### Compute (EC2)
- 73 × t3.medium instances
- ~$30/month per instance
- **Subtotal**: ~$2,190/month

### Storage (EBS)
- 73 × 30-80 GB root volumes
- ~$0.10/GB/month
- **Subtotal**: ~$300/month

### Data Transfer
- Minimal for lab environment
- **Subtotal**: ~$50/month

### Other Services
- VPC, Route53, VPC Endpoints
- **Subtotal**: ~$60/month

### **TOTAL ESTIMATED COST: ~$2,600/month**

## Current Issue

The deployment is failing validation because:

```
Error: Invalid value for variable
Instance counts must be between 0 and 10.
```

You have set all services to **3 instances**, which is valid (between 0 and 10).

However, there's also a CIDR byte validation error that needs investigation.

## Recommended Actions

### Option 1: Start Small (Recommended)
Deploy just the bastion host first:

```hcl
# In terraform.auto.tfvars
aws_number = {
  "guacamole" = 1  # Just the bastion
  # Set all others to 0
}
```

**Cost**: ~$35/month

### Option 2: Deploy Core Services
Deploy essential services:

```hcl
aws_number = {
  "guacamole" = 1  # Bastion
  "adds"      = 2  # Domain Controllers (2 for redundancy)
  "dhcp"      = 1  # DHCP
  "mgmt"      = 1  # Management
  # Set all others to 0
}
```

**Cost**: ~$150/month

### Option 3: Full Lab (Current Config)
Deploy all 73 instances as configured.

**Cost**: ~$2,600/month

## Deployment Steps

1. **Fix validation errors** (in progress)
2. **Choose deployment size** (Option 1, 2, or 3)
3. **Update terraform.auto.tfvars** accordingly
4. **Run terraform plan** to verify
5. **Run terraform apply** to deploy

## Notes

- All instances will be in **single AZ** (eu-west-1a)
- **No public admin access** (secure - access via Guacamole)
- **Admin CIDR**: 10.0.0.0/16 (VPC only)
- **DNS**: ez-lab.xyz
- **Region**: eu-west-1

## Next Steps

Let me fix the validation errors and then you can choose which deployment size you want.
