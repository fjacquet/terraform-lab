Initialize-AWSDefaults
$secret = (Get-SECSecretValue -SecretId "evlab.ch/ad/joinuser").SecretString | ConvertFrom-Json
$username = "joinuser"
$password = $secret.password | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

Install-ADDSForest `
   -CreateDnsDelegation:$false `
   -DatabasePath "C:\Windows\NTDS" `
   -DomainMode 7 `
   -DomainName "evlab.ch" `
   -DomainNetbiosName "EVLAB" `
   -ForestMode 7 `
   -InstallDns:$true `
   -SafeModeAdministratorPassword $password `
   -LogPath "C:\Windows\NTDS" `
   -NoRebootOnCompletion:$false `
   -SysvolPath "C:\Windows\SYSVOL" `
   -Force:$true

Restart-Computer -Force:$true -Confirm:$false
