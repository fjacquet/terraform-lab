Get-Disk | Where-Object partitionstyle -eq 'raw' `
    | Initialize-Disk -PartitionStyle GPT -PassThru `
    | New-Partition  -DriveLetter D -UseMaximumSize  `
    | Format-Volume `
    -FileSystem NTFS `
    -Force:$true  `
    -Compress  `
    -UseLargeFRS  `
    -Confirm:$false

Enable-DedupVolume D:
Start-DedupJob -Type Optimization -Volume d:
