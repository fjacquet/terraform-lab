
Initialize-AWSDefaults

$file = "issuing-capolicy.inf"
$domain = "ez-lab.xyz"
$root = "EVLAB-ROOT"
$s3bucket = "installers-fja"
$caname = "evlab Enterprise Certificate Authority"
$cacrl = 'C:\root-ca.crl'
$cacrt = 'C:\root-ca.crt'

Install-Module -Name PSPKI

$url = "https://raw.githubusercontent.com/fjacquet/terraform-lab/master/config_files/$($file)"

# Get the right polica file
Invoke-WebRequest -Uri $url -OutFile $file #DevSkim: ignore DS104456
Copy-Item -Path $file -Destination "C:\Windows\capolicy.inf"

# Get the root CA
Copy-S3Object `
   -BucketName $s3bucket `
   -Key 'root-ca.crt' `
   -LocalFile $cacrt

Copy-S3Object `
   -BucketName $s3bucket `
   -Key 'root-ca.crl' `
   -LocalFile $cacrl

# Push to domain
certutil.exe –dsPublish –f $cacrt RootCA

certutil.exe -dsPublish -f $cacrl RootCA

# Add to local store
certutil.exe –addstore –f root $cacrt
certutil.exe –addstore –f root cacrl

# startup configuration
Install-AdcsCertificationAuthority `
   -CAType EnterpriseSubordinateCA `
   -CACommonName $caname `
   -KeyLength 4096 `
   -HashAlgorithm SHA512 `
   -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
   -Force



Write-Host "add this step sign the .req in c:\ using the root CA"
Pause
