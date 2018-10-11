# Change to swiss keyboard
Set-WinSystemLocale fr-CH
$langList = New-WinUserLanguageList fr-CH
Set-WinUserLanguageList $langList -Force
# Allow WinRM
# Configure-SMremoting.exe -enable
# Remove SMBv1
Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol -NoRestart
# Install-Module -Name AWSPowerShell 