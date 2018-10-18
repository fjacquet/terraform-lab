Initialize-AWSDefaults
$domain = "evlab.ch"
$secret = (Get-SECSecretValue -SecretId "$($domain)/ad/joinuser").SecretString 
$username = "joinuser"
$password = $secret | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

Install-ADDSForest `
   -CreateDnsDelegation:$false `
   -DatabasePath "C:\Windows\NTDS" `
   -DomainMode 7 `
   -DomainName $domain  `
   -DomainNetbiosName "EVLAB" `
   -ForestMode 7 `
   -InstallDns:$true `
   -SafeModeAdministratorPassword $password `
   -LogPath "C:\Windows\NTDS" `
   -NoRebootOnCompletion:$false `
   -SysvolPath "C:\Windows\SYSVOL" `
   -Force:$true

Restart-Computer -Force:$true -Confirm:$false
