﻿<powershell>
# download needed for this server
mkdir C:\installers\
# Install windows features
install-windowsfeature AD-Domain-Services –IncludeManagementTools
$gitroot = 'https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/'
Set-ExecutionPolicy Bypass -Scope Process -Force  #DevSkim: ignore DS113853
$scripts = (
    'Disable-av',
    'Disable-ieesc',
    'Initialize-env',
    'Install-nbugrt',
    'Install-chocolateys',
    'Install-features',
    'Install-fusioninventory',
    'Initialize-hostname'
)
foreach ($script in $scripts) {
    $url = "$($gitroot)$($script).ps1"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url)) #DevSkim: ignore DS104456
}
restart-computer -force:$true -Confirm:$false
</powershell>
