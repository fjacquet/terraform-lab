Initialize-AWSDefaults
$region = 'eu-west-1'
$secret = (Get-SECSecretValue -SecretId "evlab.ch/ad/joinuser" -region $regiob).SecretString 
$username = "joinuser"
$password = ConvertTo-SecureString -AsPlainText -Force $secret
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
$domain = 'evlab.ch'
Write-Output 'set DNS'
Get-NetAdapter -Physical | Set-DnsClientServerAddress -ServerAddresses (
    "10.0.51.110",
    "10.0.52.158")
Write-Output 'Set suffix'
Set-DnsClientGlobalSetting -SuffixSearchList (
    $domain,
    "$($region).ec2-utilities.amazonaws.com",
    "us-east-1.ec2-utilities.amazonaws.com",
    "$($region).compute.internal")
Write-Output 'Join domain'
Add-Computer –domainname $domain -Credential $Credential -Restart –Force
