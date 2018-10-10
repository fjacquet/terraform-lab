# Script Author
# http://justanothertechnicalblog.blogspot.co.uk/2014/10/create-system-management-container-with.html

#SCCM - Install Prerequisites
add-windowsfeature -Name "Net-Framework-Core" -Source D:\sources\sxs
add-windowsfeature -Name "RDC","BITS","Web-WMI","RSAT-AD-PowerShell"

# Get the distinguished name of the Active Directory domain
$DomainDN = (Get-ADDomain).DistinguishedName

# Get the AD computer object for this system
$ThisSiteSystem = Get-ADComputer $env:ComputerName

# Build distinguished name path of the System container
$SystemDN = "CN=System," + $DomainDN

# Get or create the System Management container
$Container = $null
try {
  $Container = Get-ADObject "CN=System Management,$SystemDN"
}
catch {
  Write-Verbose "System Management container does not exist."
}

if ($Container -eq $null) {
  $Container = New-ADObject -Type Container -Name "System Management" `
     -Path "$SystemDN" -Passthru
}

# Get current ACL for the System Management container
$ACL = Get-Acl -Path AD:\$Container

# Get the SID for the computer object
$SID = [System.Security.Principal.SecurityIdentifier]$ThisSiteSystem.SID

# Create a new access control entry for the System Management container
$adRights = [System.DirectoryServices.ActiveDirectoryRights]"GenericAll"
$type = [System.Security.AccessControl.AccessControlType]"Allow"
$inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance]"All"
$ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
   $SID,$adRights,$type,$inheritanceType

# Add the new access control entry to the ACL object we grabbed earlier
$ACL.AddAccessRule($ACE)

# Commit the new audit rule
Set-Acl -AclObject $ACL -Path "AD:$Container"


New-Item -ItemType Directory -Path C:\installers

$params = @{
  Source = "https://download.microsoft.com/download/3/1/E/31EC1AAF-3501-4BB4-B61C-8BD8A07B4E8A/adk/adksetup.exe"
  Destination = "c:\installers\adk_setup.exe"
}
Start-BitsTransfer @params

$params = @{
  FilePath = "c:\installers\adk_setup.exe"
  Wait = $true
  ArgumentList = "/quiet /features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment OptionId.UserStateMigrationTool"
}
Start-Process @params
