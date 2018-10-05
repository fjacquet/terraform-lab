# Install basic
install-windowsfeature DSC-Service, GPMC, SNMP-Service, Bitlocker
winrm qc
Enable-PSRemoting –Force