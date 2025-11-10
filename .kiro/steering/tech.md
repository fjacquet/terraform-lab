## Technology Stack

### Infrastructure as Code

- **Terraform** (~3.0): AWS provider for infrastructure provisioning
- **Backend**: Terraform Cloud (remote state in organization "fjacquet")
- **AWS Services**: EC2, VPC, Route53, IAM, S3, Secrets Manager, DynamoDB

### Configuration Management

- **Ansible**: System and application configuration
- **Python**: Runtime for Ansible and tooling
- **Collections**: amazon.aws, ansible.windows, community.*, vmware.*, cisco.*, purestorage.*

### Key Dependencies

- boto3: AWS SDK for Python
- pypsrp/pywinrm: Windows remote management
- hvac: HashiCorp Vault client
- ansible-parallel: Parallel playbook execution

## Common Commands

### Setup

```bash
# Install Python dependencies
pip3 install -r requirements.txt

# Install Ansible collections and roles
ansible-galaxy install -r requirements.yml

# Configure Terraform performance
export TF_CLI_ARGS="-parallelism=50"
export TFE_PARALLELISM=50
export TF_REGISTRY_CLIENT_TIMEOUT=15

# Fix WinRM on macOS
export no_proxy="*"
```

### Terraform Workflow

```bash
# Plan infrastructure changes
terraform plan

# Apply infrastructure
terraform apply

# Destroy infrastructure
terraform destroy
```

### Ansible Workflow

```bash
# Configure base systems (run after Terraform)
ansible-parallel playbooks/system/*.yml

# Configure applications
ansible-parallel playbooks/apps/*.yml

# Target specific inventory
ansible-playbook -i inventory/aws_ec2.yaml playbooks/system/configure-windows.yml
```

### Build Order

1. Deploy Guacamole first (bastion/jump host)
2. Deploy Domain Controller before other Windows services
3. Run system playbooks before application playbooks

## Configuration Files

- `ansible.cfg`: Ansible configuration with AWS EC2 dynamic inventory
- `variables.tf`: Main configuration for VM counts and network layout
- `backend.tf`: Terraform backend and AWS provider configuration
- `.ssh/config`: SSH proxy configuration for bastion access
