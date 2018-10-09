$dlroot = 'C:\installers'
$bin = 'SQL Server 2016 Enterprise 64bit English.ISO'
$file = Join-Path -parent $dlroot -ChildPath $bin
Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile $file
Mount-DiskImage -ImagePath C:\installers\$bin
$bin = 'FirstResponderKit.zip'
$file = Join-Path -parent $dlroot -ChildPath $bin
Invoke-WebRequest -uri http://public.brentozar.com/FirstResponderKit.zip -OutFile  $file #DevSkim: ignore DS137138 