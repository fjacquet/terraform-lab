#!/usr/bin/bash
echo "export PATH=/usr/openv/netbackup/bin/:/usr/openv/netbackup/bin/admincmd/:/usr/openv/netbackup/bin/goodies/:/usr/openv/netbackup/bin/support/:/usr/openv/volmgr/bin/:$PATH" > /etc/profile.d/nbu.sh
chmod 755 /etc/profile.d/nbu.sh