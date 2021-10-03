# terraform-lab

We all need to create a set of VM to perform some labs. Thanks to terraforming, it can be very simple to automate.

Some variables are still hardcoded to simplify writing. Maybe it will go in parameter later


## Project status
### Github

You should already know my Github if you read this :)

### SonarCloud status
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=fjacquet_terraform-lab&metric=alert_status)](https://sonarcloud.io/dashboard?id=fjacquet_terraform-lab)

### Terraform cloud build status
[![Build](https://github.com/fjacquet/terraform-lab/actions/workflows/build.yml/badge.svg)](https://github.com/fjacquet/terraform-lab/actions/workflows/build.yml)

### Snyk status
[![Known Vulnerabilities](https://snyk.io/test/github/fjacquet/terraform-lab/badge.svg)](https://snyk.io/test/github/fjacquet/terraform-lab)

## Configuration
### Shell

To fix winrm on mac set
```bash
no_proxy="*"
```

To speedup terraform set

```bash
TF_CLI_ARGS="-parallelism=50"
TFE_PARALLELISM=50
TF_REGISTRY_CLIENT_TIMEOUT=15
export TF_REGISTRY_CLIENT_TIMEOUT
export TF_CLI_ARGS
export TFE_PARALLELISM
```

NB must have execution local if you use https://app.terraform.io/

### ansible

Be ready to install ansible (pypsrp and boto3 are a must)
```bash
pip3 install -r ./requirements.txt
ansible-galaxy install -r requirements.yml
```

## ssh
To access private network, you can use `.ssh/config`  like :
```bash
Host bastion
        Hostname bastion.ez-lab.xyz
        IdentityFile ~/.ssh/aws
        User admin
        ControlMaster auto
        ControlPath ~/.ansible/cp/ssh-%r
        ControlPersist 5m


Host *.compute.internal
        ProxyCommand ssh -C -W %h:%p bastion
        IdentityFile ~/.ssh/aws
        User admin
Host *.compute.amazonaws.com
        ProxyCommand ssh -C -W %h:%p bastion
        IdentityFile ~/.ssh/aws
```

where bastion.ez-lab.xyz is a PUBLIC cname to your bastion

An ssh key must be set up, the public key should be declared in variable public_key

## Ressources
### AWS

A valid account must exist for terraform usage

#### EC2

Normally, I use t3.medium except if the application needs more

#### S3

I use an S3 repository named installers-fja, private. Remember to replace the name in your case.

#### Secrets management

We use AWS secrets manager to avoid password in scripts.
Need to create some aws secrets :

* ezlab/ad/joinuser
* ezlab/ad/fjacquet
* ezlab/guacamole/mysqlroot
* ezlab/guacamole/mysqluser
* ezlab/glpi/mysqlroot
* ezlab/glpi/mysqluser
* ezlab/guacamole/keystore
* ezlab/guacamole/mail
* ezlab/sharepoint/sp_farm
* ezlab/sharepoint/sp_services
* ezlab/sharepoint/sp_portalAppPool
* ezlab/sharepoint/sp_profilesAppPool
* ezlab/sharepoint/sp_searchService
* ezlab/sharepoint/sp_cacheSuperUser
* ezlab/sharepoint/sp_cacheSuperReader
* ezlab/sql/svc-sql
* ezlab/pki/svc-ndes

## Run

1. Adapt variables.tf to deploy the VM you want
1. run `terraform plan` to validate what will happens
1. if ok, start `terraform apply`
1. then when vm are baked, start ansible
- `ansible-parallel playbooks/system/*yml` to get the minimum informations
- `ansible-parallel playbooks/apps/*yml` to get the preconfigurations

## Build order
Some dependencies always exists :
- deploy guacamole to get bastion jump host
- when you want windows services, start by deploying a "first" DC
