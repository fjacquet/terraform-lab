$bin = "SW_DVD9_Exchange_Svr_2016_MultiLang_-6_Std_Ent_.iso_MLF_X21-40135.ISO"
Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile C:\installers\$bin
Mount-DiskImage -ImagePath C:\installers\$bin
