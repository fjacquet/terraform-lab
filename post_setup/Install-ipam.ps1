Add-WindowsFeature -name RSAT-AD-PowerShell
Import-Module -name ActiveDirectory

$Domain = $env:USERDNSDOMAIN

Install-WindowsFeature -Name IPAM `
    -IncludeAllSubFeature `
    -IncludeManagementTools

Initialize-AWSDefaults
$secret = (Get-SECSecretValue -SecretId "ez-lab.xyz/ad/fjacquet" -region eu-west-1).SecretString
$username = "fjacquet@ez-lab.xyz"
$password = ConvertTo-SecureString -AsPlainText -Force $secret
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

Invoke-IpamGpoProvisioning `
    –Domain $Domain `
    -GpoPrefixName IPAM `
    –IpamServerFqdn ipam-0.$domain `
    -DelegatedGpoUser $Credential `
    -confirm:$false -force