install-windowsfeature FS-NFS-Service,NFS-Client
# Set NFS on manual
Set-Service NfsClnt -startuptype "manual"
Set-Service NfsService -startuptype "manual"
