#!/bin/bash
sudo yum -y upgrade
sudo yum -y install wget numactl  xorg-x11-xauth unzip  libXrender
sudo yum -y install binutils ksh
sudo yum -y install compat-libstdc++-33  compat-libstdc++-33.i686
sudo yum -y install gcc gcc-c++
sudo yum -y install glibc glibc.i686
sudo yum -y install glibc-devel glibc-devel.i686
sudo yum -y install libgcc libgcc.i686
sudo yum -y install libstdc++ libstdc++.i686
sudo yum -y install libstdc++-devel libstdc++-devel.i686
sudo yum -y install libaio libaio.i686
sudo yum -y install libaio-devel libaio-devel.i686
sudo yum -y install libXext libXext.i686
sudo yum -y install libXtst libXtst.i686
sudo yum -y install libX11 libX11.i686
sudo yum -y install libXau libXau.i686
sudo yum -y install libxcb libxcb.i686
sudo yum -y install libXi libXi.i686
sudo yum -y install make sysstat
sudo yum -y install unixODBC unixODBC-devel
sudo yum -y install zlib-devel zlib-devel.i686
sudo yum -y install smartmontools compat-libcap1
sudo wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm #DevSkim: ignore DS137138 
sudo rpm -ivh epel-release-7-9.noarch.rpm
sudo yum -y install rlwrap
sudo yum -y install cockpit cockpit-storaged
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/" /etc/ssh/sshd_config
sudo sed -i "s/#X11DisplayOffset 10/X11DisplayOffset 10/" /etc/ssh/sshd_config
sudo sed -i "s/#X11UseLocalhost yes/X11UseLocalhost yes/" /etc/ssh/sshd_config
sudo sed -i "s/enforce/permissive/" /etc/selinux/config
sudo systemctl restart sshd
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo groupadd -g 54321 oinstall
sudo groupadd -g 54322 dba
sudo groupadd -g 54323 oper
sudo groupadd -g 54324 backupdba
sudo groupadd -g 54325 dgdba
sudo groupadd -g 54326 kmdba
sudo groupadd -g 54327 asmdba
sudo groupadd -g 54328 asmoper
sudo groupadd -g 54329 asmadmin

sudo useradd -u 54321 -g oinstall -G dba,oper oracle
sudo mkfs.xfs /dev/xvdb
sudo -- sh -c 'echo "/dev/xvdb		/u01				xfs     defaults        0 0" >> /etc/fstab'
sudo mkdir -p /u01
sudo mkdir -p /u01/app/oracle/product/12.2/db_1
sudo chown -R oracle:oinstall /u01
sudo chmod -R 775 /u01
sudo mount -a
sudo -- sh -c 'echo "fs.file-max = 6815744" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "kernel.sem = 250 32000 100 128" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "kernel.shmmni = 4096" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "kernel.shmall = 1073741824" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "kernel.shmmax = 4398046511104" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "kernel.panic_on_oops = 1" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "net.core.rmem_default = 262144" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "net.core.rmem_max = 4194304" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "net.core.wmem_default = 262144" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "net.core.wmem_max = 1048576" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "net.ipv4.conf.all.rp_filter = 2" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "net.ipv4.conf.default.rp_filter = 2" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "fs.aio-max-nr = 1048576" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "net.ipv4.ip_local_port_range = 9000 65500" >> /etc/sysctl.conf'
sudo -- sh -c 'echo "export PATH=$PATH:/usr/openv/netbackup/bin:/usr/openv/netbackup/bin/admincmd:/usr/openv/netbackup/bin/goodies:/usr/openv/netbackup/bin/support" >> /etc/profile.d/netbackup.sh'
sudo sysctl -p
sudo -- sh -c 'echo "oracle   soft   nofile    1024" >> /etc/security/limits.conf'
sudo -- sh -c 'echo "oracle   hard   nofile    65536" >> /etc/security/limits.conf'
sudo -- sh -c 'echo "oracle   soft   nproc    16384" >> /etc/security/limits.conf'
sudo -- sh -c 'echo "oracle   hard   nproc    16384" >> /etc/security/limits.conf'
sudo -- sh -c 'echo "oracle   soft   stack    10240" >> /etc/security/limits.conf'
sudo -- sh -c 'echo "oracle   hard   stack    32768" >> /etc/security/limits.conf'
sudo -- sh -c 'echo "oracle   hard   memlock    134217728" >> /etc/security/limits.conf'
sudo -- sh -c 'echo "oracle   soft   memlock    134217728" >> /etc/security/limits.conf'

sudo yum install python
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
sudo pip install awscli
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) #DevSkim: ignore DS137138 
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}') #DevSkim: ignore DS137138 
HOSTNAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --region=$REGION --output=text |awk '{print $5}')
sudo hostnamectl  set-hostname $HOSTNAME.evlab.ch

sudo sed -i "s/127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4/127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 $HOSTNAME/" /etc/hosts
cat >> oracle.sh << EOF
# Oracle Settings
export TMP=/tmp
export TMPDIR=$TMP

export ORACLE_HOSTNAME=oracle-0.evlab.ch
export ORACLE_UNQNAME=cdb1
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/12.1.0.2/db_1
export ORACLE_SID=cdb1

export PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
alias rlsqlplus='rlwrap sqlplus'
alias rlrman='rlwrap rman'
EOF
cd /u01
sudo wget http://installers-fja.s3-website-eu-west-1.amazonaws.com/linuxx64_12201_database.zip #DevSkim: ignore DS137138 
#sudo mv epel-release-7-9.noarch.rpm linuxx64_12201_database.zip /u01/
sudo unzip /u01/linuxx64_12201_database.zip
sudo chown -R oracle:dba /u01
sudo chmod 755 oracle.sh
sudo cp oracle.sh /etc/profile.d/oracle.sh
sudo cp -r .ssh/ /home/oracle/
sudo chown -R oracle:dba /home/oracle/

sudo reboot
