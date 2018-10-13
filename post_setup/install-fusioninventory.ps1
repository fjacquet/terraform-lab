Write-Output 'Fusion inventory'
$install = 'C:\installers'
$file = 'fusioninventory-agent_windows-x64_2.4.2.exe'
$url = "https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.4.2/$($file)"
$localfile = Join-Path -Path $install -ChildPath $file 
Write-Output 'Download'
Invoke-WebRequest -Uri $url -OutFile $localfile  #DevSkim: ignore DS104456 
Write-Output 'install'
$server = 'glpi-0.evlab.ch'
$args = ('/acceptlicense',
    '/add-firewall-exception' ,
    '/execmode=Service',
    '/installtasks=Default',
    '/installtype=from-scratch',
    '/runnow',
    '/S' ,
    '/scan-homedirs' ,
    '/scan-profiles' ,
    "/server=$($server)")
Start-Process -filepath $localfile -ArgumentList  $args

