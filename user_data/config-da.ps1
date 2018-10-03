<powershell>
Set-ExecutionPolicy unrestricted -force #DevSkim: ignore DS113853 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://github.com/fjacquet/terraform-lab/disable-ipv6.ps1') #DevSkim: ignore DS104456 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://github.com/fjacquet/terraform-lab/disable-ieesc.ps1') #DevSkim: ignore DS104456 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://github.com/fjacquet/terraform-lab/install-mslaps.ps1') #DevSkim: ignore DS104456 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://github.com/fjacquet/terraform-lab/install-chocolateys.ps1') #DevSkim: ignore DS104456 



# Disable antivirus
Set-MpPreference -DisableRealtimeMonitoring $true
# Disable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
# Install basic
Add-WindowsFeature –Name DirectAccess-VPN –IncludeManagementTools
# Install-RemoteAccess -DAInstallType FullInstall -ConnectToAddress DA.DIRECTACCESSLAB.FR -ClientGPOName « DirectAccesslab.Lan\DirectAccess Clients GPO » -ServerGPOName « DirectAccesslab.Lan\DirectAccess Server GPO »-InternalInterface LAN -InternetInterface INTERNET -NLSURL https://nls.directaccesslab.lan -Force

Update-Help
# change to swiss keyboard
Set-WinSystemLocale fr-CH
$langList = New-WinUserLanguageList fr-CH
Set-WinUserLanguageList $langList -force


# download needed for this server
mkdir C:\installers\

# curl.exe -k https://s3-eu-west-1.amazonaws.com/installers-fja/NetBackup_8.1.2Beta5_Win.zip -o C:\installers\NetBackup_8.1.2Beta5_Win.zip 
# reboot to finish setup
Initialize-AWSDefaults
$instanceId = Invoke-RestMethod -uri http://169.254.169.254/latest/meta-data/instance-id #DevSkim: ignore DS104456 
$instance = (Get-EC2Instance -InstanceId $instanceId).Instances[0]
$instanceName = ($instance.Tags | Where-Object { $_.Key -eq "Name"} | Select-Object -expand Value)
Rename-computer -newName $instanceName
restart-computer
</powershell>