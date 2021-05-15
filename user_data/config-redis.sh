#!/usr/bin/env bash
yum upgrade -y
yum install wget httpd -y

yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

yum-config-manager –-enable --save epel
yum upgrade -y
yum install python2-pip.noarch python34-pip.noarch cockpit cockpit-storaged -y
yum install redis -y

yum-config-manager –-disable --save epel
yum clean all

pip install --upgrade pip
pip install awscli --upgrade --user
export PATH=$PATH:/root/.local/bin
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) #DevSkim: ignore DS137138
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region=$REGION --output=text |grep Name |awk '{print $5}')
PASSWD=$(aws secretsmanager get-secret-value --secret-id "evlab.ch/redis/root" --output json|jq -r '.SecretString')
FQDN="$HOSTNAME.evlab.ch"
hostnamectl set-hostname $FQDN

re

SECURE=$(echo $PASSWD | sha256sum)

sed -i "s/# requirepass foobared/requirepass $SECURE/" /etc/redis.conf
cat >> /etc/redis.conf << EOF
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command DEBUG ""
rename-command CONFIG ""
rename-command SHUTDOWN SHUTDOWN_MENOT
EOF
systemctl restart redis.service cockpit
systemctl enable redis cockpit
chmod 770 /var/lib/redis
chown redis:redis /etc/redis.conf
chmod 660 /etc/redis.conf

reboot