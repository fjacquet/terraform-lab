<powershell>
# Disable IPv6 Transition Technologies
netsh int teredo set state disabled
netsh int 6to4 set state disabled
netsh int isatap set state disabled
netsh interface tcp set global autotuninglevel=disabled
# Disable-InternetExplorerESC
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
Stop-Process -Name Explorer
# Disable antivirus
Set-MpPreference -DisableRealtimeMonitoring $true
# Disable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
# Install basic
install-windowsfeature DSC-Service,FS-NFS-Service,NFS-Client,GPMC,Multipath-IO,RSAT,SNMP-Service
# Set NFS on manual
Set-Service NfsClnt -startuptype "manual"
Set-Service NfsService -startuptype "manual"
Update-Help

# change to swiss keyboard
Set-WinSystemLocale fr-CH
$langList = New-WinUserLanguageList fr-CH
Set-WinUserLanguageList $langList -force
Set-ExecutionPolicy unrestricted -force #DevSkim: ignore DS113853 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) #DevSkim: ignore DS104456 
$values = ('notepadplusplus','googlechrome','jre8','7zip.install','baretail','windirstat','curl','bginfo')
foreach ($value in $values ){
    choco install $value -y
}
# download needed for this server
mkdir C:\installers\
curl.exe -k https://s3-eu-west-1.amazonaws.com/installers-fja/LAPS.x64.msi -o C:\installers\LAPS.x64.msi
msiexec /q /i C:\installers\LAPS.x64.msi
# curl.exe -k https://s3-eu-west-1.amazonaws.com/installers-fja/NetBackup_8.1.2Beta5_Win.zip -o C:\installers\NetBackup_8.1.2Beta5_Win.zip 
curl.exe -k https://s3-eu-west-1.amazonaws.com/installers-fja/officeserver2016.img -o C:\installers\officeserver2016.img
# reboot to finish setup
iiscryptocli /template best 
Initialize-AWSDefaults
$instanceId = Invoke-RestMethod -uri http://169.254.169.254/latest/meta-data/instance-id #DevSkim: ignore DS104456 
$instance = (Get-EC2Instance -InstanceId $instanceId).Instances[0]
$instanceName = ($instance.Tags | Where-Object { $_.Key -eq "Name"} | Select-Object -expand Value)
Rename-computer -newName $instanceName
restart-computer
</powershell>