Initialize-AWSDefaults
$region = 'eu-west-1'
$domain = 'evlab.ch'
$username = "joinuser"
$secret = (Get-SECSecretValue -SecretId "$($domain)/ad/$($username)" -region $region).SecretString 

$password = ConvertTo-SecureString `
    -AsPlainText `
    -Force $secret
$Credential = New-Object `
    -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $username, $password

Write-Output 'set DNS'
Get-NetAdapter -Physical `
    | Set-DnsClientServerAddress -ServerAddresses (
    "10.0.51.85",
    "10.0.52.144")
Write-Output 'Set suffix'
Set-DnsClientGlobalSetting -SuffixSearchList (
    $domain,
    "$($region).ec2-utilities.amazonaws.com",
    "us-east-1.ec2-utilities.amazonaws.com",
    "$($region).compute.internal")
Write-Output 'Join domain'
Add-Computer –domainname $domain `
    -Credential $Credential `
    -Restart:$false `
    –Force
