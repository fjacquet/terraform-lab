#!/usr/bin/env bash
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