#!/usr/bin/env bash
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
yum -y upgrade
yum -y install https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
# yum -y install wget numactl  xorg-x11-xauth unzip  libXrender
# yum -y install binutils ksh
# yum -y install compat-libstdc++-33  compat-libstdc++-33.i686
# yum -y install gcc gcc-c++
# yum -y install glibc glibc.i686
# yum -y install glibc-devel glibc-devel.i686
# yum -y install libgcc libgcc.i686
# yum -y install libstdc++ libstdc++.i686
# yum -y install libstdc++-devel libstdc++-devel.i686
# yum -y install libaio libaio.i686
# yum -y install libaio-devel libaio-devel.i686
# yum -y install libXext libXext.i686
# yum -y install libXtst libXtst.i686
# yum -y install libX11 libX11.i686
# yum -y install libXau libXau.i686
# yum -y install libxcb libxcb.i686
# yum -y install libXi libXi.i686
# yum -y install make sysstat
# yum -y install unixODBC unixODBC-devel
# yum -y install zlib-devel zlib-devel.i686
# yum -y install smartmontools compat-libcap1
yum -y install rlwrap
yum -y install cockpit cockpit-storaged
sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config


groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper
groupadd -g 54324 backupdba
groupadd -g 54325 dgdba
groupadd -g 54326 kmdba
groupadd -g 54327 asmdba
groupadd -g 54328 asmoper
groupadd -g 54329 asmadmin
useradd -u 54321 -g oinstall -G dba,oper oracle

mkdir -p /u01/app/oracle/product/12.2/db_1
mkfs.xfs /dev/nvme1n1
echo "/dev/nvme1n1      /u01     xfs     defaults     0 0 " >> /etc/fstab


# chown -R oracle:oinstall /u01
# chmod -R 775 /u01
# mount -a
# cat >> /etc/sysctl.conf << EOF
# fs.file-max = 6815744
# kernel.sem = 250 32000 100 128
# kernel.shmmni = 4096
# kernel.shmall = 1073741824
# kernel.shmmax = 4398046511104
# kernel.panic_on_oops = 1
# net.core.rmem_default = 262144
# net.core.rmem_max = 4194304
# net.core.wmem_default = 262144
# net.core.wmem_max = 1048576
# net.ipv4.conf.all.rp_filter = 2
# net.ipv4.conf.default.rp_filter = 2
# fs.aio-max-nr = 1048576
# net.ipv4.ip_local_port_range = 9000 65500
# EOF

echo "export PATH=\$PATH:/usr/openv/netbackup/bin:/usr/openv/netbackup/bin/admincmd:/usr/openv/netbackup/bin/goodies:/usr/openv/netbackup/bin/support" >> /etc/profile.d/netbackup.sh
chmod 755  /etc/profile.d/netbackup.sh
sysctl -p
# cat >> /etc/security/limits.conf << EOF
# oracle   soft   nofile    1024
# oracle   hard   nofile    65536
# oracle   soft   nproc    16384
# oracle   hard   nproc    16384
# oracle   soft   stack    10240
# oracle   hard   stack    32768
# oracle   hard   memlock    134217728
# oracle   soft   memlock    134217728
EOF

yum -y install python
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py
pip install awscli
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) #DevSkim: ignore DS137138
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region=$REGION --output=text |grep Name|awk '{print $5}')
FQDN="$HOSTNAME.ez-lab.xyz"
hostnamectl set-hostname $FQDN

# sudo sed -i "s/127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4/127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 $HOSTNAME/" /etc/hosts
# cat >> oracle.sh << EOF
# # Oracle Settings
# export TMP=/tmp
# export TMPDIR=\$TMP

# export ORACLE_HOSTNAME=$FQDN
# export ORACLE_UNQNAME=cdb1
# export ORACLE_BASE=/u01/app/oracle
# export ORACLE_HOME=\$ORACLE_BASE/product/12.1.0.2/db_1
# export ORACLE_SID=cdb1

# export PATH=/usr/sbin:\$PATH
# export PATH=\$ORACLE_HOME/bin:\$PATH

# export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
# export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
# alias rlsqlplus='rlwrap sqlplus'
# alias rlrman='rlwrap rman'
# EOF
# mv oracle.sh /etc/profile.d/
# chmod 755  /etc/profile.d/oracle.sh

cd /u01
rm -rf .aws/credentials


aws s3 cp s3://installers-fja/oracle-database-ee-18c-1.0-1.x86_64.rpm   /u01/oracle-database-ee-18c-1.0-1.x86_64.rpm

# unzip /u01/linuxx64_12201_database.zip
chown -R oracle:dba /u01
cp -r /home/ec2-user/.ssh/ /home/oracle/
chown -R oracle:dba /home/oracle/.ssh/
rpm -ivh /u01/oracle-database-ee-18c-1.0-1.x86_64.rpm
systemctl start cockpit
systemctl enable cockpit
reboot