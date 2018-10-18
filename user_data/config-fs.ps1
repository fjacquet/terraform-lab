﻿<powershell>
# download needed for this server
mkdir C:\installers\
# Install windows features
add-windowsfeature -Name File-Services, FS-DFS-Namespace, FS-DFS-Replication, FS-Data-Deduplication, FS-Resource-Manager, FS-SyncShareService –IncludeManagementTools

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
    'Format-datadisk',
    'Initialize-hostname', 
    'Join-domain-member'
)
foreach ($script in $scripts) {
    $url = "$($gitroot)$($script).ps1"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url)) #DevSkim: ignore DS104456 
}

</powershell>
