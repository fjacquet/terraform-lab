#!/bin/bash
# sudo yum -y upgrade
# sudo yum -y install wget libaio numactl atop htop nfs-utils xorg-x11-xauth  libXtst nfs-utils
# sudo wget http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm #DevSkim: ignore DS137138
# yum-config-manager --enable rhui-REGION-rhel-server-optional
# sudo rpm -ivh epel-release-7-11.noarch.rpm
# sudo yum -y install  git make gcc cockpit cockpit-storaged cairo-devel libwebp-devel libvorbis-devel pulseaudio-libs-devel libvncserver-devel libtelnet-devel libssh2-devel libjpeg-devel pango-devel libjpeg-turbo-devel libpng-devel uuid-devel freerdp-devel	ffmpeg-devel
# sudo yum install uuid uuid-devel uuid-c++ uuid-c++-devel uuid-dce uuid-dce-devel telnet omcat nginx
# sudo yum  yum -y install cairo-devel freerdp-devel gcc java-1.8.0-openjdk.x86_64 libguac libguac-client-rdp libguac-client-ssh libguac-client-vnc \
# libjpeg-turbo-devel libpng-devel libssh2-devel libtelnet-devel libvncserver-devel libvorbis-devel libwebp-devel openssl-devel pango-devel \
# pulseaudio-libs-devel terminus-fonts tomcat tomcat-admin-webapps tomcat-webapps uuid-devel

# sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old

# git clone git://github.com/apache/incubator-guacamole-server.git

# sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
# sudo sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/" /etc/ssh/sshd_config
# sudo sed -i "s/#X11DisplayOffset 10/X11DisplayOffset 10/" /etc/ssh/sshd_config
# sudo sed -i "s/#X11UseLocalhost yes/X11UseLocalhost yes/" /etc/ssh/sshd_config
# sudo sed -i "s/enforce/permissive/" /etc/selinux/config
# sudo systemctl restart sshd
# sudo systemctl disable firewalld
# sudo systemctl stop firewalld

# sudo -- sh -c 'echo "kernel.sem=300  307200  32  1024" >> /etc/sysctl.conf'
# sudo sysctl -p
# sudo -- sh -c 'echo "*               soft    core            0" >> /etc/security/limits.conf'
# sudo -- sh -c 'echo "*               hard    core            0" >> /etc/security/limits.conf'
# sudo -- sh -c 'echo "*               soft    nofile      20480" >> /etc/security/limits.conf'
# sudo -- sh -c 'echo "*               hard    nofile      20480" >> /etc/security/limits.conf'

# sudo yum install python
# curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
# sudo python get-pip.py
# sudo pip install awscli


INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) #DevSkim: ignore DS137138
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region=$REGION --output=text|grep Name |awk '{print $5}')
MYSQLROOT=$(aws secretsmanager get-secret-value --secret-id "evlab/guacamole/mysqlroot" --output json|jq -r '.SecretString')
MYSQLDB=evguacamole
MYSQLUSER=evguacamole
MYSQLPASS=$(aws secretsmanager get-secret-value --secret-id "evlab/guacamole/mysqluser" --output json |jq -r '.SecretString')
KEYSTORE=$(aws secretsmanager get-secret-value --secret-id "evlab/guacamole/keystore" --output json |jq -r '.SecretString')
MAIL=$(aws secretsmanager get-secret-value --secret-id "evlab/guacamole/mail" --output json|jq -r '.SecretString')

hostnamectl  set-hostname "$HOSTNAME.evlab.ch"
curl https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/install-guacamole.sh -o install-guacamole.sh
chmod 755 install-guacamole.sh
echo  "./install-guacamole.sh -a $MYSQLROOT -b $MYSQLDB -c $MYSQLUSER -d $MYSQLPASS -e $KEYSTORE -l evlab.ch:$MAIL -s -p yes " > /install.sh
reboot