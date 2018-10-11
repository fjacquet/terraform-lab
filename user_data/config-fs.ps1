<powershell>
# download needed for this server
mkdir C:\installers\
# Install windows features
add-windowsfeature -Name File-Services, FS-DFS-Replication, FS-Data-Deduplication, FS-NFS-Service, NFS-Client, FS-Resource-Manager, FS-SyncShareService –IncludeManagementTools

$gitroot = 'https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/'
Set-ExecutionPolicy unrestricted -Force #DevSkim: ignore DS113853 
$scripts = ('disable-av', 
    'disable-ieesc',
    'initialize-env',
    'install-nbugrp',
    'install-chocolateys', 
    'install-mslaps', 
    'install-features', 
    'initialize-hostname', 
    'format-datadisk',
    'join-domain-member')
foreach ($script in $scripts) {
    $url = "$($gitroot)$($script).ps1"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url)) #DevSkim: ignore DS104456 
}

</powershell>
