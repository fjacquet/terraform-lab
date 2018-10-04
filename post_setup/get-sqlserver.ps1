$bin = "SQL Server 2016 Enterprise 64bit English.ISO"
Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile C:\installers\$bin

