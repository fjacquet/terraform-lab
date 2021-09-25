#!/usr/bin/env bash

curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py
pip install awscli

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)                                               #DevSkim: ignore DS137138
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region="$REGION" --output=text | awk '{print $5}')

hostnamectl set-hostname "$HOSTNAME".ez-lab.xyz
