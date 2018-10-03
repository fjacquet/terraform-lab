Initialize-AWSDefaults
$secret = Get-SECSecretValue -SecretId "prod/ad/joinuser" |ConvertFrom-Json
$username = $secret.value 
$password = $secret.key| ConvertTo-SecureString -AsPlainText -Force

Install-ADDSDomainController `
    -InstallDns `
    -Credential (Get-Credential "EVLAB\fjacquet") `
    -DomainName "evlab.ch"