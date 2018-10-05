Initialize-AWSDefaults
$secret = (Get-SECSecretValue -SecretId "prod/ad/joinuser").SecretString  |ConvertFrom-Json
$username = "joinuser"
$password = $secret.joinuser| ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

Install-ADDSDomainController `
    -InstallDns `
    -Credential $Credential `
    -DomainName "evlab.ch" `
    -Confirm:$false