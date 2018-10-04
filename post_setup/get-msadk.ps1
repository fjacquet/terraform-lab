$bin = "adksetup.exe"
Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile C:\installers\$bin
$bin = "adkwinpesetup.exe"
Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile C:\installers\$bin