#!/usr/bin/env bash

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) #DevSkim: ignore DS137138
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region=$REGION --output=text |awk '{print $5}')
MYSQLROOT=$(aws secretsmanager get-secret-value --secret-id "evlab/glpi/mysqlroot" --output json|jq -r '.SecretString'|jq -r '.mysqlroot')
MYSQLUSER=$(aws secretsmanager get-secret-value --secret-id "evlab/glpi/mysqluser" --output json|jq -r '.SecretString'|jq -r '.mysqlroot')
MYSQLDB=glpidb

setenforce 0

wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm
subscription-manager repos --enable=rhel-7-server-optional-rpms
yum install httpd php php-{gd,mysql,mbstring} mariadb-server 
yum install  mariadb-server glpi

systemctl start httpd mariadb
systemctl enable httpd mariadb
systemctl is-enabled httpd mariadb
firewall-cmd --zone=public --add-port=http/tcp --permanent
firewall-cmd --zone=public --add-port=https/tcp --permanent
firewall-cmd --reload 

mysql -u root << EOF
CREATE DATABASE $MYSQLDB;
GRANT ALL PRIVILEGES ON $MYSQLDB.* TO utilisateur_glpi@localhost IDENTIFIED BY $MYSQLUSER;
FLUSH PRIVILEGES;
EXIT;
EOF

systemctl reload httpd