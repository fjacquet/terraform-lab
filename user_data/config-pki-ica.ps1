<powershell>
# download needed for this server
mkdir C:\installers\
# Install windows features
# add-windowsfeature -Name Adcs-Cert-Authority,ADCS-Web-Enrollment -IncludeManagementTools

$gitroot = 'https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/'
Set-ExecutionPolicy Bypass -Scope Process -Force  #DevSkim: ignore DS113853
$scripts = (
    'Disable-av',
    'Disable-ieesc',
    'Initialize-env',
    'Install-nbugrt',
    'Install-chocolateys',
    'Install-mslaps',
    'Install-features',
    'Install-fusioninventory',
    'Join-domain-member',
    'Initialize-hostname'
)
foreach ($script in $scripts) {
    $url = "$($gitroot)$($script).ps1"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url)) #DevSkim: ignore DS104456
}

</powershell>
