Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) #DevSkim: ignore DS104456 
$values = ('notepadplusplus','googlechrome','sysinternals','7zip.install','baretail','windirstat','curl')
foreach ($value in $values) {
  choco install $value -y
}
