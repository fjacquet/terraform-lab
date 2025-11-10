<!-- BEGIN_TF_DOCS -->


## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | n/a | `any` | n/a | yes |
| <a name="input_aws_number"></a> [aws\_number](#input\_aws\_number) | n/a | `map(string)` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `any` | n/a | yes |
| <a name="input_azs"></a> [azs](#input\_azs) | n/a | `list(string)` | n/a | yes |
| <a name="input_cidrbyte"></a> [cidrbyte](#input\_cidrbyte) | n/a | `map(string)` | n/a | yes |
| <a name="input_dns_suffix"></a> [dns\_suffix](#input\_dns\_suffix) | n/a | `any` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | n/a | `any` | n/a | yes |
| <a name="input_public_dns_id"></a> [public\_dns\_id](#input\_public\_dns\_id) | n/a | `any` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | n/a | `any` | n/a | yes |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | n/a | `any` | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_iip_assumerole"></a> [aws\_iip\_assumerole](#output\_aws\_iip\_assumerole) | n/a |
| <a name="output_aws_subnet_back_id"></a> [aws\_subnet\_back\_id](#output\_aws\_subnet\_back\_id) | n/a |
| <a name="output_aws_subnet_backup_id"></a> [aws\_subnet\_backup\_id](#output\_aws\_subnet\_backup\_id) | n/a |
| <a name="output_aws_subnet_exchange_id"></a> [aws\_subnet\_exchange\_id](#output\_aws\_subnet\_exchange\_id) | n/a |
| <a name="output_aws_subnet_mgmt_id"></a> [aws\_subnet\_mgmt\_id](#output\_aws\_subnet\_mgmt\_id) | n/a |
| <a name="output_aws_subnet_web_id"></a> [aws\_subnet\_web\_id](#output\_aws\_subnet\_web\_id) | n/a |
| <a name="output_aws_vpc_id"></a> [aws\_vpc\_id](#output\_aws\_vpc\_id) | n/a |
| <a name="output_dns_public_zone_id"></a> [dns\_public\_zone\_id](#output\_dns\_public\_zone\_id) | n/a |
| <a name="output_dns_zone_id"></a> [dns\_zone\_id](#output\_dns\_zone\_id) | n/a |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | n/a |

<!-- END_TF_DOCS -->