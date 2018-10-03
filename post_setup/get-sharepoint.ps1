
$binaries=('officeserver2016.img')
foreach ($bin in $binaries)
{
    Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile C:\installers\$bin
}