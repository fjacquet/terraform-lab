$bin = "SW_DVD5_SharePoint_Server_2016_64Bit_English_MLF_X20-97223.ISO"
Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile C:\installers\$bin
Mount-DiskImage -ImagePath C:\installers\$bin
