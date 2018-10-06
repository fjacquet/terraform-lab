Get-Disk | Where-Object partitionstyle -EQ 'raw' `
   | Initialize-Disk -PartitionStyle GPT -Passthru `
   | New-Partition -DriveLetter D -UseMaximumSize `
   | Format-Volume `
   -FileSystem NTFS `
   -Force:$true `
   -Compress `
   -UseLargeFRS `
   -confirm:$false

Enable-DedupVolume D:
Set-Dedupvolume D: -MinimumFileAgeDays 0
Set-DedupSchedule –Name "OffHoursGC" –Type GarbageCollection –Start 08:00 –DurationHours 5 –Days Sunday –Priority Normal
Set-DedupSchedule –Name "OffHoursScrub" –Type Scrubbing –Start 23:00 –StopWhenSystemBusy –DurationHours 6 –Days Monday,Tuesday,Wednesday,Thursday,Friday –Priority Normal
Set-DedupSchedule –Name "DailyOptimization" –Type Optimization –Days Monday,Tuesday,Wednesday,Thursday,Friday –Start 08:00 –DurationHours 9


Start-DedupJob -Type Optimization -Volume d:

# new-Partition -PartitionNumber 2  -DriveLetter D  | Format-Volume  -FileSystem NTFS   -Force:$true   -Compress   -UseLargeFRS  -Confirm:$false
mkdir D:\samples
New-SmbShare `
   -Description "Sample file share" `
   -FolderEnumerationMode AccessBased `
   -CachingMode None `
   -Path D:\samples -Name samples `
   -EncryptData $true

