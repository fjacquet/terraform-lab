Set-ExecutionPolicy Bypass -Scope Process -Force  #DevSkim: ignore DS113853 
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.501 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))#DevSkim: ignore DS104456 
$values = ('notepadplusplus','googlechrome','sysinternals','7zip.install','baretail','windirstat','curl')
foreach ($value in $values) {
  choco install $value -y
}
