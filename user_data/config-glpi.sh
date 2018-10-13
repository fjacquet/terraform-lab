#!/usr/bin/env bash
sudo yum install python wget -y
yum update rh-amazon-rhui-client

wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm
# subscription-manager repos --enable=rhel-7-server-optional-rpms
 yum install python2-pip.noarch -y
 pip install --upgrade pip
  export PATH=$PATH:/root/.local/bin

pip install awscli --upgrade --user
yum install php54-php-mbstring.x86_64 -y
yum install httpd mariadb-server jq -y 
yum -y install httpd php php-mysql php-pdo php-gd php-mbstring  php-imap php-ldapyum -y install httpd php php-mysql php-pdo php-gd php-mbstring  php-imap php-ldap
yum install  mariadb-server glpi


HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region=$REGION --output=text |awk '{print $5}')
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) #DevSkim: ignore DS137138
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138
MYSQLROOT=$(aws secretsmanager get-secret-value --secret-id "evlab/glpi/mysqlroot" --region=$REGION  --output json|jq -r '.SecretString')
MYSQLUSER=$(aws secretsmanager get-secret-value --secret-id "evlab/glpi/mysqluser" --region=$REGION  --output json|jq -r '.SecretString')
MYSQLDB=glpidb
sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config

setenforce 0

systemctl start httpd mariadb
systemctl enable httpd mariadb
systemctl is-enabled httpd mariadb
# firewall-cmd --zone=public --add-port=http/tcp --permanent
# firewall-cmd --zone=public --add-port=https/tcp --permanent
# firewall-cmd --reload 

echo "DROP DATABASE $MYSQLDB;"  > input.sql
echo "CREATE DATABASE $MYSQLDB;"  >> input.sql
echo "CREATE USER 'glpi'@'localhost' IDENTIFIED BY \"$MYSQLUSER\";" >> input.sql
echo "GRANT ALL PRIVILEGES ON $MYSQLDB.* TO 'glpi'@'localhost' ;" >> input.sql
echo "FLUSH PRIVILEGES;">> input.sql
echo "EXIT;" >> input.sql
mysql -u root < input.sql

cd /var/www/html
wget https://github.com/glpi-project/glpi/releases/download/9.3.1/glpi-9.3.1.tgz
tar -xzf glpi-9.3.1.tgz
mv glpi glpi-9.3.1
ln -s  glpi-9.3.1 glpi
chmod -R 755 /var/www/glpi-9.3.1
chown -R apache:apache /var/www/glpi-9.3.1

systemctl reload httpd