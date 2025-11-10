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
| <a name="input_aws_number"></a> [aws\_number](#input\_aws\_number) | n/a | `map(string)` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `any` | n/a | yes |
| <a name="input_azs"></a> [azs](#input\_azs) | n/a | `list(string)` | n/a | yes |
| <a name="input_cidrbyte"></a> [cidrbyte](#input\_cidrbyte) | n/a | `map(string)` | n/a | yes |
| <a name="input_cidrbyte_back"></a> [cidrbyte\_back](#input\_cidrbyte\_back) | n/a | `list(string)` | n/a | yes |
| <a name="input_cidrbyte_backup"></a> [cidrbyte\_backup](#input\_cidrbyte\_backup) | n/a | `list(string)` | n/a | yes |
| <a name="input_cidrbyte_exchange"></a> [cidrbyte\_exchange](#input\_cidrbyte\_exchange) | n/a | `list(string)` | n/a | yes |
| <a name="input_cidrbyte_gw"></a> [cidrbyte\_gw](#input\_cidrbyte\_gw) | n/a | `list(string)` | n/a | yes |
| <a name="input_cidrbyte_mgmt"></a> [cidrbyte\_mgmt](#input\_cidrbyte\_mgmt) | n/a | `list(string)` | n/a | yes |
| <a name="input_cidrbyte_sql"></a> [cidrbyte\_sql](#input\_cidrbyte\_sql) | n/a | `list(string)` | n/a | yes |
| <a name="input_cidrbyte_web"></a> [cidrbyte\_web](#input\_cidrbyte\_web) | n/a | `list(string)` | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_subnet_back_id"></a> [aws\_subnet\_back\_id](#output\_aws\_subnet\_back\_id) | n/a |
| <a name="output_aws_subnet_backup_id"></a> [aws\_subnet\_backup\_id](#output\_aws\_subnet\_backup\_id) | n/a |
| <a name="output_aws_subnet_exchange_id"></a> [aws\_subnet\_exchange\_id](#output\_aws\_subnet\_exchange\_id) | n/a |
| <a name="output_aws_subnet_mgmt_id"></a> [aws\_subnet\_mgmt\_id](#output\_aws\_subnet\_mgmt\_id) | n/a |
| <a name="output_aws_subnet_web_id"></a> [aws\_subnet\_web\_id](#output\_aws\_subnet\_web\_id) | n/a |
| <a name="output_aws_vpc_id"></a> [aws\_vpc\_id](#output\_aws\_vpc\_id) | n/a |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | n/a |

<!-- END_TF_DOCS -->