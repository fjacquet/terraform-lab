# Change to swiss keyboard
Write-Output "Set local"
Set-WinSystemLocale fr-CH
$langList = New-WinUserLanguageList fr-CH
Set-WinUserLanguageList $langList -Force
# Allow WinRM
Write-Output "Allow WinRM"
Configure-SMremoting.exe -enable
# Remove SMBv1
Write-Output "Disabling SMBv1"
Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol -NoRestart
# Install-Module -Name AWSPowerShell 