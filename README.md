# terraform-lab

We all need to create a set of VM to perform some labs. Thanks to terraforming, it can be very simple to automate.

Some variables are still hardcoded to simplify writing. Maybe it will go in parameter later

## Github

You should already know my Github if you read this

## SonarCloud status

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=fjacquet_terraform-lab&metric=alert_status)](https://sonarcloud.io/dashboard?id=fjacquet_terraform-lab)
![Terraform plan](https://github.com/fjacquet/terraform-lab/actions/workflows/terraform.yml/badge.svg)
![SonarCloud](https://github.com/fjacquet/terraform-lab/actions/workflows/build.yml/badge.svg)
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

* evlab/ad/joinuser
* evlab/ad/fjacquet
* evlab/guacamole/mysqlroot
* evlab/guacamole/mysqluser
* evlab/glpi/mysqlroot
* evlab/glpi/mysqluser
* evlab/guacamole/keystore
* evlab/guacamole/mail
* evlab/sharepoint/sp_farm
* evlab/sharepoint/sp_services
* evlab/sharepoint/sp_portalAppPool
* evlab/sharepoint/sp_profilesAppPool
* evlab/sharepoint/sp_searchService
* evlab/sharepoint/sp_cacheSuperUser
* evlab/sharepoint/sp_cacheSuperReader
* evlab/sql/svc-sql
* evlab/pki/svc-ndes
