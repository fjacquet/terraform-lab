#!/usr/bin/env bash

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) #DevSkim: ignore DS137138
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region=$REGION --output=text |awk '{print $5}')
MYSQLROOT=$(aws secretsmanager get-secret-value --secret-id "ez-lab.xyz/glpi/mysqlroot" --output json|jq -r '.SecretString'|jq -r '.mysqlroot')
MYSQLUSER=$(aws secretsmanager get-secret-value --secret-id "ez-lab.xyz/glpi/mysqluser" --output json|jq -r '.SecretString'|jq -r '.mysqlroot')
MYSQLDB=glpidb

setenforce 0

wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
wget https://rpms.remirepo.net/enterprise/remi-release-8.rpm
rpm -Uvh remi-release-8.rpm epel-release-latest-8.noarch.rpm
subscription-manager repos --enable=rhel-7-server-optional-rpms

yum install  mariadb-server glpi

systemctl enable httpd
systemctl start httpd
systemctl enable mariadb
systemctl start mariad


mysql -u root << EOF
CREATE DATABASE $MYSQLDB;
GRANT ALL PRIVILEGES ON $MYSQLDB.* TO utilisateur_glpi@localhost IDENTIFIED BY $MYSQLUSER;
FLUSH PRIVILEGES;
EXIT;
EOF

mysql_secure_installation

systemctl reload httpd