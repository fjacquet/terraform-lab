Initialize-AWSDefaults
$secret = (Get-SECSecretValue -SecretId "evlab/ad/joinuser" -region eu-west-1).SecretString 
$username = "joinuser"
$password =  ConvertTo-SecureString -AsPlainText -Force $secret
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password
Write-Output 'set DNS'
Get-NetAdapter -Physical | Set-DnsClientServerAddress -ServerAddresses ("10.0.51.110","10.0.52.158")
Write-Output 'Set suffix'
Set-DnsClientGlobalSetting -SuffixSearchList ("evlab.ch","eu-west-1.ec2-utilities.amazonaws.com","us-east-1.ec2-utilities.amazonaws.com","eu-west-1.compute.internal")
Write-Output 'Join domain'
Add-Computer –domainname "evlab.ch" -Credential $Credential -Restart –Force
