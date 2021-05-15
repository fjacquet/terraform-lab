Write-Output 'Fusion inventory'
$install = 'C:\installers'
$version = "2.6"
$file = "fusioninventory-agent_windows-x64_$($version).exe"
$url = "https://github.com/fusioninventory/fusioninventory-agent/releases/download/$($version)/$($file)"

$localfile = Join-Path -Path $install -ChildPath $file
Write-Output 'Download'
Invoke-WebRequest -Uri $url -OutFile $localfile  #DevSkim: ignore DS104456
Write-Output 'install'
$glpi = Resolve-DnsName glpi-0.evlab.ch -Type A
$server = 'http://' + $glpi.ipaddress + '/glpi/plugins/fusioninventory/'
$arg = ('/acceptlicense',
    '/add-firewall-exception' ,
    '/execmode=Service',
    '/installtasks=Default',
    '/installtype=from-scratch',
    '/runnow',
    '/S' ,
    '/scan-homedirs' ,
    '/scan-profiles' ,
    "/server=$($server)")
Start-Process -filepath $localfile -ArgumentList  $arg

