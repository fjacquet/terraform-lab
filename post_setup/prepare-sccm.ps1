# Script Author
# http://justanothertechnicalblog.blogspot.co.uk/2014/10/create-system-management-container-with.html

Add-WindowsFeature RSAT-AD-PowerShell

# Get the distinguished name of the Active Directory domain
$DomainDN = (Get-ADDomain).DistinguishedName
 
# Get the AD computer object for this system
$ThisSiteSystem = Get-ADComputer $env:ComputerName 
 
# Build distinguished name path of the System container
$SystemDN = "CN=System," + $DomainDN
 
# Get or create the System Management container
$Container = $null
Try 
 { 
    $Container = Get-ADObject "CN=System Management,$SystemDN"
 } 
Catch 
 { 
    Write-Verbose "System Management container does not exist."
 }
 
If ($Container -eq $null) 
 { 
    $Container = New-ADObject -Type Container -name "System Management" `
                                             -Path "$SystemDN" -Passthru
 }
 
# Get current ACL for the System Management container
$ACL = Get-ACL -Path AD:\$Container
 
# Get the SID for the computer object
$SID = [System.Security.Principal.SecurityIdentifier] $ThisSiteSystem.SID
 
# Create a new access control entry for the System Management container
$adRights = [System.DirectoryServices.ActiveDirectoryRights] "GenericAll"
$type = [System.Security.AccessControl.AccessControlType] "Allow"
$inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
$ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
                                     $SID,$adRights,$type,$inheritanceType
 
# Add the new access control entry to the ACL object we grabbed earlier
$ACL.AddAccessRule($ACE)
 
# Commit the new audit rule
Set-ACL -AclObject $ACL -Path "AD:$Container" 