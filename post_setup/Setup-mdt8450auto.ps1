# Microsoft Deployment Toolkit 8450 Automatic Setup
# Author: EasyMDT (http://easymdt.org/microsoft-deployment-toolkit-8450-automatic-setup/)
# Version: 3.2
# Release date: 01/07/2018
# Tested on Windows 10 1607

#Requires -RunAsAdministrator

#Input Parameters
param(
  [Parameter(Mandatory = $true)]
  [string]$ServiceAccountPassword,

  [Parameter(Mandatory = $true)]
  [ValidateScript({ Test-Path $_ })]
  [string]$DeploymentShareDrive,

  [Parameter(Mandatory = $false)]
  [switch]$Office365,

  [Parameter(Mandatory = $false)]
  [switch]$Applications
)

$ErrorActionPreference = "Stop"

$DeploymentShareDrive = $DeploymentShareDrive.TrimEnd("\")

#Get Installers
Write-Output "Downloading MDT 8450"
$params = @{
  Source      = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
  Destination = "$PSScriptRoot\mdt_install.msi"
  ErrorAction = "Stop"
}
Start-BitsTransfer @params

Write-Output "Downloading ADK 1803"
$params = @{
  Source      = "http://download.microsoft.com/download/6/8/9/689E62E5-C50F-407B-9C3C-B7F00F8C93C0/adk/adksetup.exe"
  Destination = "$PSScriptRoot\adk_setup.exe"
  ErrorAction = "Stop"
}
Start-BitsTransfer @params

#Run Installs
Write-Output "Installing MDT"
Start-Process msiexec.exe -Wait -ArgumentList "/i ""$PSScriptRoot\mdt_install.msi"" /qn" -ErrorAction Stop

Write-Output "Installing ADK"
$params = @{
  FilePath     = "$PSScriptRoot\adk_setup.exe"
  ArgumentList = "/quiet /features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment"
  ErrorAction  = "Stop"
}
Start-Process @params -Wait

#Import MDT Module
Write-Output "Importing MDT Module"
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1" -ErrorAction Stop

#Create Deployment Share
Write-Output "Create Deployment Share"
$localUser = "svc_mdt"
$localUserPasswordSecure = ConvertTo-SecureString $ServiceAccountPassword -AsPlainText -Force -ErrorAction Stop
New-LocalUser -AccountNeverExpires -Name $localUser -Password $localUserPasswordSecure -PasswordNeverExpires -ErrorAction Stop
New-Item -Path "$DeploymentShareDrive\DeploymentShare" -ItemType directory -ErrorAction Stop
New-SmbShare -Name "DeploymentShare$" -Path "$DeploymentShareDrive\DeploymentShare" -ReadAccess "$env:COMPUTERNAME\$localUser" -ErrorAction Stop

$params = @{
  Name        = "DS001"
  PSProvider  = "MDTProvider"
  Root        = "$DeploymentShareDrive\DeploymentShare"
  Description = "MDT Deployment Share"
  NetworkPath = "\\$env:COMPUTERNAME\DeploymentShare$"
  ErrorAction = "Stop"
}
New-PSDrive @params -Verbose | add-MDTPersistentDrive -Verbose

#Import WIM
Write-Output "Checking for wim files"
$Wims = Get-ChildItem $PSScriptRoot -Filter "*.wim" | Select-Object -ExpandProperty FullName
if (!$Wims) {
  Write-Output "No wim files found"
}

if ($Wims) {
  foreach ($Wim in $Wims) {
    $WimName = Split-Path $Wim -Leaf
    $WimName = $WimName.TrimEnd(".wim")
    Write-Output "$WimName found - will import"
    $params = @{
      Path              = "DS001:\Operating Systems"
      SourceFile        = $Wim
      DestinationFolder = $WimName
    }
    $osData = Import-MDTOperatingSystem @params -Verbose -ErrorAction Stop
  }
}

#Create Task Sequence for each Operating System
Write-Output "Creating Task Sequence for each imported Operating System"
$OperatingSystems = Get-ChildItem -Path "DS001:\Operating Systems"

if ($OperatingSystems) {
  [int]$counter = 0
  foreach ($OS in $OperatingSystems) {
    $Counter++
    $WimName = Split-Path -Path $OS.Source -Leaf
    $params = @{
      Path                = "DS001:\Task Sequences"
      Name                = "$($OS.Description) in $WimName"
      Template            = "Client.xml"
      Comments            = ""
      Id                  = $Counter
      version             = "1.0"
      OperatingSystemPath = "DS001:\Operating Systems\$($OS.Name)"
      FullName            = "fullname"
      OrgName             = "org"
      HomePage            = "about:blank"
      Verbose             = $true
      ErrorAction         = "Stop"
    }
    Import-MDTTaskSequence @params
  }
}

if (!$wimPath) {
  Write-Output "Skipping as no WIM found"
}

#Edit Bootstrap.ini
$bootstrapIni = @"
[Settings]
Priority=Default
[Default]
DeployRoot=\\$env:COMPUTERNAME\DeploymentShare$
SkipBDDWelcome=YES
UserDomain=$env:COMPUTERNAME
UserID=$localUser
UserPassword=$ServiceAccountPassword
"@

Set-Content -Path "$DeploymentShareDrive\DeploymentShare\Control\Bootstrap.ini" -Value $bootstrapIni -Force -Confirm:$false

#Create LiteTouch Boot WIM & ISO
Write-Output "Creating LiteTouch Boot Media"
Update-MDTDeploymentShare -Path "DS001:" -Force -Verbose -ErrorAction Stop

#Download & Import Office 365 2016
if ($Office365) {
  Write-Output "Downloading Office Deployment Toolkit"
  New-Item -ItemType Directory -Path "$PSScriptRoot\odt"
  $params = @{
    Source      = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_10306.33602.exe"
    Destination = "$PSScriptRoot\odt\officedeploymenttool.exe"
    ErrorAction = "Stop"
  }
  Start-BitsTransfer @params

  Write-Output "Extracting Office Deployment Toolkit"
  $params = @{
    FilePath     = "$PSScriptRoot\odt\officedeploymenttool.exe"
    ArgumentList = "/quiet /extract:$PSScriptRoot\odt"
    ErrorAction  = "Stop"
  }
  Start-Process @params -Wait
  Remove-Item "$PSScriptRoot\odt\officedeploymenttool.exe" -Force -Confirm:$false -ErrorAction Stop

  Write-Output "Remove Visio"
  $xml = @"
<Configuration>
  <Add OfficeClientEdition="32" Channel="Monthly">
    <Product ID="O365ProPlusRetail">
      <Language ID="en-us" />
      <ExcludeApp ID="Groove" />
    </Product>
  </Add>
</Configuration>
"@
  Set-Content -Path "$PSScriptRoot\odt\configuration.xml" -Value $xml -Force -Confirm:$false

  Write-Output "Importing Office 365 into MDT"
  $params = @{
    Path                  = "DS001:\Applications"
    Name                  = "Microsoft Office 365 2016 Monthly"
    ShortName             = "Office 365 2016"
    Publisher             = "Microsoft"
    Language              = ""
    Enable                = "True"
    version               = "Monthly"
    Verbose               = $true
    ErrorAction           = "Stop"
    CommandLine           = "setup.exe /configure configuration.xml"
    WorkingDirectory      = ".\Applications\Microsoft Office 365 2016 Monthly"
    ApplicationSourcePath = "$PSScriptRoot\odt"
    DestinationFolder     = "Microsoft Office 365 2016 Monthly"
  }
  Import-MDTApplication @params
}

if ($Applications) {
  $AppList = @"
[
    {
        "name": "Google Chrome Enterprise",
        "version": "67.0.3396.87",
        "download": "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi",
        "filename": "googlechromestandaloneenterprise64.msi",
        "install": "msiexec /i googlechromestandaloneenterprise64.msi /qb"
    },
    {
        "name": "Mozilla Firefox",
        "version": "60.0.2",
        "download": "https://download-installer.cdn.mozilla.net/pub/firefox/releases/60.0.2/win64/en-GB/Firefox%20Setup%2060.0.2.exe",
        "filename": "firefox.exe",
        "install": "firefox.exe /S"
    },
    {
        "name": "7-Zip",
        "version": "18.05",
        "download": "https://www.7-zip.org/a/7z1805-x64.msi",
        "filename": "7z1805-x64.msi",
        "install": "msiexec /i 7z1805-x64.msi /qb"
    },
    {
        "name": "Visual Studio Code",
        "version": "1.24.1",
        "download": "https://az764295.vo.msecnd.net/stable/24f62626b222e9a8313213fb64b10d741a326288/VSCodeSetup-x64-1.24.1.exe",
        "filename": "VSCodeSetup-x64-1.24.1.exe",
        "install": "VSCodeSetup-x64-1.24.1.exe /VERYSILENT"
    },
    {
        "name": "Node.js",
        "version": "10.5.0",
        "download": "https://nodejs.org/dist/v10.5.0/node-v10.5.0-x64.msi",
        "filename": "node-v10.5.0-x64.msi",
        "install": "msiexec /i node-v10.5.0-x64.msi /qb"
    },
    {
        "name": "MongoDB",
        "version": "3.6.5",
        "download": "https://downloads.mongodb.org/win32/mongodb-win32-x86_64-2008plus-ssl-3.6.5-signed.msi",
        "filename": "mongodb-win32-x86_64-2008plus-ssl-3.6.5-signed.msi",
        "install": "msiexec /i mongodb-win32-x86_64-2008plus-ssl-3.6.5-signed.msi /qb"
    },
    {
        "name": "VLC media player",
        "version": "3.0.3",
        "download": "http://mirror.lchost.net/videolan/vlc/3.0.3/win64/vlc-3.0.3-win64.exe",
        "filename": "vlc-3.0.3-win64.exe",
        "install": "vlc-3.0.3-win64.exe /L=1033 /S"
    },
    {
        "name": "Adobe Reader DC",
        "version": "2015.007.20033.02",
        "download": "http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1500720033/AcroRdrDC1500720033_MUI.exe",
        "filename": "AcroRdrDC1500720033_MUI.exe",
        "install": "AcroRdrDC1500720033_MUI.exe /sAll /rs /rps /msi /norestart /quiet ALLUSERS=1 EULA_ACCEPT=YES"
    }
]
"@
  $AppList = ConvertFrom-Json $AppList

  foreach ($Application in $AppList) {
    New-Item -Path "$PSScriptRoot\mdt_apps\$($application.name)" -ItemType Directory -Force
    Start-BitsTransfer -Source $Application.download -Destination "$PSScriptRoot\mdt_apps\$($application.name)\$($Application.filename)"
    $params = @{
      Path                  = "DS001:\Applications"
      Name                  = $Application.Name
      ShortName             = $Application.Name
      Publisher             = ""
      Language              = ""
      Enable                = "True"
      version               = $Application.version
      Verbose               = $true
      ErrorAction           = "Stop"
      CommandLine           = $Application.install
      WorkingDirectory      = ".\Applications\$($Application.name)"
      ApplicationSourcePath = "$PSScriptRoot\mdt_apps\$($application.name)"
      DestinationFolder     = $Application.Name
    }
    Import-MDTApplication @params
  }
  Remove-Item -Path "$PSScriptRoot\mdt_apps" -Recurse -Force -Confirm:$false
}

#Finish
Write-Output "Script Finished"
