Install-ADDSForest `
   -CreateDnsDelegation:$false `
   -DatabasePath "C:\Windows\NTDS" `
   -DomainMode 7 `
   -DomainName "evlab.ch" `
   -DomainNetbiosName "EVLAB" `
   -ForestMode 7 `
   -InstallDns:$true `
   -LogPath "C:\Windows\NTDS" `
   -NoRebootOnCompletion:$false `
   -SysvolPath "C:\Windows\SYSVOL" `
   -Force:$true

restart-computer -Force:$true
