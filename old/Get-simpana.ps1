$bin = "Commvault_R80_SP13_14September18.exe"
$s3bucket = 'installers-fja'
$dlroot = "C:\installers\$bin"
Copy-S3Object -BucketName $s3bucket -Key $bin -LocalFile $dlroot
$bin = "CVL_00003359.xml"
$dlroot = "C:\installers\$bin"
Copy-S3Object -BucketName $s3bucket -Key $bin -LocalFile $dlroot
