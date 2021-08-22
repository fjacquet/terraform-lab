Initialize-AWSDefaults

$s3bucket = "installers-fja"

$domainName = "{{ windows_domain_info['dns_domain_name'] }}"
$password = "{{ windows_domain_info['domain_admin_password'] }}"
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$fqdn = [System.Net.Dns]::GetHostByName(($env:computerName)) | format-list HostName | Out-String | ForEach-Object { "{0}" -f $_.Split(':')[1].Trim() };
$filename = "C:\$fdqn.pfx"
$user = "{{ windows_domain_info['dns_domain_name'] }}\{{ windows_domain_info['domain_admin_user'] }}"
$credential = New-Object `
    -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $user, $securePassword

Write-Host "Installing nuget package provider"
Install-PackageProvider nuget -force

Write-Host "Installing PSPKI module"
Install-Module -Name PSPKI -Force

Write-Host "Importing PSPKI into current environment"
Import-Module -Name PSPKI

Write-Host "Generating Certificate"
Get-Certificate `
    -Url "https://afds-0.ez-lab.xyz" `
    -Template "SSL" `
    -SubjectName <String>] `
    -DnsName "afds-0.ez-lab.xyz" `
    -Credential <PkiCredential> `
    -CertStoreLocation <String> `
    -Confirm:$false


$selfSignedCert = New-SelfSignedCertificateEx `
    -Subject "CN=$fqdn" `
    -ProviderName "Microsoft Enhanced RSA and AES Cryptographic Provider" `
    -KeyLength 2048 -FriendlyName 'OAFED SelfSigned' -SignatureAlgorithm sha256 `
    -EKU "Server Authentication", "Client authentication" `
    -KeyUsage "KeyEncipherment, DigitalSignature" `
    -Exportable -StoreLocation "LocalMachine"
$certThumbprint = $selfSignedCert.Thumbprint

Write-Host "Installing ADFS"
Install-WindowsFeature -IncludeManagementTools -Name ADFS-Federation

Write-Host "Configuring ADFS"
Import-Module ADFS
Install-AdfsFarm -CertificateThumbprint $certThumbprint -FederationServiceName $fqdn -ServiceAccountCredential $credential

# dir Cert:\LocalMachine\My
# Get-KdsRootKey –EffectiveTime (Get-Date).AddHours(-10)
# setspn -L ADFS-0

# https://ADFS_FQDN/adfs/ls/idpinitiatedSignOn.aspx

# (Get-AdfsProperties).EnableIdPInitiatedSignonPage
# Set-AdfsProperties -EnableIdPInitiatedSignonPage $true
# (Get-AdfsProperties).EnableIdPInitiatedSignonPage