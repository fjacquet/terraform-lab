# Install basic
Install-WindowsFeature DSC-Service,GPMC,SNMP-Service,Bitlocker
# Enable Remoting
winrm qc
Enable-PSRemoting –Force
