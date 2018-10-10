Install-WindowsFeature FS-NFS-Service,NFS-Client
# Set NFS on manual
Set-Service NfsClnt -StartupType "manual"
Set-Service NfsService -StartupType "manual"
