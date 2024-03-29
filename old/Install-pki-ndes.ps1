Initialize-AWSDefaults

$s3bucket = "installers-fja"
$domain = 'ezlab'
$secret = (Get-SECSecretValue -SecretId "ez-lab.xyz/pki/svc-ndes").SecretString | ConvertFrom-Json
$user = "svc-ndes"
$caname = "ezlab Root Certificate Authority"
$raname = "ezlab Enterprise Certificate Authority"

Install-AdcsNetworkDeviceEnrollmentService `
   -ServiceAccountName $domain\$user `
   -ServiceAccountPassword (ConvertTo-SecureString -AsPlainText $secret -Force) `
   -CAConfig $caname `
   -RAName $raname `
   -RACountry "CH" `
   -RACompany $domain `
   -SigningProviderName "Microsoft Strong Cryptographic Provider" `
   -SigningKeyLength 4096 `
   -EncryptionProviderName "Microsoft Strong Cryptographic Provider" `
   -EncryptionKeyLength 4096
