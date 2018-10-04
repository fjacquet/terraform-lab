<powershell>
# download needed for this server
mkdir C:\installers\
$gitroot='https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/'
Set-ExecutionPolicy unrestricted -force #DevSkim: ignore DS113853 
$scripts = ('disable-av','disable-ieesc','initialize-env','install-nbugrp','install-chocolateys','install-mslaps','install-features','get-exchange')
foreach ($script in $scripts){
    $url = "$($gitroot)$($script).ps1"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url)) #DevSkim: ignore DS104456 
}

# Install basic
add-windowsfeature -Name 'DHCP' –IncludeManagementTools

$scripts = ('initialize-hostname')
foreach ($script in $scripts){
    $url = "$($gitroot)$($script).ps1"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url)) #DevSkim: ignore DS104456 
}

# reboot to finish setup
restart-computer -force 
</powershell>