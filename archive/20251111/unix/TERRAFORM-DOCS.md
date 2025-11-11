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
| <a name="input_admin_cidr_blocks"></a> [admin\_cidr\_blocks](#input\_admin\_cidr\_blocks) | CIDR blocks allowed for administrative access | `list(string)` | n/a | yes |
| <a name="input_aws_disks_size"></a> [aws\_disks\_size](#input\_aws\_disks\_size) | n/a | `map(string)` | n/a | yes |
| <a name="input_aws_iip_assumerole_name"></a> [aws\_iip\_assumerole\_name](#input\_aws\_iip\_assumerole\_name) | n/a | `any` | n/a | yes |
| <a name="input_aws_key_pair_auth_id"></a> [aws\_key\_pair\_auth\_id](#input\_aws\_key\_pair\_auth\_id) | n/a | `any` | n/a | yes |
| <a name="input_aws_number"></a> [aws\_number](#input\_aws\_number) | n/a | `map(string)` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `any` | n/a | yes |
| <a name="input_aws_sg_simpana_client_id"></a> [aws\_sg\_simpana\_client\_id](#input\_aws\_sg\_simpana\_client\_id) | n/a | `any` | n/a | yes |
| <a name="input_aws_subnet_back_id"></a> [aws\_subnet\_back\_id](#input\_aws\_subnet\_back\_id) | n/a | `list(string)` | n/a | yes |
| <a name="input_aws_subnet_backup_id"></a> [aws\_subnet\_backup\_id](#input\_aws\_subnet\_backup\_id) | n/a | `list(string)` | n/a | yes |
| <a name="input_aws_subnet_mgmt_id"></a> [aws\_subnet\_mgmt\_id](#input\_aws\_subnet\_mgmt\_id) | n/a | `list(string)` | n/a | yes |
| <a name="input_aws_subnet_web_id"></a> [aws\_subnet\_web\_id](#input\_aws\_subnet\_web\_id) | n/a | `list(string)` | n/a | yes |
| <a name="input_aws_vpc_id"></a> [aws\_vpc\_id](#input\_aws\_vpc\_id) | n/a | `any` | n/a | yes |
| <a name="input_azs"></a> [azs](#input\_azs) | n/a | `list(string)` | n/a | yes |
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | Computed CIDR blocks for all subnet types | `map(list(string))` | n/a | yes |
| <a name="input_cidrbyte"></a> [cidrbyte](#input\_cidrbyte) | n/a | `map(string)` | n/a | yes |
| <a name="input_dns_public_zone_id"></a> [dns\_public\_zone\_id](#input\_dns\_public\_zone\_id) | n/a | `any` | n/a | yes |
| <a name="input_dns_suffix"></a> [dns\_suffix](#input\_dns\_suffix) | n/a | `any` | n/a | yes |
| <a name="input_dns_zone_id"></a> [dns\_zone\_id](#input\_dns\_zone\_id) | n/a | `any` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `any` | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_sg_guacamole_id"></a> [aws\_sg\_guacamole\_id](#output\_aws\_sg\_guacamole\_id) | n/a |
| <a name="output_aws_sg_nbuclient_ids"></a> [aws\_sg\_nbuclient\_ids](#output\_aws\_sg\_nbuclient\_ids) | n/a |
| <a name="output_aws_sg_nbumaster_ids"></a> [aws\_sg\_nbumaster\_ids](#output\_aws\_sg\_nbumaster\_ids) | n/a |
| <a name="output_aws_sg_oracle_id"></a> [aws\_sg\_oracle\_id](#output\_aws\_sg\_oracle\_id) | n/a |
| <a name="output_aws_sg_ssh_id"></a> [aws\_sg\_ssh\_id](#output\_aws\_sg\_ssh\_id) | n/a |

<!-- END_TF_DOCS -->