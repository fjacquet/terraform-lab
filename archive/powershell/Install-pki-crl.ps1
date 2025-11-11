Initialize-AWSDefaults

$s3bucket = "installers-fja"
$root = "ezlab-ROOT"
$pkiroot = "C:\pki"
$cacrl = "$($pkiroot)\root-ca.crl"
$cacrt = "$($pkiroot)\root-ca.crt"
$entcrl = "$($pkiroot)\ent-ca.crl"
$entcrt = "$($pkiroot)\ent-ca.crt"

# Get the right polica file
add-windowsfeature -Name Web-server
mkdir $pkiroot
Install-Module -Name PSPKI


Set-Location "inetsrv\"
.\Appcmd Set-Variable config “Default Web Site” /section:system.webServer/Security/requestFiltering -allowDoubleEscaping:True

# Get the root CA
Copy-S3Object `
   -BucketName $s3bucket `
   -Key 'root-ca.crt' `
   -LocalFile $cacrt

Copy-S3Object `
   -BucketName $s3bucket `
   -Key 'root-ca.crl' `
   -LocalFile $cacrl

Copy-S3Object `
   -BucketName $s3bucket `
   -Key 'ent-ca.crt' `
   -LocalFile $entcrt

Copy-S3Object `
   -BucketName $s3bucket `
   -Key 'ent-ca.crl' `
   -LocalFile $entcrl
