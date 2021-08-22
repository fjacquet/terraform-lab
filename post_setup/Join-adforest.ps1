Initialize-AWSDefaults
$domain = "ez-lab.xyz"
$secret = (Get-SECSecretValue -SecretId "$($domain)/ad/joinuser").SecretString
$username = "joinuser"
$password = $secret | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

Get-NetAdapter -Physical | Set-DnsClientServerAddress -ServerAddresses (
    "10.0.51.85",
    "10.0.52.144"
)
Set-DnsClientGlobalSetting -SuffixSearchList (
    $($domain),
    "eu-west-1.ec2-utilities.amazonaws.com",
    "us-east-1.ec2-utilities.amazonaws.com",
    "eu-west-1.compute.internal")

Install-ADDSDomainController `
    -InstallDns `
    -Credential $Credential `
    -DomainName $($domain) `
    -SafeModeAdministratorPassword $password `
    -SiteName 'Default-First-Site-Name' `
    -confirm:$false
