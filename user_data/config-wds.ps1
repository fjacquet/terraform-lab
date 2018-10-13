<powershell>
# download needed for this server
mkdir C:\installers\

# Install windows features
add-windowsfeature -Name FS-Data-Deduplication,WDS -IncludeManagementTools

$gitroot = 'https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/'
Set-ExecutionPolicy Bypass -Scope Process -Force  #DevSkim: ignore DS113853 
$scripts = ('disable-av','disable-ieesc','initialize-env','install-nbugrp','install-chocolateys','install-mslaps','install-features')
foreach ($script in $scripts) {
  $url = "$($gitroot)$($script).ps1"
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url)) #DevSkim: ignore DS104456 
}


$scripts = ('get-msadk','get-msap','get-msmdt','format-datadisk','initialize-hostname')


$gitroot = 'https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/'
Set-ExecutionPolicy Bypass -Scope Process -Force  #DevSkim: ignore DS113853 
$scripts = ('disable-av', 
    'disable-ieesc',
    'initialize-env',
    'install-nbugrp',
    'install-chocolateys', 
    'install-mslaps', 
    'install-features', 
    'install-fusioninventory',
    'format-datadisk'
    'initialize-hostname', 
    'join-domain-member')
foreach ($script in $scripts) {
    $url = "$($gitroot)$($script).ps1"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url)) #DevSkim: ignore DS104456 
}


</powershell>
