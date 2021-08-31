Get-Disk | Where-Object partitionstyle -EQ 'raw' `
| Initialize-Disk -PartitionStyle GPT -PassThru `
| New-Partition -DriveLetter D -UseMaximumSize `
| Format-Volume `
   -FileSystem NTFS `
   -Force:$true `
   -Compress `
   -UseLargeFRS `
   -Confirm:$false

Import-Module -Name Deduplication
Enable-DedupVolume D: -UsageType Default
Set-Dedupvolume D: -MinimumFileAgeDays 0
New-DedupSchedule -Name "OffHoursGC" -Type GarbageCollection -Start 08:00 -DurationHours 5 -Days Sunday -Priority Normal
New-DedupSchedule -Name "OffHoursScrub" -Type Scrubbing -Start 23:00 -StopWhenSystemBusy -DurationHours 6 -Days Monday, Tuesday, Wednesday, Thursday, Friday -Priority Normal
New-DedupSchedule -Name "DailyOptimization" -Type Optimization -Days Monday, Tuesday, Wednesday, Thursday, Friday -Start 08:00 -DurationHours 9

Start-DedupJob -Type Optimization -Volume D:
