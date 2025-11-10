<!-- BEGIN_TF_DOCS -->


## Requirements

## Requirements

No requirements.

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_vpc_id"></a> [aws\_vpc\_id](#input\_aws\_vpc\_id) | VPC ID for private hosted zone | `string` | n/a | yes |
| <a name="input_dns_suffix"></a> [dns\_suffix](#input\_dns\_suffix) | DNS domain name for the hosted zone | `string` | n/a | yes |
| <a name="input_public_dns_id"></a> [public\_dns\_id](#input\_public\_dns\_id) | Route 53 public hosted zone ID (optional) | `string` | `""` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_public_zone_id"></a> [dns\_public\_zone\_id](#output\_dns\_public\_zone\_id) | n/a |
| <a name="output_dns_zone_id"></a> [dns\_zone\_id](#output\_dns\_zone\_id) | n/a |

<!-- END_TF_DOCS -->