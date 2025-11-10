<!-- BEGIN_TF_DOCS -->


## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | AWS access key (prefer using IAM roles or AWS SSO instead) | `string` | `""` | no |
| <a name="input_admin_cidr_blocks"></a> [admin\_cidr\_blocks](#input\_admin\_cidr\_blocks) | CIDR blocks allowed for administrative access (RDP, SSH, WinRM). Restricts access to specific IP ranges for security. Default allows access only from within the VPC (10.0.0.0/16). For lab environments, this provides a secure default while allowing flexibility. | `list(string)` | <pre>[<br/>  "10.0.0.0/16"<br/>]</pre> | no |
| <a name="input_aws_disks_size"></a> [aws\_disks\_size](#input\_aws\_disks\_size) | n/a | `map` | <pre>{<br/>  "nbu_backups": 500,<br/>  "nbu_openv": 50<br/>}</pre> | no |
| <a name="input_aws_number"></a> [aws\_number](#input\_aws\_number) | Number of instances to create for each service type (0-10) | `map(number)` | <pre>{<br/>  "adfs": 0,<br/>  "bsd": 0,<br/>  "da": 0,<br/>  "dc": 0,<br/>  "dhcp": 0,<br/>  "etcd": 0,<br/>  "exchange": 0,<br/>  "fs": 0,<br/>  "glpi": 0,<br/>  "guacamole": 1,<br/>  "ipam": 0,<br/>  "longhorn": 0,<br/>  "mgmt": 0,<br/>  "nbu": 0,<br/>  "nps": 0,<br/>  "opscenter": 0,<br/>  "oracle": 0,<br/>  "pki-crl": 0,<br/>  "pki-ica": 0,<br/>  "pki-ndes": 0,<br/>  "pki-rca": 0,<br/>  "rancher": 0,<br/>  "rdsh": 0,<br/>  "redis": 0,<br/>  "sharepoint": 0,<br/>  "simpana": 0,<br/>  "sofs": 0,<br/>  "sql": 0,<br/>  "symv": 0,<br/>  "vault": 0,<br/>  "wac": 0,<br/>  "wds": 0,<br/>  "workers": 0,<br/>  "wsus": 0<br/>}</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for infrastructure deployment | `string` | `"eu-west-1"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | List of AWS availability zones for resource distribution (1-3 zones) | `list(string)` | <pre>[<br/>  "eu-west-1a"<br/>]</pre> | no |
| <a name="input_cidrbyte"></a> [cidrbyte](#input\_cidrbyte) | Third octet values for subnet CIDR blocks (10.0.X.0/24) | `map(number)` | <pre>{<br/>  "back1.eu-west-1": 51,<br/>  "back2.eu-west-1": 52,<br/>  "back3.eu-west-1": 53,<br/>  "backup1.eu-west-1": 41,<br/>  "backup2.eu-west-1": 42,<br/>  "backup3.eu-west-1": 43,<br/>  "exchange1.eu-west-1": 31,<br/>  "exchange2.eu-west-1": 32,<br/>  "exchange3.eu-west-1": 33,<br/>  "gw1.eu-west-1": 101,<br/>  "gw2.eu-west-1": 102,<br/>  "gw3.eu-west-1": 103,<br/>  "mgmt1.eu-west-1": 11,<br/>  "mgmt2.eu-west-1": 12,<br/>  "mgmt3.eu-west-1": 13,<br/>  "sql1.eu-west-1": 61,<br/>  "sql2.eu-west-1": 62,<br/>  "sql3.eu-west-1": 63,<br/>  "vpc.eu-west-1": 0,<br/>  "web1.eu-west-1": 1,<br/>  "web2.eu-west-1": 2,<br/>  "web3.eu-west-1": 3<br/>}</pre> | no |
| <a name="input_dns_suffix"></a> [dns\_suffix](#input\_dns\_suffix) | name of DNS zone | `string` | `"ez-lab.xyz"` | no |
| <a name="input_enable_public_admin_access"></a> [enable\_public\_admin\_access](#input\_enable\_public\_admin\_access) | Allow administrative access (RDP, SSH, WinRM) from the internet (0.0.0.0/0). WARNING: This is a security risk and should only be enabled for development/testing environments. When false, access is restricted to admin\_cidr\_blocks. Default is false for security. | `bool` | `false` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Desired name of AWS key pair | `string` | `"aws"` | no |
| <a name="input_public_dns_id"></a> [public\_dns\_id](#input\_public\_dns\_id) | ID of public DNS | `string` | `"Z07150253A0MNSTGYQG5P"` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | SSH public key for EC2 instance access | `string` | `"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+sBJl4PYrY+DEjXFU8QUR2wGrZruh/PETMkr585aIv/F06K7vcpR012J9cjh3Ib14Kx5PAHhrm2r/jAnMPLaBZinJIDJGGuc/Tv/m/3P39Yl/QvfTZ/A2Cjy0g6Igmc4C3Kd6T0WBRqxWRxM3yRJRuq2Iv9UDCAasQ/UFZ4RAWiPWkrQVWsJvkkEXcJ/TciV0+DBodXTaQQ1Af8a8tHuzD9m5ALkdgpmjqwnrNwrJCKy4R7Kn1ZcDMn0ajrVux/ejXrPch8APzC4iS2dlGel+hbHHpeAszkiFZpNMZ6SOH2u6Qq5viPffMKoAM00m7MvEfFziRx/EDSFul1Wk78pC599Q1QtVGaDIvQZwyRRZoOCOqWc+PaBnUa43AcETEOQt+7BylIpxczvi0NcIemyeisXtxCrfTZk6rZHF3r/NeSKHEUxadTXvPZHjkS2l4hzqHwGCfpEOIKNpBXRWchcm4cnMuXh6/ZUTda5BsYGZjX74KfTxrBkOxz0+J6HPUws= fjacquet@mm-fj.ljf.home"` | no |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | AWS secret key (prefer using IAM roles or AWS SSO instead) | `string` | `""` | no |

## Outputs

## Outputs

No outputs.

<!-- END_TF_DOCS -->