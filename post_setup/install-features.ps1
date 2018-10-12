﻿# Install windows features
Write-Output 'add DSC'
Add-WindowsFeature -Name DSC-Service, GPMC, SNMP-Service, Bitlocker
# # Enable Remoting
Write-Output 'Enable winrm'
winrm qc
Write-Output 'Enable remoting'
Enable-PSRemoting –Force 


# WinRM service is already running on this machine.
# WinRM is not set up to allow remote access to this machine for management.
# The following changes must be made:

# Configure LocalAccountTokenFilterPolicy to grant administrative rights remotely to local users.