Initialize-AWSDefaults

$file = "root-capolicy.inf"
$domain = "evlab.ch"
$s3bucket = "installers-fja"
$caname = "evlab Root Certificate Authority"
$root = "EVLAB-ROOT"
$url = 'https://raw.githubusercontent.com/fjacquet/terraform-lab/master/config_files/$($file)'

Install-Module -name PSPKI
# Get the right polica file
Invoke-WebRequest -Uri $url -OutFile $file #DevSkim: ignore DS104456 
Copy-Item -Path $file -Destination "C:\Windows\capolicy.inf"
# startup configuration 
Install-AdcsCertificationAuthority `
    -CAType StandaloneRootCA `
    -CACommonName $caname `
    -KeyLength 4096 `
    -HashAlgorithm SHA256 `
    -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
    -ValidityPeriod Years`
    -ValidityPeriodUnits 20 `
    -Force

# remove default
$crllist = Get-CACrlDistributionPoint
foreach ($crl in $crllist) {
    Remove-CACrlDistributionPoint $crl.uri -Force
}
# create valide crl
Add-CACRLDistributionPoint `
    -Uri C:\Windows\System32\CertSrv\CertEnroll\$($root)%8%9.crl `
    -PublishToServer `
    -PublishDeltaToServer `
    -Force
Add-CACRLDistributionPoint `
    -Uri http://pki.$($domain)/pki/$($root)%8%9.crl `
    -AddToCertificateCDP `
    -AddToFreshestCrl `
    -Force
# Prepare AIA 
Get-CAAuthorityInformationAccess `
    | Where-Object {$_.Uri -like '*ldap*' -or $_.Uri -like '*http*' -or $_.Uri -like '*file*'} `
    | Remove-CAAuthorityInformationAccess `
    -Force
Add-CAAuthorityInformationAccess `
    -AddToCertificateAia http://pki.$($domain)/pki/$($root)%3%4.crt `
    -Force
# Configure 
certutil.exe –setreg CA\CRLPeriodUnits 20
certutil.exe –setreg CA\CRLPeriod “Years”
certutil.exe –setreg CA\CRLOverlapPeriodUnits 3
certutil.exe –setreg CA\CRLOverlapPeriod “Weeks”
certutil.exe –setreg CA\ValidityPeriodUnits 10
certutil.exe –setreg CA\ValidityPeriod “Years”
certutil.exe -setreg CA\AuditFilter 127
# Restart ca
Restart-Service -name certsvc
# publish 
certutil -crl

# Copy to S3
Copy-S3Object -LocalFile "C:\Windows\System32\CertSrv\CertEnroll\RootCA_$($caname).crt"  `
    -BucketName $s3bucket `
    -Key root-ca.crt
Copy-S3Object -LocalFile "C:\Windows\System32\CertSrv\CertEnroll\$($root).crl" `
    -BucketName $s3bucket `
    -Key root-ca.crl