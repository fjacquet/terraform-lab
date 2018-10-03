
$binaries=('Exchange2016-x64.exe')
foreach ($bin in $binaries)
{
    Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile C:\installers\$bin
}