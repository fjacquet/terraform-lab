$bin = "Commvault_R80_SP6_15December16.exe"
$s3bucket = 'installers-fja'
$dlroot = "C:\installers\$bin"
Copy-S3Object -BucketName $s3bucket -Key $bin -LocalFile $dlroot
$bin = "CVL_00003359.xml"
Copy-S3Object -BucketName $s3bucket -Key $bin -LocalFile $dlroot
