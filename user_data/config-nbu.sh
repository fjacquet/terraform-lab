#!/bin/bash
sudo yum -y upgrade
sudo yum -y install wget libaio numactl atop htop nfs-utils xorg-x11-xauth  libXtst nfs-utils
sudo wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm #DevSkim: ignore DS137138 
sudo rpm -ivh epel-release-7-9.noarch.rpm
sudo yum -y install cockpit cockpit-storaged

sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old
sudo -- sh -c '#!/bin/bash' >> /etc/profile.d/nbu.sh
sudo -- sh -c 'echo "export PATH=$PATH:/usr/openv/netbackup/bin:/usr/openv/netbackup/bin/admincmd:/usr/openv/netbackup/bin/goodies:/usr/openv/netbackup/bin/support:/usr/openv/netbackup/bin/driver:/usr/openv/pdde/pdcr/bin:/usr/openv/volmgr/bin/"' >> /etc/profile.d/nbu.sh
sudo chmod 755 /etc/profile.d/nbu.sh
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/" /etc/ssh/sshd_config
sudo sed -i "s/#X11DisplayOffset 10/X11DisplayOffset 10/" /etc/ssh/sshd_config
sudo sed -i "s/#X11UseLocalhost yes/X11UseLocalhost yes/" /etc/ssh/sshd_config
sudo sed -i "s/enforce/permissive/" /etc/selinux/config
sudo systemctl restart sshd
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo groupadd nbwebgrp
sudo useradd -g nbwebgrp -c 'NetBackup Web Services account' -d /usr/openv/wmc nbwebsvc
sudo mkfs.xfs /dev/xvdb
sudo mkfs.xfs /dev/xvdc
sudo -- sh -c 'echo "/dev/xvdb		/usr/openv				xfs     defaults        0 0" >> /etc/fstab'
sudo -- sh -c 'echo "/dev/xvdc		/backups				xfs     defaults        0 0" >> /etc/fstab'
sudo mkdir -p /usr/openv
sudo mkdir -p /backups

sudo mount -a
sudo mkdir -p /backups/dr
sudo mkdir -p /backups/msdp
sudo mkdir -p /backups/simple
cd /backups
sudo wget https://s3-eu-west-1.amazonaws.com/installers-fja/NNetBackup_8.1.2Beta5_LinuxR_x86_64.tar.gz
tar xzf NNetBackup_8.1.2Beta5_LinuxR_x86_64.tar.gz


sudo -- sh -c 'echo "kernel.sem=300  307200  32  1024" >> /etc/sysctl.conf'
sudo sysctl -p
sudo -- sh -c 'echo "*               soft    core            0" >> /etc/security/limits.conf'
sudo -- sh -c 'echo "*               hard    core            0" >> /etc/security/limits.conf'
sudo -- sh -c 'echo "*               soft    nofile            20480" >> /etc/security/limits.conf'
sudo -- sh -c 'echo "*               hard    nofile            20480" >> /etc/security/limits.conf'
sudo yum install python
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
sudo pip install awscli
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) #DevSkim: ignore DS137138 
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138 
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region=$REGION --output=text |awk '{print $5}')
sudo hostnamectl  set-hostname $HOSTNAME.evlab.ch
# sudo hostnamectl  set-hostname nbu-0.evlab.ch
#sudo sed -i "s/127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4/127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 /" /etc/hosts


sudo reboot