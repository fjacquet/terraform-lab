Copy-S3Object -BucketName installers-fja -Key LAPS.x64.msi -LocalFile C:\installers\LAPS.x64.msi
msiexec /q /i C:\installers\LAPS.x64.msi