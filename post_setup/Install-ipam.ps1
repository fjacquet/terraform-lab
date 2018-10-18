﻿Add-WindowsFeature -name RSAT-AD-PowerShell
Import-Module -name activedirectory

$Domain = $env:USERDNSDOMAIN

# Install-WindowsFeature ipam -IncludeAllSubFeature -IncludeManagementTools

Initialize-AWSDefaults
$secret = (Get-SECSecretValue -SecretId "evlab/ad/fjacquet" -region eu-west-1).SecretString 
$username = "fjacquet@evlab.ch"
$password = ConvertTo-SecureString -AsPlainText -Force $secret
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

Invoke-IpamGpoProvisioning ` #DevSkim: ignore DS104456 
    –Domain $Domain `
    -GpoPrefixName IPAM `
    –IpamServerFqdn ipam-0.$domain `
    -DelegatedGpoUser $Credential `
    -confirm:$false -force