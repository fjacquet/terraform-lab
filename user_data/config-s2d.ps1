<powershell>

# Disable-InternetExplorerESC
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey  -Name "IsInstalled" -Value 0
Stop-Process -Name Explorer
# Disable antivirus
Set-MpPreference -DisableRealtimeMonitoring $true
# Disable firewall
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
# Install basic
install-windowsfeature -Name DSC-Service, GPMC, Multipath-IO, RSAT, SNMP-Service, File-Services, FS-DFS-Replication, FS-Data-Deduplication, FS-NFS-Service, NFS-Client, FS-Resource-Manager, FS-SyncShareService  
Install-WindowsFeature -Name File-Services, Failover-Clustering -IncludeManagementTools
# Set NFS on manual
Set-Service NfsClnt -startuptype "manual"
Set-Service NfsService -startuptype "manual"

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

# Disable IPv6 Transition Technologies
# netsh int teredo set state disabled
# netsh int 6to4 set state disabled
# netsh int isatap set state disabled
# netsh interface tcp set global autotuninglevel=disabled
# change to swiss keyboard
Set-WinSystemLocale fr-CH
Set-ExecutionPolicy unrestricted -force #DevSkim: ignore DS113853 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) #DevSkim: ignore DS104456 
$values = ('notepadplusplus', 'googlechrome', 'jre8', '7zip.install', 'baretail', 'windirstat', 'curl', 'bginfo')
foreach ($value in $values ) {
    choco install $value -y
}

# download needed for this server
mkdir C:\installers\
Copy-S3Object -BucketName installers-fja -Key LAPS.x64.msi -LocalFile C:\installers\LAPS.x64.msi

# curl.exe -k https://s3-eu-west-1.amazonaws.com/installers-fja/NetBackup_8.1.2Beta5_Win.zip1Beta5_Win.zip -o C:\installers\NetBackup_8.1.2Beta5_Win.zip 
# reboot to finish setup
Initialize-AWSDefaults
$instanceId = Invoke-RestMethod -uri http://169.254.169.254/latest/meta-data/instance-id #DevSkim: ignore DS104456 
$instance = (Get-EC2Instance -InstanceId $instanceId).Instances[0]
$instanceName = ($instance.Tags | Where-Object { $_.Key -eq "Name"} | Select-Object -expand Value)
Rename-computer -newName $instanceName
restart-computer
</powershell>