Set-ExecutionPolicy Bypass -Scope Process -Force #DevSkim: ignore DS113853
Write-Output "installing latest nuget"
Install-PackageProvider -Name NuGet -Force -Confirm:$false
Write-Output "allow ps gallery"
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Write-Output "install chocolatey"
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) #DevSkim: ignore DS104456
$values = (
  '7zip.install',
  'baretail',
  'curl',
  'git',
  'googlechrome',
  'notepadplusplus',
  'reportviewer2012',
  'rdmfree',
  'sysinternals',
  'windirstat'
)
choco feature enable -n allowGlobalConfirmation
foreach ($value in $values) {
  Write-Output "installing $($value)"
  choco install $value -y
}
