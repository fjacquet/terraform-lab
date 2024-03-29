#!/usr/bin/env bash
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
yum -y upgrade
yum -y install wget libaio numactl atop htop nfs-utils xorg-x11-xauth libXtst nfs-utils cockpit cockpit-storaged xclock xauth firefox

cat >>/etc/profile.d/nbu.sh <<EOF
#!/usr/bin/env bash
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
cat >>/etc/fstab <<EOF
/dev/xvdb		/usr/openv				xfs     defaults        0 0
/dev/xvdc		/backups				xfs     defaults        0 0
EOF

sudo mkdir -p /usr/openv
sudo mkdir -p /backups

mount -a
mkdir -p /backups/dr
mkdir -p /backups/msdp
mkdir -p /backups/simple

echo "kernel.sem=300  307200  32  1024" >>/etc/sysctl.conf
sysctl -p
cat >>/etc/security/limits.conf <<EOF
*               soft    core            0
*               hard    core            0
*               soft    nofile            20480
*               hard    nofile            20480
EOF
yum install python
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py
pip install awscli
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)                                               #DevSkim: ignore DS137138
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region="$REGION" --output=text | grep Name | awk '{print $5}')
hostnamectl set-hostname "$HOSTNAME".ez-lab.xyz

cd /backups || exit
rm -rf .aws/credentials

for i in NetBackup_8.1.3Beta2_LinuxR_x86_64.tar.gz NetBackup_8.1.3Beta2_Win.zip; do
  aws s3 cp s3://installers-fja/$i /backups/$i
  tar xzf /backups/$i
done

systemctl start cockpit
systemctl enable cockpit

reboot
