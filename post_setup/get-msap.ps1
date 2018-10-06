$bin = "MapSetup.exe"
Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile C:\installers\$bin
