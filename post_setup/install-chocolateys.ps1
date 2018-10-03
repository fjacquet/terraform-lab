Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) #DevSkim: ignore DS104456 
$values = ('notepadplusplus','googlechrome','jre8','7zip.install','baretail','windirstat','curl','bginfo')
foreach ($value in $values ){
    choco install $value -y
}