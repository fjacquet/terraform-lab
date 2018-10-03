<powershell>
# download needed for this server
mkdir C:\installers\
$gitroot='https://github.com/fjacquet/terraform-lab/blob/master/post_setup/'
Set-ExecutionPolicy unrestricted -force #DevSkim: ignore DS113853 
$scripts = ('disable-av','disable-ieesc','initialize-env','install-nbugrp','install-chocolateys','install-mslaps','install-features')
foreach ($script in scripts){
    $url = "$($gitroot)$($script).ps1"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url) #DevSkim: ignore DS104456 
}

# Install basic
add-WindowsFeature -name FS-Data-Deduplication, UpdateServices, UpdateServices-WidDB, UpdateServices-Services, UpdateServices-RSAT, UpdateServices-API, UpdateServices-UI -IncludeManagementTools

$scripts = ('format-datadisk','initialize-hostname')
foreach ($script in scripts){
    $url = "$($gitroot)$($script).ps1"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url) #DevSkim: ignore DS104456 
}

# reboot to finish setup
restart-computer
</powershell>
