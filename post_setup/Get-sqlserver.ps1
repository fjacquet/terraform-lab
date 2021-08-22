$dlroot = 'C:\installers'
# Get ISO
#-----------------------------------------------------------------------------
$bin = 'SQL Server 2016 Enterprise 64bit English.ISO'
$file = Join-Path -Parent $dlroot -ChildPath $bin
Copy-S3Object -BucketName installers-fja -Key $bin -LocalFile $file
Mount-DiskImage -ImagePath C:\installers\$bin
# Get tool
#-----------------------------------------------------------------------------
$bin = 'FirstResponderKit.zip'
$file = Join-Path -Parent $dlroot -ChildPath $bin
Invoke-WebRequest -Uri https://downloads.brentozar.com/FirstResponderKit.zip -OutFile $file #DevSkim: ignore DS137138
