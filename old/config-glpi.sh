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

yum install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm

yum upgrade -y
yum --enablerepo=remi,remi-glpi93,remi-php73,epel --disablerepo=amzn2-core install glpi jq glpi-* php php-gd php-mysql php-mcrypt php-apcu php-xmlrpc php-pecl-zendopcache php-ldap php-imap php-mbstring php-simplexml php-xml -y

yum clean all
rm -rf /var/cache/yum

cat >/etc/yum.repos.d/mariadb.repo <<EOF
# MariaDB 10.3 RedHat repository list - created 2018-10-13 16:11 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/rhel7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
enabled=1
EOF
yum upgrade -y
yum install MariaDB-server MariaDB-client -y

# MYSQLROOT=$(aws secretsmanager get-secret-value --secret-id "ez-lab.xyz/glpi/mysqlroot" --region=$REGION  --output json|jq -r '.SecretString')
# MYSQLUSER=$(aws secretsmanager get-secret-value --secret-id "ez-lab.xyz/glpi/mysqluser" --region=$REGION  --output json|jq -r '.SecretString')
# MYSQLDB=glpidb

sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config
sed -i 's/Allow from 127.0.0.1/Allow from 10.0.*.*/' /etc/httpd/conf.d/glpi.conf
sed -i 's/Allow from ::1//' /etc/httpd/conf.d/glpi.conf
setenforce 0

systemctl start httpd mariadb cockpit
systemctl enable httpd mariadb cockpit
systemctl is-enabled httpd mariadb

reboot
