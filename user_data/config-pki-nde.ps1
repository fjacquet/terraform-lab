< powershell>
# download needed for this server
mkdir C:\installers\
$gitroot = 'https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/'
Set-ExecutionPolicy unrestricted -Force #DevSkim: ignore DS113853 
$scripts = ('disable-av','disable-ieesc','initialize-env','install-nbugrp','install-chocolateys','install-mslaps','install-features')
foreach ($script in $scripts) {
  $url = "$($gitroot)$($script).ps1"
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url)) #DevSkim: ignore DS104456 
}

# Install basic
add-windowsfeature -Name ADCS-Device-Enrollment -IncludeManagementTools

Install-AdcsNetworkDeviceEnrollmentService `
    -ServiceAccountName MyDomain\AccountName `
    -ServiceAccountPassword (read-host "Set user password" -assecurestring) `
    -CAConfig "CAComputerName\CAName" `
    -RAName "Contoso-NDES-RA" `
    -RACountry "US" -RACompany "Contoso" `
    -SigningProviderName "Microsoft Strong Cryptographic Provider" `
    -SigningKeyLength 4096 `
    -EncryptionProviderName "Microsoft Strong Cryptographic Provider" `
    -EncryptionKeyLength 4096

$scripts = ('initialize-hostname')
foreach ($script in $scripts) {
  $url = "$($gitroot)$($script).ps1"
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url)) #DevSkim: ignore DS104456 
}

# reboot to finish setup
restart-computer -force:$true -Confirm:$false
< /powershell>
