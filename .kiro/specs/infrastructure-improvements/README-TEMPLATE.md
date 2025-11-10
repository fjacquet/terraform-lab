# Module Name

## Overview

Brief description of what this module does and its purpose in the infrastructure.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| example_var | Description of the variable | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| example_output | Description of the output |

## Usage Example

```hcl
module "example" {
  source = "./path/to/module"
  
  example_var = "value"
}
```

## Resources Created

- List of AWS resources created by this module
- Include resource types and purposes

## Notes

- Any additional information
- Special considerations
- Dependencies on other modules
