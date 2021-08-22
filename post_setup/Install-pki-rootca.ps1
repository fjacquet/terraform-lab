Initialize-AWSDefaults

$file = "root-capolicy.inf"
$domain = "ez-lab.xyz"
$s3bucket = "installers-fja"
$caname = "evlab Root Certificate Authority"
$root = "EVLAB-ROOT"
$url = "https://raw.githubusercontent.com/fjacquet/terraform-lab/master/config_files/$($file)"

Install-Module -Name PSPKI
# Get the right polica file
Invoke-WebRequest -Uri $url -OutFile $file #DevSkim: ignore DS104456
Copy-Item -Path $file -Destination "C:\Windows\capolicy.inf"
# startup configuration
Install-AdcsCertificationAuthority `
    -CAType StandaloneRootCA `
    -CACommonName $caname `
    -KeyLength 4096 `
    -HashAlgorithm SHA512 `
    -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
    -ValidityPeriod Years `
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
    | Where-Object { $_.uri -like '*ldap*' -or $_.uri -like '*http*' -or $_.uri -like '*file*' } `
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
Restart-Service -Name certsvc
# publish
certutil -crl

# Copy to S3
$certdir = "C:\Windows\System32\CertSrv\CertEnroll"
$localdir = "c:\installers"

copy-item "$($certdir)\$($env:computername)_$($caname).crt" $localdir
copy-item "$($certdir)\$($root).crl" $localdir

Write-S3Object -File  "$($localdir)\$($env:computername)_$($caname).crt" `
    -BucketName $s3bucket `
    -key root-ca.crt

Write-S3Object -File "$($localdir)\$($root).crl" `
    -BucketName $s3bucket `
    -key root-ca.crl
