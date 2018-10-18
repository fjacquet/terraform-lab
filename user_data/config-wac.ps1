<powershell>
mkdir C:\installers\
Write-Output "installing RSAT"
# Install windows features
add-windowsfeature -Name RSAT

$gitroot = 'https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/'
Set-ExecutionPolicy Bypass -Scope Process -Force  #DevSkim: ignore DS113853 
$scripts = (
    'Disable-av', 
    'Disable-ieesc',
    'Initialize-env',
    'Install-nbugrp',
    'Install-chocolateys', 
    'Install-mslaps', 
    'Install-features', 
    'Install-fusioninventory',
    'Initialize-hostname', 
    'Join-domain-member'
)
foreach ($script in $scripts) {
    $url = "$($gitroot)$($script).ps1"
    Write-Output "running $($url)"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url)) #DevSkim: ignore DS104456 
}
</powershell>
