Initialize-AWSDefaults
$secret = Get-SECSecretValue -SecretId "prod/ad/joinuser" |ConvertFrom-Json
$username = $secret.value 
$password = $secret.key| ConvertTo-SecureString -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
Get-NetAdapter -Name ethernet |Set-DnsClientServerAddress -ServerAddresses ("10.0.51.57","10.0.52.211") 
Set-DnsClientGlobalSetting -SuffixSearchList ("evlab.ch","eu-west-1.ec2-utilities.amazonaws.com","us-east-1.ec2-utilities.amazonaws.com", "eu-west-1.compute.internal")
add-computer –domainname "evlab.ch" -Credential "evlab\fjacquet" -restart –force 