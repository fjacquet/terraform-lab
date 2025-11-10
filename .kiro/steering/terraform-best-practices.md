## Terraform Best Practices

### Module Design

**Standard Module Structure**

- Each module should contain: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- Use consistent variable names across modules: `aws_number`, `aws_subnet_id`, `aws_vpc_id`, `dns_zone_id`
- Modules should accept standard inputs (AMI, subnet, VPC, security groups, DNS zone)
- Use `count` or `for_each` controlled by variables to enable/disable resources
- Always output resource IDs and attributes needed by other modules

**Module Composition**

```hcl
# Use flatten() to combine security group lists
aws_sg_ids = flatten([
  aws_security_group.base.id,
  module.service.aws_sg_ids,
  var.additional_sg_ids,
])
```

### State Management

**Backend Configuration**

- Use remote backends (S3, Terraform Cloud) for team collaboration
- Enable state locking with DynamoDB for S3 backends
- Always encrypt state files (`encrypt = true`)
- Use separate state files per environment via workspaces or separate configurations

**State Operations**

```bash
# List resources before making changes
terraform state list

# Move resources when refactoring
terraform state mv aws_instance.old aws_instance.new

# Remove from state without destroying
terraform state rm aws_instance.example

# Import existing infrastructure
terraform import aws_instance.example i-0abc123def456
```

**Refactoring with moved blocks**

```hcl
moved {
  from = aws_instance.old_name
  to   = aws_instance.new_name
}
```

### Provider Configuration

**Version Constraints**

```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"  # Allow patch updates only
    }
  }
}
```

**Multiple Provider Instances**

```hcl
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_instance" "east_server" {
  provider = aws.east
  # ...
}
```

**Default Tags**

```hcl
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Project     = "terraform-lab"
    }
  }
}
```

### Resource Lifecycle Management

**Lifecycle Rules**

```hcl
resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true  # Create replacement before destroying
    prevent_destroy       = true  # Prevent accidental deletion
    ignore_changes        = [tags, user_data]  # Ignore external changes
  }
}
```

**Force Replacement on Dependency Changes**

```hcl
resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
  lifecycle {
    replace_triggered_by = [
      aws_iam_policy.example.id
    ]
  }
}
```

### Data Sources

**Query Existing Infrastructure**

```hcl
# Use data sources instead of hardcoding values
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Reference in resources
resource "aws_instance" "web" {
  ami               = data.aws_ami.ubuntu.id
  availability_zone = data.aws_availability_zones.available.names[0]
}
```

**Remote State Data Sources**

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  
  config = {
    bucket = "terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-west-2"
  }
}

# Use outputs from other state files
resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.network.outputs.subnet_id
}
```

### Workflow Best Practices

**Standard Workflow**

```bash
# 1. Initialize (download providers, setup backend)
terraform init

# 2. Validate syntax and configuration
terraform validate

# 3. Format code consistently
terraform fmt -recursive

# 4. Generate and review plan
terraform plan -out=tfplan

# 5. Apply saved plan
terraform apply tfplan

# 6. Verify outputs
terraform output
```

**Performance Optimization**

```bash
# Increase parallelism for faster operations
export TF_CLI_ARGS="-parallelism=50"
export TFE_PARALLELISM=50
export TF_REGISTRY_CLIENT_TIMEOUT=15
```

**Workspace Management**

```bash
# Use workspaces for environment isolation
terraform workspace new production
terraform workspace new staging
terraform workspace select production
terraform apply
```

### Security Best Practices

**Sensitive Data**

- Never commit credentials to version control
- Use AWS Secrets Manager or similar for sensitive values
- Mark outputs as sensitive when needed:

```hcl
output "db_password" {
  value     = aws_db_instance.example.password
  sensitive = true
}
```

**Variable Validation**

```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  
  validation {
    condition     = can(regex("^t[23]\\.", var.instance_type))
    error_message = "Instance type must be t2 or t3 family."
  }
}
```

### Debugging and Troubleshooting

**Inspect State and Plans**

```bash
# View current state
terraform show

# View state in JSON
terraform show -json > state.json

# Interactive console for testing expressions
terraform console
> aws_instance.example.public_ip
> length(var.availability_zones)
```

**Targeted Operations**

```bash
# Apply changes to specific resources only
terraform apply -target=aws_instance.example

# Destroy specific resources
terraform destroy -target=aws_instance.example

# Refresh state without applying changes
terraform refresh
```

**Taint Resources for Replacement**

```bash
# Mark resource for recreation
terraform taint aws_instance.example
terraform apply
```

### Code Organization

**File Structure**

- `main.tf`: Primary resource definitions
- `variables.tf`: Input variable declarations
- `outputs.tf`: Output value declarations
- `versions.tf`: Provider version constraints
- `backend.tf`: Backend configuration
- `data.tf`: Data source queries (optional)

**Naming Conventions**

- Resources: `<provider>_<resource_type>_<descriptive_name>`
- Variables: Use snake_case
- Modules: Use descriptive names matching their purpose
- Tags: Consistent tagging strategy across all resources

### Module Usage

**Local Modules**

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  cidr_block = "10.0.0.0/16"
  region     = var.region
}
```

**Registry Modules**

```hcl
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.0"
  
  bucket = "my-application-bucket"
  acl    = "private"
}
```

**Module Outputs**

```hcl
# Reference module outputs in resources
resource "aws_instance" "app" {
  subnet_id = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]
}
```

### Dependencies

**Implicit Dependencies**

- Terraform automatically detects dependencies through resource references
- Use resource attributes to create implicit dependencies

**Explicit Dependencies**

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
  # Explicit dependency when implicit isn't sufficient
  depends_on = [aws_iam_role_policy.example]
}
```

### Testing and Validation

**Pre-Apply Checks**

```bash
# Validate configuration syntax
terraform validate

# Check formatting
terraform fmt -check -recursive

# Generate plan and review
terraform plan

# Use -detailed-exitcode for CI/CD
terraform plan -detailed-exitcode
# Exit code 0: no changes
# Exit code 1: error
# Exit code 2: changes present
```
