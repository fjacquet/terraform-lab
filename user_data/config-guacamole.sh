#!/bin/bash
yum -y install deltarpm 
yum -y install https://dl.fedoraproject.org/pub/epel//epel-release-latest-7.noarch.rpm
yum -y upgrade
yum -y install wget libaio numactl atop htop nfs-utils xorg-x11-xauth  libXtst nfs-utils cockpit python jq

curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py
pip install awscli


INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) #DevSkim: ignore DS137138
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region=$REGION --output=text|grep Name |awk '{print $5}')
MYSQLROOT=$(aws secretsmanager get-secret-value --secret-id "evlab.ch/guacamole/mysqlroot" --region=$REGION --output json|jq -r '.SecretString')
MYSQLDB=evguacamole
MYSQLUSER=evguacamole
MYSQLPASS=$(aws secretsmanager get-secret-value --secret-id "evlab.ch/guacamole/mysqluser" --region=$REGION  --output json |jq -r '.SecretString')
KEYSTORE=$(aws secretsmanager get-secret-value --secret-id "evlab.ch/guacamole/keystore" --region=$REGION  --output json |jq -r '.SecretString')
MAIL=$(aws secretsmanager get-secret-value --secret-id "evlab.ch/guacamole/mail" --region=$REGION  --output json|jq -r '.SecretString')

hostnamectl  set-hostname "$HOSTNAME.evlab.ch"
curl https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/Install-guacamole.sh -o /install-guacamole.sh
chmod 755 /install-guacamole.sh
echo  "/install-guacamole.sh -a $MYSQLROOT -b $MYSQLDB -c $MYSQLUSER -d $MYSQLPASS -e $KEYSTORE -l evlab.ch:$MAIL -s -p yes " > /install.sh
chmod 755 /install.sh
reboot