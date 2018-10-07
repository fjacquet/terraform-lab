# terraform-lab

We all need to create a set of VM to perform some labs. Thanks to terraform, it can be very simple to automate.

Some variable are still hard coded to simplify writing. Maybe will go in parameter later

## Github

You should already know my github if you read this

## SSH 

An ssh key must be setup, public key should in variable public_key

## AWS

A valid account must exist for terraform

## EC2 

Normally I use t2.medium except if application needs more

## S3

I use a S3 repository named installers-fja, private, remember to replace name in case of.

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