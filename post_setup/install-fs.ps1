Get-Disk | Where-Object partitionstyle -eq 'raw' `
    | Initialize-Disk -PartitionStyle GPT -PassThru `
    | New-Partition  -DriveLetter D -UseMaximumSize  `
    | Format-Volume `
    -FileSystem NTFS `
    -Force:$true  `
    -Compress  `
    -UseLargeFRS  `
    -Confirm:$false

new-Partition -PartitionNumber 2  -DriveLetter D  | Format-Volume  -FileSystem NTFS   -Force:$true   -Compress   -UseLargeFRS  -Confirm:$false

New-SmbShare `
    -Description "Sample file share" `
    -FolderEnumerationMode AccessBased `
    -CachingMode None  `
    -Path D:\samples -name samples `
    -EncryptData $true

Enable-DedupVolume D:
Start-DedupJob -Type Optimization -Volume d: