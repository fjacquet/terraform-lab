Get-Disk | Where-Object partitionstyle -EQ 'raw' `
   | Initialize-Disk -PartitionStyle GPT -Passthru `
   | New-Partition -DriveLetter D -UseMaximumSize `
   | Format-Volume `
   -FileSystem NTFS `
   -Force:$true `
   -Compress `
   -UseLargeFRS `
   -confirm:$false

Import-Module -name Deduplication
Enable-DedupVolume D: 
Start-DedupJob -Type Optimization -Volume D:
