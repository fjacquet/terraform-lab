# terraform-lab

We all need to create a set of VM to perform some labs. Thanks to terraforming, it can be very simple to automate.

Some variables are still hardcoded to simplify writing. Maybe it will go in parameter later

## Github

You should already know my Github if you read this

## SonarCloud status

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=fjacquet_terraform-lab&metric=alert_status)](https://sonarcloud.io/dashboard?id=fjacquet_terraform-lab)
[![Terraform](https://github.com/fjacquet/terraform-lab/actions/workflows/terraform.yml/badge.svg)](https://github.com/fjacquet/terraform-lab/actions/workflows/terraform.yml)
[![Build](https://github.com/fjacquet/terraform-lab/actions/workflows/build.yml/badge.svg)](https://github.com/fjacquet/terraform-lab/actions/workflows/build.yml)
[![Known Vulnerabilities](https://snyk.io/test/github/fjacquet/terraform-lab/badge.svg)](https://snyk.io/test/github/fjacquet/terraform-lab)
## SSH

An ssh key must be set up, the public key should be declared in variable public_key

## AWS

A valid account must exist for terraform usage

## EC2

Normally, I use t3.medium except if the application needs more

## S3

I use an S3 repository named installers-fja, private. Remember to replace the name in your case.

## Secrets management

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

## ansible

Be ready to install ansible (pywinrm and boto3 are a must )
```bash
pip3 install -r ./requirements.txt
ansible-galaxy install -r requirements.yml
```