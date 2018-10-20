Write-Output 'MS-LAPS'
$s3bucket = 'installers-fja'
$install = 'C:\installers'
$file = 'LAPS.x64.msi'
$localfile  = Join-Path -Path $install -ChildPath $file 
Copy-S3Object -BucketName $s3bucket -Key $file -LocalFile $localfile 
msiexec /q /i $localfile
