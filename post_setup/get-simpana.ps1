$bin = "Commvault_R80_SP6_15December16.exe"
Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile C:\installers\$bin
$bin = "CVL_00003359.xml"
Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile C:\installers\$bin
