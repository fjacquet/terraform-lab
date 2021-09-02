#!/usr/bin/env bash

yum -y install deltarpm
yum -y install https://dl.fedoraproject.org/pub/epel//epel-release-latest-8.noarch.rpm
yum -y upgrade
yum -y install wget libaio numactl atop htop nfs-utils xorg-x11-xauth libXtst nfs-utils cockpit python jq

curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python3 get-pip.py
pip3 install awscli

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)                                               #DevSkim: ignore DS137138
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region="$REGION" --output=text | grep Name | awk '{print $5}')
MYSQLROOT=$(aws secretsmanager get-secret-value --secret-id "ez-lab.xyz/guacamole/mysqlroot" --region="$REGION" --output json | jq -r '.SecretString')
MYSQLDB=evguacamole
MYSQLUSER=evguacamole
MYSQLPASS=$(aws secretsmanager get-secret-value --secret-id "ez-lab.xyz/guacamole/mysqluser" --region="$REGION" --output json | jq -r '.SecretString')
KEYSTORE=$(aws secretsmanager get-secret-value --secret-id "ez-lab.xyz/guacamole/keystore" --region="$REGION" --output json | jq -r '.SecretString')
MAIL=$(aws secretsmanager get-secret-value --secret-id "ez-lab.xyz/guacamole/mail" --region="$REGION" --output json | jq -r '.SecretString')

# hostnamectl set-hostname "$HOSTNAME.ez-lab.xyz"
# curl https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/Install-guacamole.sh -o /install-guacamole.sh
# chmod 755 /install-guacamole.sh
# echo "/install-guacamole.sh -a $MYSQLROOT -b $MYSQLDB -c $MYSQLUSER -d $MYSQLPASS -e $KEYSTORE -l ez-lab.xyz:$MAIL -s -p yes " >/install.sh
# chmod 755 /install.sh
# reboot
