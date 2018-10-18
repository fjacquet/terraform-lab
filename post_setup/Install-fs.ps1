# new-Partition -PartitionNumber 2  -DriveLetter D  | Format-Volume  -FileSystem NTFS   -Force:$true   -Compress   -UseLargeFRS  -Confirm:$false
mkdir D:\samples
New-SmbShare `
   -Description "Sample file share" `
   -FolderEnumerationMode AccessBased `
   -CachingMode None `
   -Path D:\samples -Name samples `
   -EncryptData $true

