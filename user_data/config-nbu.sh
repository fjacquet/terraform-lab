#!/bin/bash
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y upgrade
yum -y install wget libaio numactl atop htop nfs-utils xorg-x11-xauth  libXtst nfs-utils
yum -y install cockpit cockpit-storaged

cat >> /etc/profile.d/nbu.sh << EOF
#!/bin/bash
export PATH=\$PATH:/usr/openv/netbackup/bin:/usr/openv/netbackup/bin/admincmd:/usr/openv/netbackup/bin/goodies:/usr/openv/netbackup/bin/support:/usr/openv/netbackup/bin/driver:/usr/openv/pdde/pdcr/bin:/usr/openv/volmgr/bin/
EOF
chmod 755 /etc/profile.d/nbu.sh

sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config
systemctl restart sshd
systemctl disable firewalld
systemctl stop firewalld
groupadd nbwebgrp
useradd -g nbwebgrp -c 'NetBackup Web Services account' -d /usr/openv/wmc nbwebsvc
mkfs.xfs /dev/xvdb
mkfs.xfs /dev/xvdc
sudo -- sh -c 'echo ≤"/dev/xvdb		/usr/openv				xfs     defaults        0 0" >> /etc/fstab'
sudo -- sh -c 'echo "/dev/xvdc		/backups				xfs     defaults        0 0" >> /etc/fstab'
sudo mkdir -p /usr/openv
sudo mkdir -p /backups

mount -a
mkdir -p /backups/dr
mkdir -p /backups/msdp
mkdir -p /backups/simple
cd /backups
sudo wget https://s3-eu-west-1.amazonaws.com/installers-fja/NNetBackup_8.1.2Beta5_LinuxR_x86_64.tar.gz
tar xzf NNetBackup_8.1.2Beta5_LinuxR_x86_64.tar.gz

echo "kernel.sem=300  307200  32  1024" >> /etc/sysctl.conf
sysctl -p
cat >> /etc/security/limits.conf << EOF
*               soft    core            0" >> /etc/security/limits.conf
*               hard    core            0" >> /etc/security/limits.conf
*               soft    nofile            20480" >> /etc/security/limits.conf
*               hard    nofile            20480" >> /etc/security/limits.conf
EOF
 yum install python
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py
pip install awscli
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) #DevSkim: ignore DS137138 
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138 
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region=$REGION --output=text |awk '{print $5}')
hostnamectl  set-hostname $HOSTNAME.evlab.ch
# sudo hostnamectl  set-hostname nbu-0.evlab.ch
#sudo sed -i "s/127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4/127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 /" /etc/hosts

reboot