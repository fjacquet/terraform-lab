# Install basic
install-windowsfeature DSC-Service,GPMC,SNMP-Service,Bitlocker
# Enable Remoting
winrm qc
Enable-PSRemoting –Force
