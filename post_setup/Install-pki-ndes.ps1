Initialize-AWSDefaults

$s3bucket = "installers-fja"
$domain = 'evlab'
$secret = (Get-SECSecretValue -SecretId "evlab.ch/pki/svc-ndes").SecretString | ConvertFrom-Json
$user = "svc-ndes"
$caname = "evlab Root Certificate Authority"
$raname = "evlab Enterprise Certificate Authority"

Install-AdcsNetworkDeviceEnrollmentService `
   -ServiceAccountName $domain\$user `
   -ServiceAccountPassword (ConvertTo-SecureString -AsPlainText $secret -Force) `
   -CAConfig $caname
-RAName $raname `
   -RACountry "CH" `
   -RACompany $domain `
   -SigningProviderName "Microsoft Strong Cryptographic Provider" `
   -SigningKeyLength 4096 `
   -EncryptionProviderName "Microsoft Strong Cryptographic Provider" `
   -EncryptionKeyLength 4096
