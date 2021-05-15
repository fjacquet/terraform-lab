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
add-windowsfeature -Name RSAT `
    -IncludeManagementTools

# Disable LMHosts
$disable = 2
$adapters = (gwmi win32_networkadapterconfiguration )
Foreach ($adapter in $adapters) {
    Write-Host $adapter
    $adapter.settcpipnetbios($disable)
}

# Disable Netbios
$nicClass = Get-WmiObject -list Win32_NetworkAdapterConfiguration
$nicClass.enableWins($false, $false)

# Set-SmbServerConfiguration `
#     -EnableSMB1Protocol $false `
#     -Confirm:$false

Set-SmbServerConfiguration `
    -RequireSecuritySignature $true `
    -EnableSecuritySignature $true `
    -EncryptData $true `
    -Confirm:$false

Set-SmbServerConfiguration -AutoShareServer $false `
    -AutoShareWorkstation $false `
    -Confirm:$false

Set-SmbServerConfiguration -ServerHidden $true `
    -AnnounceServer $false `
    -Confirm:$false