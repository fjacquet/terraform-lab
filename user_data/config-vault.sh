#!/usr/bin/env bash
yum upgrade -y
yum install wget httpd fontconfig -y

yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

yum upgrade -y
yum install --enablerepo=epel python2-pip.noarch python34-pip.noarch cockpit cockpit-storaged jq -y

pip install --upgrade pip
pip install awscli --upgrade --user
export PATH=$PATH:/root/.local/bin
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)                                               #DevSkim: ignore DS137138
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region="$REGION" --output=text | grep Name | awk '{print $5}')
FQDN="$HOSTNAME.ez-lab.xyz"
hostnamectl set-hostname "$FQDN"

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt install vault