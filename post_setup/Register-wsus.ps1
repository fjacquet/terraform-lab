
$server = "prod-tech-srv4.mtx.hotela.ch"
$scheme = "https"
$WindowsUpdate = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$AU = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

function set-Dword {
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [string]$registryPath,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [string]$name,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [string]$value

  )
  if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
      -PropertyType DWord -Force | Out-Null
  }
  else {
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
      -PropertyType DWord -Force | Out-Null
  }
}
function set-String {
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [string]$registryPath,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [string]$name,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [string]$value

  )
  if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
      -PropertyType String -Force | Out-Null
  }
  else {
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
      -PropertyType String -Force | Out-Null
  }
}

# GPO equivalent
set-String -registryPath $WindowsUpdate -Name "WUServer" -Value "$($scheme)://$($server)"
set-String -registryPath $WindowsUpdate -Name "WUStatusServer" -Value "$($scheme)://$($server)"
set-String -registryPath $WindowsUpdate -Name "TargetGroup" -Value "Servers 2019"
set-Dword -registryPath $WindowsUpdate -Name "TargetGroupEnabled" -Value "00000001"
set-Dword -registryPath $WindowsUpdate -Name "ElevateNonAdmins" -Value "00000001"
set-Dword -registryPath $AU -Name "NoAutoUpdate" -Value "00000000"
set-Dword -registryPath $AU -Name "AutoInstallMinorUpdates" -Value "00000001"

set-Dword -registryPath $AU -Name "AUOptions" -Value "00000003"
set-Dword -registryPath $AU -Name "AutoInstallMinorUpdates" -Value "00000001"
set-Dword -registryPath $AU -Name "ScheduledInstallDay" -Value "00000011"
set-Dword -registryPath $AU -Name "UseWUServer" -Value "00000001"


# Restart to force reload
Stop-Service wsusservice
Start-Service wsusservice


#copy to %WINDIR%\System32\WindowsPowerShell\v1.0\Modules
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
Import-Module PSWindowsUpdate
Get-WindowsUpdate –Download

Install-WindowsUpdate -AcceptAll -Install -AutoReboot | Out-File "c:\temp\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log" -force