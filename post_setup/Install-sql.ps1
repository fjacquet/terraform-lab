#----------------------------------------------------------------------------------------------------
#Script notes

<#
- This script is primarily for setting up AAG's, but *can* be used to acclerate the setup of traditional SQL clusters and standalone nodes.
- This script is not designed to do a bulk copy and run, it's designed to copy blocks and execute.
- Some sections only need to be run once for the whole cluster, some sections need to be run per node. I'll try to note when and where
- Some sections can not be complete until all nodes are at the same step.  When in doubt, perform these steps on each node in lock step
#>


#END Script notes
#----------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------
#Pre-script steps

<#
- Deploy SQL Servers
- Deploy disks (but don't bring them online or format them).  We'll do that in this script.
- Configure local administration
- Add computer accounts the appropriate AD group that gives the computer accounts "manage computer" rights.
- Move the computers to the correct OU
- Reboot the computers twice after all the above is complete
- If UAT / PRD, create the service accounts (agent and service)
- related to UAT / PRD service accounts, make sure they have access to the backup share.  Look at the other service accounts (member of) in AD
- Reseve all IP's needed for cluster named object, listeners / database instance
#> #----------------------------------------------------------------------------------------------------
#Script notes

<#
- This script is primarily for setting up AAG's, but *can* be used to acclerate the setup of traditional SQL clusters and standalone nodes.
- This script is not designed to do a bulk copy and run, it's designed to copy blocks and execute.
- Some sections only need to be run once for the whole cluster, some sections need to be run per node. I'll try to note when and where
- Some sections can not be complete until all nodes are at the same step.  When in doubt, perform these steps on each node in lock step
#>


#END Script notes
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Pre-script steps

<#
- Deploy SQL Servers
- Deploy disks (but don't bring them online or format them).  We'll do that in this script.
- Configure local administration
- Add computer accounts the appropriate AD group that gives the computer accounts "manage computer" rights.
- Move the computers to the correct OU
- Reboot the computers twice after all the above is complete
- If UAT / PRD, create the service accounts (agent and service)
- related to UAT / PRD service accounts, make sure they have access to the backup share.  Look at the other service accounts (member of) in AD
- Reseve all IP's needed for cluster named object, listeners / database instance
#>


#END Pre-script steps
#----------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------
#Parameters

$domain = 'evlab'
#File Path to local GPO function
$LocalGPOFunctionName = "Add-ECSLocalGPOUserRightAssignment.ps1"
$LocalGPOFunctionFilePath = "\\a1-file-04\SysAdminStuff\SQL Servers\Functions" + "\" + $LocalGPOFunctionName

#File Path to SQL config file
$ConfigFileName = "ConfigurationFile_Template_2017plus.ini"
$ConfigFileSource = "\\a1-file-04\SysAdminStuff\SQL Servers\" + $ConfigFileName
$ConfigFileDestination = "K:\" + $ConfigFileName

#File path to SSMS
$SSMSFileName = "SSMS-Setup-ENU.exe"
$SSMSFileSource = "\\$(domain).ch\Servers\ISG Software\Microsoft\SQL Server Management Studio\17.4\" + $SSMSFileName
$SSMSFileDestination = "K:\" + $SSMSFileName

#File Path to SQL ISO of your choice
$ISOFileName = "SW_DVD9_NTRL_SQL_Svr_Ent_Core_2017_64Bit_English_OEM_VL_X21-56995.ISO"
$ISOFileSource = "\\$(domain).ch\Servers\ISG Software\Microsoft\SQL Enterprise 2017\" + $ISOFileName
$ISOFileDestination = "K:\" + $ISOFileName

#Service Account
$sqlserviceuserNoDomain = "usrsqlpc15svc"
$sqlserviceuser = "$(domain)\" + $sqlserviceuserNoDomain
$sqlagentuserNoDomain = "usrsqlpc15agt"
$sqlagentuser = "$(domain)\" + $sqlagentuserNoDomain


##Clustering
$node1 = "a1-sqlpcn1-15"
$node2 = "a1-sqlpcn2-15"
$clusterip = "192.168.1.19"
$ClusterCNO = "a1-sqlpc-15"
$DB1Name = "Test1"
$DB2Name = "Test2"
$DB3Name = "Test3"
$DB4Name = "Test4"
$SQLAAGEndPointName = "Hadr_endpoint"
$AAG1Name = "a1-sqlpcdg1-15"
$AAG2Name = "a1-sqlpcdg2-15"
$AAG3Name = "a1-sqlpcdg3-15"
$AAG4Name = "a1-sqlpcdg4-15"
$AAG1IP = "192.168.1.20/255.255.255.0"
$AAG2IP = "192.168.1.21/255.255.255.0"
$AAG3IP = "192.168.1.22/255.255.255.0"
$AAG4IP = "192.168.1.23/255.255.255.0"

#File Share Wittness

<#
Note 1: FSW is only needed if you're setting up an AAG.  Traditional failover clusters, don't need this, instead they need a quorum disk.  This script does not cover that.
Note 2: There are currently four different file share wittness locations.  See below

Odd numbered clusters (for example a1-sqluc-01, 03, 05, etc.) go here
UAT = \\a1-fswus1-02\Clusters
PRD = \\a1-fswps1-02\Clusters

Even numbered clusters (for example a1-sqluc-02, 04, 06, etc.) go here
UAT = \\a1-fswus2-02\Clusters
PRD = \\a1-fswps2-02\Clusters

#>
$filesharewitness = "\\a1-fswps1-02\Clusters\$($ClusterCNO)"

#Backup Share

<#
This step is only needed if you're setting up an AAG, otherwise the DBA's will do this.

Here are the following paths
\\$(domain).ch\Backups\SQL Backups 2\DEV
\\$(domain).ch\Backups\SQL Backups 2\PRD
\\$(domain).ch\Backups\SQL Backups 2\STG
\\$(domain).ch\Backups\SQL Backups 2\TST
\\$(domain).ch\Backups\SQL Backups 2\UAT

#>
$BackupSharePath = "\\$(domain).ch\Backups\SQL Backups 2\PRD\$($node1)"

#DB backup names
$TestDB1FullPath = $BackupSharePath + "\" + $DB1Name + ".bak"
$TestDB2FullPath = $BackupSharePath + "\" + $DB2Name + ".bak"
$TestDB3FullPath = $BackupSharePath + "\" + $DB3Name + ".bak"
$TestDB4FullPath = $BackupSharePath + "\" + $DB4Name + ".bak"
$TestLog1FullPath = $BackupSharePath + "\" + $DB1Name + ".log"
$TestLog2FullPath = $BackupSharePath + "\" + $DB2Name + ".log"
$TestLog3FullPath = $BackupSharePath + "\" + $DB3Name + ".log"
$TestLog4FullPath = $BackupSharePath + "\" + $DB4Name + ".log"


#AAG information

#Dynamic parameters

#These passwords will be used to automate the setup of SQL.
$sqlagentuserpassword = Read-Host -Prompt "Enter your SQL Agent Account Password Here"
while ($sqlagentuserpassword -eq $null -or $sqlagentuserpassword -eq "")
{
  $sqlagentuserpassword = Read-Host -Prompt "Enter your SQL Agent Account Password Here"
}

$sqlserviceuserpassword = Read-Host -Prompt "Enter your SQL Service Account Password Here"
while ($sqlserviceuserpassword -eq $null -or $sqlserviceuserpassword -eq "")
{
  $sqlserviceuserpassword = Read-Host -Prompt "Enter your SQL Service Account Password Here"
}

#Temp Directory
$TempDirectory = Get-ChildItem -Path env: | Where-Object { $_.Name -eq "Temp" } | Select-Object -ExpandProperty value
$LocalGPOFunctionNameTempPath = $TempDirectory + "\" + $LocalGPOFunctionName

#ComputerName
$ComputerName = Get-ChildItem -Path env: | Where-Object { $_.Name -like "ComputerName" } | Select-Object -ExpandProperty value

#END Parameters
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Setting up the physical disks

#Get all offline disks, should be any disks you've created
$OfflineDisks = Get-Disk | Where-Object { $_.OperationalStatus -eq "Offline" }

#Set Disk online
$OfflineDisks | Set-Disk -IsOffline:$false

#Disable read only
$OfflineDisks | Set-Disk -IsReadOnly:$false

#Initialize Disks
$OfflineDisks | Initialize-Disk -PartitionStyle GPT

#loop through all disks and configure based on thier location.  This location is based on VMware controller card and controller port locations.  In VMware you should have the following SCSI configs
#0:0 = C: = OS = disk 1
#0:1 = K: = Misc = disk 2
#1:0 = F: = UserDB1 = disk 3
#1:1 = N: = Index1 = disk 4
#2:0 = J: = UserLog1 = disk 5
#3:0 = V: = TempLog = disk 6
#3:1 = W: = TempDB = disk 7

#Microsoft in their infinite wisdom, continues to change f'ing property values around, so below is the server 2016 specific scsi id

foreach ($disk in $OfflineDisks)
{
  #This will give us the view of which SCSI card and port we're in.
  #Note: property "SCSIPort" actually equals SCSI card in WMI, and "SCSITargetId" equals the SCSI port for the card


  $WMIDiskInformation = Get-WmiObject -Class win32_diskdrive | Where-Object { $_.DeviceID -like "*$($disk.number)" }


  if ($WMIDiskInformation.SCSIPort -eq 2 -and $WMIDiskInformation.SCSITargetId -eq 1)
  {
    Write-Output "K:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 4096 -NewFileSystemLabel "Misc" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter k
  }

  elseif ($WMIDiskInformation.SCSIPort -eq 3 -and $WMIDiskInformation.SCSITargetId -eq 0)
  {
    Write-Output "V:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 4096 -NewFileSystemLabel "TempLog" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter V
  }
  elseif ($WMIDiskInformation.SCSIPort -eq 3 -and $WMIDiskInformation.SCSITargetId -eq 1)
  {
    Write-Output "w:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 8192 -NewFileSystemLabel "TempDB" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter w
  }
  elseif ($WMIDiskInformation.SCSIPort -eq 4 -and $WMIDiskInformation.SCSITargetId -eq 0)
  {
    Write-Output "F:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 8192 -NewFileSystemLabel "UserDB1" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter f
  }
  elseif ($WMIDiskInformation.SCSIPort -eq 4 -and $WMIDiskInformation.SCSITargetId -eq 1)
  {
    Write-Output "N:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 8192 -NewFileSystemLabel "Index1" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter n
  }
  elseif ($WMIDiskInformation.SCSIPort -eq 5 -and $WMIDiskInformation.SCSITargetId -eq 0)
  {
    Write-Output "J:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 4096 -NewFileSystemLabel "UserLog1" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter j
  }
  elseif ($WMIDiskInformation.SCSIPort -eq 4 -and $WMIDiskInformation.SCSITargetId -eq 2)
  {
    Write-Output "G:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 8192 -NewFileSystemLabel "UserDB2" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter G
  }
}

#END Setting up the physical disks
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Setting up the folder paths and permissions

# Note 1: If you have more than the standard F, J, K, N, V and W drives, you'll need to mananually setup the folder structure and permsissions
# Note 2: As part of the SQL install, SQL will configure the modify permissions for the default DB, Log, TempLog and TempDB folders, which is why I don't configure them.
# NOte 3: Keep an eye on the folder permissions, you shouldn't see a lot of errors, if you do, something went wrong.
# Note 4: These are based on default disk locations and default disk requests.  if you get a request for a G: drive for example, we don't have that scripted at the moment.

#Create Folder Stucture

#F: Drive
if ((Test-Path "F:\MSSQLDB\Data") -eq $false)
{
  New-Item -Path "F:\MSSQLDB\Data" -ItemType Container
}
if ((Test-Path "F:\OLAP\Data") -eq $false)
{
  New-Item -Path "F:\OLAP\Data" -ItemType Container
}

#J: Drive
if ((Test-Path "J:\MSSQLDB\Log") -eq $false)
{
  New-Item -Path "J:\MSSQLDB\Log" -ItemType Container
}
if ((Test-Path "J:\OLAP\Log") -eq $false)
{
  New-Item -Path "J:\OLAP\Log" -ItemType Container
}

#K: Drive
if ((Test-Path "K:\Config") -eq $false)
{
  New-Item -Path "K:\Config" -ItemType Container
}
if ((Test-Path "K:\MSSQL") -eq $false)
{
  New-Item -Path "K:\MSSQL" -ItemType Container
}
if ((Test-Path "K:\MSSQLDB") -eq $false)
{
  New-Item -Path "K:\MSSQLDB" -ItemType Container
}
if ((Test-Path "K:\OLAP\config") -eq $false)
{
  New-Item -Path "K:\OLAP\config" -ItemType Container
}
if ((Test-Path "K:\Support") -eq $false)
{
  New-Item -Path "K:\Support" -ItemType Container
}

#N: Drive
if ((Test-Path "N:\MSSQLDB\Index") -eq $false)
{
  New-Item -Path "N:\MSSQLDB\Index" -ItemType Container
}

#V: Drive
if ((Test-Path "V:\MSSQLDB\Log") -eq $false)
{
  New-Item -Path "V:\MSSQLDB\Log" -ItemType Container
}

#W: Drive
if ((Test-Path "W:\MSSQLDB\Data") -eq $false)
{
  New-Item -Path "W:\MSSQLDB\Data" -ItemType Container
}
if ((Test-Path "W:\OLAP\Temp") -eq $false)
{
  New-Item -Path "W:\OLAP\Temp" -ItemType Container
}

#Adding a catch for the G: drive
$GDRive = Get-PSDrive | Where-Object { $_.Root -like "G:*" }

if ($GDRive -ne $null)
{
  if ((Test-Path "G:\MSSQLDB\Data") -eq $false)
  {
    New-Item -Path "G:\MSSQLDB\Data" -ItemType Container
  }
  if ((Test-Path "G:\OLAP\Data") -eq $false)
  {
    New-Item -Path "G:\OLAP\Data" -ItemType Container
  }

}

#Set Permissions

#F: Drive
Start-Process -FilePath "icacls.exe" -ArgumentList "f:\ /remove Everyone /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "f:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "f:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "f: /grant:rx ""$sqlserviceuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "f: /grant:rx ""$sqlagentuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait

#J: Drive
Start-Process -FilePath "icacls.exe" -ArgumentList "j:\ /remove Everyone /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "j:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "j:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "j: /grant:rx ""$sqlserviceuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "j: /grant:rx ""$sqlagentuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait

#K: Drive
Start-Process -FilePath "icacls.exe" -ArgumentList "k:\ /remove Everyone /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "k:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "k:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "k: /grant:rx ""$sqlserviceuser"":(OI)(CI)(M) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "k: /grant:rx ""$sqlagentuser"":(OI)(CI)(M) /C" -NoNewWindow -Wait

#N: Drive
Start-Process -FilePath "icacls.exe" -ArgumentList "n:\ /remove Everyone /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "n:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "n:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "n: /grant:rx ""$sqlserviceuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "n: /grant:rx ""$sqlagentuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "N:\MSSQLDB\Index /grant:rx ""$sqlserviceuser"":(OI)(CI)(F) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "N:\MSSQLDB\Index /grant:rx ""$sqlagentuser"":(OI)(CI)(F) /C" -NoNewWindow -Wait

#V: Drive
Start-Process -FilePath "icacls.exe" -ArgumentList "v:\ /remove Everyone /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "v:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "v:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "v: /grant:rx ""$sqlserviceuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "v: /grant:rx ""$sqlagentuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait

#W: Drive
Start-Process -FilePath "icacls.exe" -ArgumentList "w:\ /remove Everyone /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "w:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "w:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "w: /grant:rx ""$sqlserviceuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "w: /grant:rx ""$sqlagentuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait

#Adding a catch for the G: drive
if ($GDRive -ne $null)
{
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\ /remove Everyone /T" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g: /grant:rx ""$sqlserviceuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g: /grant:rx ""$sqlagentuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\MSSQLDB\Data /grant:rx ""$sqlserviceuser"":(OI)(CI)(F) /C" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\MSSQLDB\Data /grant:rx ""$sqlagentuser"":(OI)(CI)(F) /C" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\OLAP\DATA /grant:rx ""$sqlserviceuser"":(OI)(CI)(F) /C" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\OLAP\DATA /grant:rx ""$sqlagentuser"":(OI)(CI)(F) /C" -NoNewWindow -Wait
}

#END Setting up the folder paths and permissions
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Add SQL service account and agent to perform volume maitanance tasks local GPO

#NOTE: You can find this setting buried in Computer\Windows\Security\Local Policies\User Rights Assignment

#Copy our function to the temp directory
Copy-Item -Path $LocalGPOFunctionFilePath -Destination $TempDirectory -Force -confirm:$false

#Function Name to load

#Import function
.$LocalGPOFunctionNameTempPath

#Add the service account
Add-ECSLocalGPOUserRightAssignment -UserOrGroup $sqlserviceuser -UserRightAssignment "SeManageVolumePrivilege"

#Add the agent account
Add-ECSLocalGPOUserRightAssignment -UserOrGroup $sqlagentuser -UserRightAssignment "SeManageVolumePrivilege"

#END Add SQL service account and agent to perform volume maitanance tasks local GPO
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Install SQL

#Copy the ISO to
Copy-Item -Path $ISOFileSource -Destination $ISOFileDestination -Force -confirm:$false

#Copy the SQL config file
Copy-Item -Path $ConfigFileSource -Destination $ConfigFileDestination -Force -Container:$false

#Copy the SSMS to the K:
Copy-Item -Path $SSMSFileSource -Destination $SSMSFileDestination -Force -Container:$false

#Modfiy the config file to update it for our SQL accounts
$ConfigFileContent = (Get-Content -Path $ConfigFileDestination).Replace("$(domain)\SQLSERVICEACCOUNTTOCHANGE",$sqlserviceuser) | Set-Content -Path $ConfigFileDestination
$ConfigFileContent = (Get-Content -Path $ConfigFileDestination).Replace("$(domain)\SQLAGENTACCOUNTTOCHANGE",$sqlagentuser) | Set-Content -Path $ConfigFileDestination

#Mount the ISO
$mountResult = Mount-DiskImage $ISOFileDestination -Passthru
$ISOVolume = $mountResult | Get-Volume

#Define the SQL install path
$SQLInstallPath = $($isovolume.driveletter) + ":\setup.exe"

#Install SQL
Start-Process -FilePath $SQLInstallPath -ArgumentList "/SQLSVCPASSWORD=""$sqlserviceuserpassword"" /AGTSVCPASSWORD=""$sqlagentuserpassword"" /ISSVCPASSWORD=""$sqlserviceuserpassword"" /ASSVCPASSWORD=""$sqlserviceuserpassword"" /ConfigurationFile=$($ConfigFileDestination) /IAcceptSQLServerLicenseTerms" -NoNewWindow -Wait

#Install SSSMS
Start-Process -FilePath $SSMSFileDestination -ArgumentList "/passive /norestart" -NoNewWindow -Wait

#END Install SQL
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Register SPNs

Start-Process -FilePath setspn -ArgumentList "-A MSSQLSvc/$($ComputerName).$(domain).ch:1433  $($sqlserviceuserNoDomain)  " -NoNewWindow -Wait -Passthru
Start-Process -FilePath setspn -ArgumentList "-A MSSQLSvc/$($ComputerName).$(domain).ch $($sqlserviceuserNoDomain)  " -NoNewWindow -Wait -Passthru

#END Register SPNs
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Auto Load SQL PS Module

#The included SQL module isn't kept up to date, so we're going to install the latest module from MS git
Install-Module sqlserver -AllowClobber

#Import the module
Import-Module sqlserver -DisableNameChecking

#End Auto Load SQL PS Module
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Configure SQL, all SQL servers

#SQL Object
$SQLObject = New-Object Microsoft.SqlServer.Management.Smo.Server

#Getting the server information
$server = New-Object Microsoft.SqlServer.Management.Smo.Server $env:ComputerName

#Configure SQL Memory
$MaxMemory = $($server.PhysicalMemory) - 4096
$MinMemory = $($server.PhysicalMemory) / 2

Invoke-Sqlcmd -Database Master -Query "EXEC  sp_configure'Show Advanced Options',1;RECONFIGURE;"
Invoke-Sqlcmd -Database Master -Query "EXEC  sp_configure'max server memory (MB)',$MaxMemory;RECONFIGURE;"
Invoke-Sqlcmd -Database Master -Query "EXEC  sp_configure'min server memory (MB)',$MinMemory;RECONFIGURE;"

#End Configure SQL, all SQL servers
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Install Cluster feature

Install-WindowsFeature -Name Failover-Clustering ?IncludeManagementTools

#END Install Cluster feature
#----------------------------------------------------------------------------------------------------









#!!!!!!!!!!!!!!!!!!!!THIS NEXT STEP ONLY NEEDS TO BE RUN ON ONE NODE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!












#----------------------------------------------------------------------------------------------------
#Setup and configure cluster (only one node)

#Configure cluster (only run once on eaither node)
New-Cluster ?Name $ClusterCNO -Node $node1,$node2 ?StaticAddress $clusterip -nostorage

#Configure file share witness folder
if ((Test-Path $filesharewitness) -eq $false)
{
  New-Item -Path $filesharewitness -ItemType Container
}

#Set file share permissions
Start-Process -FilePath "icacls.exe" -ArgumentList """$filesharewitness"" /grant ""$(domain)\$ClusterCNO$"":(OI)(CI)(F) /C" -NoNewWindow -Wait

#Set quorum for the cluster
#Note 1:  This is for AAG's only, if you are setting up a traditional cluster, you'll need to setup a disk based quorum
Set-ClusterQuorum ?NodeAndFileShareMajority $filesharewitness

#Set Cluster Timeout to 10 seconds
(Get-Cluster).SameSubnetThreshold = 10

#Stop the cluster service so you can give it the correct AD rights
Get-Cluster -Name $ClusterCNO | Stop-Cluster -Force -confirm:$false


#!!!!!!!!!!!!!Add the cluster CNO to the same AD group that you added the invidvidual nodes to


#After assigning the rights, start the cluster service
Get-Service -Name ClusSvc -ComputerName $node1 | Start-Service
Get-Service -Name ClusSvc -ComputerName $node2 | Start-Service

#END Setup and configure cluster (only one node)
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Enable SQL AAG, AAG only

#Enable SQL Always on (run on both nodes)

#NOTE: This may fail once, wait a minute, then try again.
Enable-SqlAlwaysOn -ServerInstance $($env:ComputerName) -confirm:$false -NoServiceRestart:$false -Force:$true

#End Enable SQL AAG, AAG only
#----------------------------------------------------------------------------------------------------

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Run these next steps only from one node !!!!!!!!!!!!!!!!!!!!!!!!!!!!


#----------------------------------------------------------------------------------------------------
#Prepare SQL for new AAG (only one node)

#Create a DB per listener.  Typically two, but sometimes more / less

#DB1
$db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database ($SQLObject,$DB1Name)
$db.Create()

#DB2
$db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database ($SQLObject,$DB2Name)
$db.Create()

#DB3
$db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database ($SQLObject,$DB3Name)
$db.Create()

#DB4
$db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database ($SQLObject,$DB4Name)
$db.Create()

#Confirm, list databases in your current instance
$SQLObject.Databases | Select-Object Name,Status,Owner,CreateDate

#Configure the backup share
if ((Test-Path $BackupSharePath) -eq $false)
{
  New-Item -Path $BackupSharePath -ItemType Container
}



#Now we need to backup all of the newly created DB's
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB1Name -BackupFile $TestDB1FullPath
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB2Name -BackupFile $TestDB2FullPath
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB3Name -BackupFile $TestDB3FullPath
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB4Name -BackupFile $TestDB4FullPath

#END Prepare SQL for new AAG (only one node)
#----------------------------------------------------------------------------------------------------

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Run these next steps only from one node !!!!!!!!!!!!!!!!!!!!!!!!!!!!

#----------------------------------------------------------------------------------------------------
#Setup the AAG (only one node)

#Create the endpoints for each SQL AAG replica
New-SqlHADREndpoint -Path "SQLSERVER:\SQL\$($node1)\Default" -Name $($SQLAAGEndPointName) -Port 5022 -EncryptionAlgorithm Aes -Encryption Required
New-SqlHADREndpoint -Path "SQLSERVER:\SQL\$($node2)\Default" -Name $($SQLAAGEndPointName) -Port 5022 -EncryptionAlgorithm Aes -Encryption Required

#Stare the endpoints for each AAG replica
Set-SqlHADREndpoint -Path "SQLSERVER:\SQL\$($node1)\Default\Endpoints\$($SQLAAGEndPointName)" -State Started
Set-SqlHADREndpoint -Path "SQLSERVER:\SQL\$($node2)\Default\Endpoints\$($SQLAAGEndPointName)" -State Started

#Create a SQL login for the SQL service account so each server can connect to each other.
$createLogin = ?CREATE LOGIN [$($sqlserviceuser)] FROM WINDOWS; Where-Object
$grantConnectPermissions = ?GRANT CONNECT ON ENDPOINT::$($SQLAAGEndPointName) TO [$($sqlserviceuser)]; Where-Object
Invoke-Sqlcmd -ServerInstance $($node1) -Query $createLogin
Invoke-Sqlcmd -ServerInstance $($node1) -Query $grantConnectPermissions
Invoke-Sqlcmd -ServerInstance $($node2) -Query $createLogin
Invoke-Sqlcmd -ServerInstance $($node2) -Query $grantConnectPermissions

#Create replicas

##########This is for non-seeded AAG's (traditional backup / restore AAGs)

#Create the replicas
$primaryReplica = New-SqlAvailabilityReplica -Name $($node1) -EndpointUrl ?TCP://$($node1).$(domain).ch:5022? -AvailabilityMode ?SynchronousCommit? -FailoverMode 'Automatic' -AsTemplate -Version $SQLObject.version
$secondaryReplica = New-SqlAvailabilityReplica -Name $($node2) -EndpointUrl ?TCP://$($node2).$(domain).ch:5022? -AvailabilityMode ?SynchronousCommit? -FailoverMode 'Automatic' -AsTemplate -Version $SQLObject.version

#Buildthe AAG's
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG1Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -Database $DB1Name -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG2Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -Database $DB2Name -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG3Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -Database $DB3Name -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG4Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -Database $DB4Name -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc

#Now we need to backup all db's (both full and log)
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB1Name -BackupFile $TestDB1FullPath
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB2Name -BackupFile $TestDB2FullPath
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB3Name -BackupFile $TestDB3FullPath
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB4Name -BackupFile $TestDB4FullPath

Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB1Name -BackupFile $TestLog1FullPath -BackupAction Log
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB2Name -BackupFile $TestLog2FullPath -BackupAction Log
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB3Name -BackupFile $TestLog3FullPath -BackupAction Log
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB4Name -BackupFile $TestLog4FullPath -BackupAction Log

#Now we need to restore the DB's
Restore-SqlDatabase -Database $DB1Name -BackupFile $TestDB1FullPath -ServerInstance $($node2) -NoRecovery
Restore-SqlDatabase -Database $DB2Name -BackupFile $TestDB2FullPath -ServerInstance $($node2) -NoRecovery
Restore-SqlDatabase -Database $DB3Name -BackupFile $TestDB3FullPath -ServerInstance $($node2) -NoRecovery
Restore-SqlDatabase -Database $DB4Name -BackupFile $TestDB4FullPath -ServerInstance $($node2) -NoRecovery

Restore-SqlDatabase -Database $DB1Name -BackupFile $TestLog1FullPath -ServerInstance $($node2) -NoRecovery -RestoreAction 'Log'
Restore-SqlDatabase -Database $DB2Name -BackupFile $TestLog2FullPath -ServerInstance $($node2) -NoRecovery -RestoreAction 'Log'
Restore-SqlDatabase -Database $DB3Name -BackupFile $TestLog3FullPath -ServerInstance $($node2) -NoRecovery -RestoreAction 'Log'
Restore-SqlDatabase -Database $DB4Name -BackupFile $TestLog4FullPath -ServerInstance $($node2) -NoRecovery -RestoreAction 'Log'

#Now we need to join the secondary nodes copy of the DB to the AAG
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node2)\Default\AvailabilityGroups\$($AAG1Name)" -Database $DB1Name
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node2)\default\AvailabilityGroups\$($AAG2Name)" -Database $DB2Name
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node2)\default\AvailabilityGroups\$($AAG3Name)" -Database $DB3Name
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node2)\default\AvailabilityGroups\$($AAG4Name)" -Database $DB4Name

########## END This is for non-seeded AAG's (traditional backup / restore AAGs)

#This is for seeded DB's, which is what we're doing in SQL 2017+

#Create the replica's
$primaryReplica = New-SqlAvailabilityReplica -Name $($node1) -EndpointUrl ?TCP://$($node1).$(domain).ch:5022? -AvailabilityMode ?SynchronousCommit? -FailoverMode 'Automatic' -AsTemplate -Version $SQLObject.version -SeedingMode Automatic
$secondaryReplica = New-SqlAvailabilityReplica -Name $($node2) -EndpointUrl ?TCP://$($node2).$(domain).ch:5022? -AvailabilityMode ?SynchronousCommit? -FailoverMode 'Automatic' -AsTemplate -Version $SQLObject.version -SeedingMode Automatic

#Create the AAG
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG1Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG2Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG3Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG4Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc

#Join secondary node to the AAG's
Join-SqlAvailabilityGroup -Path ?SQLSERVER:\SQL\$($node2)\Default? -Name $AAG1Name
Join-SqlAvailabilityGroup -Path ?SQLSERVER:\SQL\$($node2)\Default? -Name $AAG2Name
Join-SqlAvailabilityGroup -Path ?SQLSERVER:\SQL\$($node2)\Default? -Name $AAG3Name
Join-SqlAvailabilityGroup -Path ?SQLSERVER:\SQL\$($node2)\Default? -Name $AAG4Name

#Grant the AAG the rights to create a DB (only needed for seeding mode)
$AAG1CreateCommand = "ALTER AVAILABILITY GROUP [$($AAG1Name)] GRANT CREATE ANY DATABASE"
$AAG2CreateCommand = "ALTER AVAILABILITY GROUP [$($AAG2Name)] GRANT CREATE ANY DATABASE"
$AAG3CreateCommand = "ALTER AVAILABILITY GROUP [$($AAG3Name)] GRANT CREATE ANY DATABASE"
$AAG4CreateCommand = "ALTER AVAILABILITY GROUP [$($AAG4Name)] GRANT CREATE ANY DATABASE"

Invoke-Sqlcmd -ServerInstance $($node1) -Query $AAG1CreateCommand
Invoke-Sqlcmd -ServerInstance $($node2) -Query $AAG1CreateCommand

Invoke-Sqlcmd -ServerInstance $($node1) -Query $AAG2CreateCommand
Invoke-Sqlcmd -ServerInstance $($node2) -Query $AAG2CreateCommand

Invoke-Sqlcmd -ServerInstance $($node1) -Query $AAG3CreateCommand
Invoke-Sqlcmd -ServerInstance $($node2) -Query $AAG3CreateCommand

Invoke-Sqlcmd -ServerInstance $($node1) -Query $AAG4CreateCommand
Invoke-Sqlcmd -ServerInstance $($node2) -Query $AAG4CreateCommand

#Now we need to join the primary nodes copy of the DB to the AAG
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node1)\Default\AvailabilityGroups\$($AAG1Name)" -Database $DB1Name
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node1)\default\AvailabilityGroups\$($AAG2Name)" -Database $DB2Name
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node1)\default\AvailabilityGroups\$($AAG3Name)" -Database $DB3Name
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node1)\default\AvailabilityGroups\$($AAG4Name)" -Database $DB4Name



#Now we need to setup the listners (for both seeded and non-seeded AAG's)
New-SqlAvailabilityGroupListener -Name $($AAG1Name) -staticIP $AAG1IP -Port 1433 -Path "SQLSERVER:\SQL\$($node1)\DEFAULT\AvailabilityGroups\$($AAG1Name)"
New-SqlAvailabilityGroupListener -Name $($AAG2Name) -staticIP $AAG2IP -Port 1433 -Path "SQLSERVER:\SQL\$($node1)\DEFAULT\AvailabilityGroups\$($AAG2Name)"
New-SqlAvailabilityGroupListener -Name $($AAG3Name) -staticIP $AAG3IP -Port 1433 -Path "SQLSERVER:\SQL\$($node1)\DEFAULT\AvailabilityGroups\$($AAG3Name)"
New-SqlAvailabilityGroupListener -Name $($AAG4Name) -staticIP $AAG4IP -Port 1433 -Path "SQLSERVER:\SQL\$($node1)\DEFAULT\AvailabilityGroups\$($AAG4Name)"

#End Setup the AAG (only one node)
#----------------------------------------------------------------------------------------------------

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Run these next steps only from one node !!!!!!!!!!!!!!!!!!!!!!!!!!!!


#----------------------------------------------------------------------------------------------------
#Fix cluster setting and test cluster post AAG (only one node)

#Note you should be ready to walk through the wizzard to setup the AAG.  At somepoint I'll script this when I have more time.

#Fix cluster multi-subnet SQL listner setting
$ClusterResource = Get-ClusterResource | Where-Object { $_.ResourceType -eq "network name" -and $_.ownergroup -ne "Cluster Group" }
$ClusterResource | Set-ClusterParameter -Create RegisterAllProvidersIP 0
$ClusterResource | ForEach-Object { Stop-ClusterResource -Name $_.Name }
Get-ClusterResource | Where-Object { $_.ResourceType -eq "SQL Server Availability Group" } | ForEach-Object { Start-ClusterResource -Name $_.Name }

#Finally test the cluster
Test-Cluster

#END Fix cluster setting and test cluster post AAG(only one node)
#----------------------------------------------------------------------------------------------------


#END Pre-script steps
#----------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------
#Parameters

#File Path to local GPO function
$LocalGPOFunctionName = "Add-ECSLocalGPOUserRightAssignment.ps1"
$LocalGPOFunctionFilePath = "\\a1-file-04\SysAdminStuff\SQL Servers\Functions" + "\" + $LocalGPOFunctionName

#File Path to SQL config file
$ConfigFileName = "ConfigurationFile_Template_2017plus.ini"
$ConfigFileSource = "\\a1-file-04\SysAdminStuff\SQL Servers\" + $ConfigFileName
$ConfigFileDestination = "K:\" + $ConfigFileName

#File path to SSMS
$SSMSFileName = "SSMS-Setup-ENU.exe"
$SSMSFileSource = "\\$(domain).ch\Servers\ISG Software\Microsoft\SQL Server Management Studio\17.4\" + $SSMSFileName
$SSMSFileDestination = "K:\" + $SSMSFileName

#File Path to SQL ISO of your choice
$ISOFileName = "SW_DVD9_NTRL_SQL_Svr_Ent_Core_2017_64Bit_English_OEM_VL_X21-56995.ISO"
$ISOFileSource = "\\$(domain).ch\Servers\ISG Software\Microsoft\SQL Enterprise 2017\" + $ISOFileName
$ISOFileDestination = "K:\" + $ISOFileName

#Service Account
$sqlserviceuserNoDomain = "usrsqlpc15svc"
$sqlserviceuser = "$(domain)\" + $sqlserviceuserNoDomain
$sqlagentuserNoDomain = "usrsqlpc15agt"
$sqlagentuser = "$(domain)\" + $sqlagentuserNoDomain


##Clustering
$node1 = "a1-sqlpcn1-15"
$node2 = "a1-sqlpcn2-15"
$clusterip = "192.168.1.19"
$ClusterCNO = "a1-sqlpc-15"
$DB1Name = "Test1"
$DB2Name = "Test2"
$DB3Name = "Test3"
$DB4Name = "Test4"
$SQLAAGEndPointName = "Hadr_endpoint"
$AAG1Name = "a1-sqlpcdg1-15"
$AAG2Name = "a1-sqlpcdg2-15"
$AAG3Name = "a1-sqlpcdg3-15"
$AAG4Name = "a1-sqlpcdg4-15"
$AAG1IP = "192.168.1.20/255.255.255.0"
$AAG2IP = "192.168.1.21/255.255.255.0"
$AAG3IP = "192.168.1.22/255.255.255.0"
$AAG4IP = "192.168.1.23/255.255.255.0"

#File Share Wittness

<#
Note 1: FSW is only needed if you're setting up an AAG.  Traditional failover clusters, don't need this, instead they need a quorum disk.  This script does not cover that.
Note 2: There are currently four different file share wittness locations.  See below

Odd numbered clusters (for example a1-sqluc-01, 03, 05, etc.) go here
UAT = \\a1-fswus1-02\Clusters
PRD = \\a1-fswps1-02\Clusters

Even numbered clusters (for example a1-sqluc-02, 04, 06, etc.) go here
UAT = \\a1-fswus2-02\Clusters
PRD = \\a1-fswps2-02\Clusters

#>
$filesharewitness = "\\a1-fswps1-02\Clusters\$($ClusterCNO)"

#Backup Share

<#
This step is only needed if you're setting up an AAG, otherwise the DBA's will do this.

Here are the following paths
\\$(domain).ch\Backups\SQL Backups 2\DEV
\\$(domain).ch\Backups\SQL Backups 2\PRD
\\$(domain).ch\Backups\SQL Backups 2\STG
\\$(domain).ch\Backups\SQL Backups 2\TST
\\$(domain).ch\Backups\SQL Backups 2\UAT

#>
$BackupSharePath = "\\$(domain).ch\Backups\SQL Backups 2\PRD\$($node1)"

#DB backup names
$TestDB1FullPath = $BackupSharePath + "\" + $DB1Name + ".bak"
$TestDB2FullPath = $BackupSharePath + "\" + $DB2Name + ".bak"
$TestDB3FullPath = $BackupSharePath + "\" + $DB3Name + ".bak"
$TestDB4FullPath = $BackupSharePath + "\" + $DB4Name + ".bak"
$TestLog1FullPath = $BackupSharePath + "\" + $DB1Name + ".log"
$TestLog2FullPath = $BackupSharePath + "\" + $DB2Name + ".log"
$TestLog3FullPath = $BackupSharePath + "\" + $DB3Name + ".log"
$TestLog4FullPath = $BackupSharePath + "\" + $DB4Name + ".log"


#AAG information

#Dynamic parameters

#These passwords will be used to automate the setup of SQL.
$sqlagentuserpassword = Read-Host -Prompt "Enter your SQL Agent Account Password Here"
while ($sqlagentuserpassword -eq $null -or $sqlagentuserpassword -eq "")
{
  $sqlagentuserpassword = Read-Host -Prompt "Enter your SQL Agent Account Password Here"
}

$sqlserviceuserpassword = Read-Host -Prompt "Enter your SQL Service Account Password Here"
while ($sqlserviceuserpassword -eq $null -or $sqlserviceuserpassword -eq "")
{
  $sqlserviceuserpassword = Read-Host -Prompt "Enter your SQL Service Account Password Here"
}

#Temp Directory
$TempDirectory = Get-ChildItem -Path env: | Where-Object { $_.Name -eq "Temp" } | Select-Object -ExpandProperty value
$LocalGPOFunctionNameTempPath = $TempDirectory + "\" + $LocalGPOFunctionName

#ComputerName
$ComputerName = Get-ChildItem -Path env: | Where-Object { $_.Name -like "ComputerName" } | Select-Object -ExpandProperty value

#END Parameters
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Setting up the physical disks

#Get all offline disks, should be any disks you've created
$OfflineDisks = Get-Disk | Where-Object { $_.OperationalStatus -eq "Offline" }

#Set Disk online
$OfflineDisks | Set-Disk -IsOffline:$false

#Disable read only
$OfflineDisks | Set-Disk -IsReadOnly:$false

#Initialize Disks
$OfflineDisks | Initialize-Disk -PartitionStyle GPT

#loop through all disks and configure based on thier location.  This location is based on VMware controller card and controller port locations.  In VMware you should have the following SCSI configs
#0:0 = C: = OS = disk 1
#0:1 = K: = Misc = disk 2
#1:0 = F: = UserDB1 = disk 3
#1:1 = N: = Index1 = disk 4
#2:0 = J: = UserLog1 = disk 5
#3:0 = V: = TempLog = disk 6
#3:1 = W: = TempDB = disk 7

#Microsoft in their infinite wisdom, continues to change f'ing property values around, so below is the server 2016 specific scsi id

foreach ($disk in $OfflineDisks)
{
  #This will give us the view of which SCSI card and port we're in.
  #Note: property "SCSIPort" actually equals SCSI card in WMI, and "SCSITargetId" equals the SCSI port for the card


  $WMIDiskInformation = Get-WmiObject -Class win32_diskdrive | Where-Object { $_.DeviceID -like "*$($disk.number)" }


  if ($WMIDiskInformation.SCSIPort -eq 2 -and $WMIDiskInformation.SCSITargetId -eq 1)
  {
    Write-Output "K:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 4096 -NewFileSystemLabel "Misc" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter k
  }

  elseif ($WMIDiskInformation.SCSIPort -eq 3 -and $WMIDiskInformation.SCSITargetId -eq 0)
  {
    Write-Output "V:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 4096 -NewFileSystemLabel "TempLog" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter V
  }
  elseif ($WMIDiskInformation.SCSIPort -eq 3 -and $WMIDiskInformation.SCSITargetId -eq 1)
  {
    Write-Output "w:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 8192 -NewFileSystemLabel "TempDB" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter w
  }
  elseif ($WMIDiskInformation.SCSIPort -eq 4 -and $WMIDiskInformation.SCSITargetId -eq 0)
  {
    Write-Output "F:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 8192 -NewFileSystemLabel "UserDB1" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter f
  }
  elseif ($WMIDiskInformation.SCSIPort -eq 4 -and $WMIDiskInformation.SCSITargetId -eq 1)
  {
    Write-Output "N:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 8192 -NewFileSystemLabel "Index1" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter n
  }
  elseif ($WMIDiskInformation.SCSIPort -eq 5 -and $WMIDiskInformation.SCSITargetId -eq 0)
  {
    Write-Output "J:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 4096 -NewFileSystemLabel "UserLog1" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter j
  }
  elseif ($WMIDiskInformation.SCSIPort -eq 4 -and $WMIDiskInformation.SCSITargetId -eq 2)
  {
    Write-Output "G:"
    $disk | New-Partition -UseMaximumSize
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Format-Volume -FileSystem NTFS -AllocationUnitSize 8192 -NewFileSystemLabel "UserDB2" -confirm:$false
    $disk | Get-Partition | Where-Object { $_.type -eq "Basic" } | Set-Partition -NewDriveLetter G
  }
}

#END Setting up the physical disks
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Setting up the folder paths and permissions

# Note 1: If you have more than the standard F, J, K, N, V and W drives, you'll need to mananually setup the folder structure and permsissions
# Note 2: As part of the SQL install, SQL will configure the modify permissions for the default DB, Log, TempLog and TempDB folders, which is why I don't configure them.
# NOte 3: Keep an eye on the folder permissions, you shouldn't see a lot of errors, if you do, something went wrong.
# Note 4: These are based on default disk locations and default disk requests.  if you get a request for a G: drive for example, we don't have that scripted at the moment.

#Create Folder Stucture

#F: Drive
if ((Test-Path "F:\MSSQLDB\Data") -eq $false)
{
  New-Item -Path "F:\MSSQLDB\Data" -ItemType Container
}
if ((Test-Path "F:\OLAP\Data") -eq $false)
{
  New-Item -Path "F:\OLAP\Data" -ItemType Container
}

#J: Drive
if ((Test-Path "J:\MSSQLDB\Log") -eq $false)
{
  New-Item -Path "J:\MSSQLDB\Log" -ItemType Container
}
if ((Test-Path "J:\OLAP\Log") -eq $false)
{
  New-Item -Path "J:\OLAP\Log" -ItemType Container
}

#K: Drive
if ((Test-Path "K:\Config") -eq $false)
{
  New-Item -Path "K:\Config" -ItemType Container
}
if ((Test-Path "K:\MSSQL") -eq $false)
{
  New-Item -Path "K:\MSSQL" -ItemType Container
}
if ((Test-Path "K:\MSSQLDB") -eq $false)
{
  New-Item -Path "K:\MSSQLDB" -ItemType Container
}
if ((Test-Path "K:\OLAP\config") -eq $false)
{
  New-Item -Path "K:\OLAP\config" -ItemType Container
}
if ((Test-Path "K:\Support") -eq $false)
{
  New-Item -Path "K:\Support" -ItemType Container
}

#N: Drive
if ((Test-Path "N:\MSSQLDB\Index") -eq $false)
{
  New-Item -Path "N:\MSSQLDB\Index" -ItemType Container
}

#V: Drive
if ((Test-Path "V:\MSSQLDB\Log") -eq $false)
{
  New-Item -Path "V:\MSSQLDB\Log" -ItemType Container
}

#W: Drive
if ((Test-Path "W:\MSSQLDB\Data") -eq $false)
{
  New-Item -Path "W:\MSSQLDB\Data" -ItemType Container
}
if ((Test-Path "W:\OLAP\Temp") -eq $false)
{
  New-Item -Path "W:\OLAP\Temp" -ItemType Container
}

#Adding a catch for the G: drive
$GDRive = Get-PSDrive | Where-Object { $_.Root -like "G:*" }

if ($GDRive -ne $null)
{
  if ((Test-Path "G:\MSSQLDB\Data") -eq $false)
  {
    New-Item -Path "G:\MSSQLDB\Data" -ItemType Container
  }
  if ((Test-Path "G:\OLAP\Data") -eq $false)
  {
    New-Item -Path "G:\OLAP\Data" -ItemType Container
  }

}

#Set Permissions

#F: Drive
Start-Process -FilePath "icacls.exe" -ArgumentList "f:\ /remove Everyone /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "f:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "f:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "f: /grant:rx ""$sqlserviceuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "f: /grant:rx ""$sqlagentuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait

#J: Drive
Start-Process -FilePath "icacls.exe" -ArgumentList "j:\ /remove Everyone /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "j:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "j:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "j: /grant:rx ""$sqlserviceuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "j: /grant:rx ""$sqlagentuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait

#K: Drive
Start-Process -FilePath "icacls.exe" -ArgumentList "k:\ /remove Everyone /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "k:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "k:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "k: /grant:rx ""$sqlserviceuser"":(OI)(CI)(M) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "k: /grant:rx ""$sqlagentuser"":(OI)(CI)(M) /C" -NoNewWindow -Wait

#N: Drive
Start-Process -FilePath "icacls.exe" -ArgumentList "n:\ /remove Everyone /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "n:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "n:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "n: /grant:rx ""$sqlserviceuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "n: /grant:rx ""$sqlagentuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "N:\MSSQLDB\Index /grant:rx ""$sqlserviceuser"":(OI)(CI)(F) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "N:\MSSQLDB\Index /grant:rx ""$sqlagentuser"":(OI)(CI)(F) /C" -NoNewWindow -Wait

#V: Drive
Start-Process -FilePath "icacls.exe" -ArgumentList "v:\ /remove Everyone /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "v:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "v:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "v: /grant:rx ""$sqlserviceuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "v: /grant:rx ""$sqlagentuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait

#W: Drive
Start-Process -FilePath "icacls.exe" -ArgumentList "w:\ /remove Everyone /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "w:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "w:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "w: /grant:rx ""$sqlserviceuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
Start-Process -FilePath "icacls.exe" -ArgumentList "w: /grant:rx ""$sqlagentuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait

#Adding a catch for the G: drive
if ($GDRive -ne $null)
{
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\ /remove Everyone /T" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\ /remove ""Creator Owner"" /T" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\ /remove BUILTIN\Users /T" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g: /grant:rx ""$sqlserviceuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g: /grant:rx ""$sqlagentuser"":(OI)(CI)(RX) /C" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\MSSQLDB\Data /grant:rx ""$sqlserviceuser"":(OI)(CI)(F) /C" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\MSSQLDB\Data /grant:rx ""$sqlagentuser"":(OI)(CI)(F) /C" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\OLAP\DATA /grant:rx ""$sqlserviceuser"":(OI)(CI)(F) /C" -NoNewWindow -Wait
  Start-Process -FilePath "icacls.exe" -ArgumentList "g:\OLAP\DATA /grant:rx ""$sqlagentuser"":(OI)(CI)(F) /C" -NoNewWindow -Wait
}

#END Setting up the folder paths and permissions
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Add SQL service account and agent to perform volume maitanance tasks local GPO

#NOTE: You can find this setting buried in Computer\Windows\Security\Local Policies\User Rights Assignment

#Copy our function to the temp directory
Copy-Item -Path $LocalGPOFunctionFilePath -Destination $TempDirectory -Force -confirm:$false

#Function Name to load

#Import function
.$LocalGPOFunctionNameTempPath

#Add the service account
Add-ECSLocalGPOUserRightAssignment -UserOrGroup $sqlserviceuser -UserRightAssignment "SeManageVolumePrivilege"

#Add the agent account
Add-ECSLocalGPOUserRightAssignment -UserOrGroup $sqlagentuser -UserRightAssignment "SeManageVolumePrivilege"

#END Add SQL service account and agent to perform volume maitanance tasks local GPO
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Install SQL

#Copy the ISO to
Copy-Item -Path $ISOFileSource -Destination $ISOFileDestination -Force -confirm:$false

#Copy the SQL config file
Copy-Item -Path $ConfigFileSource -Destination $ConfigFileDestination -Force -Container:$false

#Copy the SSMS to the K:
Copy-Item -Path $SSMSFileSource -Destination $SSMSFileDestination -Force -Container:$false

#Modfiy the config file to update it for our SQL accounts
$ConfigFileContent = (Get-Content -Path $ConfigFileDestination).Replace("$(domain)\SQLSERVICEACCOUNTTOCHANGE",$sqlserviceuser) | Set-Content -Path $ConfigFileDestination
$ConfigFileContent = (Get-Content -Path $ConfigFileDestination).Replace("$(domain)\SQLAGENTACCOUNTTOCHANGE",$sqlagentuser) | Set-Content -Path $ConfigFileDestination

#Mount the ISO
$mountResult = Mount-DiskImage $ISOFileDestination -Passthru
$ISOVolume = $mountResult | Get-Volume

#Define the SQL install path
$SQLInstallPath = $($isovolume.driveletter) + ":\setup.exe"

#Install SQL
Start-Process -FilePath $SQLInstallPath -ArgumentList "/SQLSVCPASSWORD=""$sqlserviceuserpassword"" /AGTSVCPASSWORD=""$sqlagentuserpassword"" /ISSVCPASSWORD=""$sqlserviceuserpassword"" /ASSVCPASSWORD=""$sqlserviceuserpassword"" /ConfigurationFile=$($ConfigFileDestination) /IAcceptSQLServerLicenseTerms" -NoNewWindow -Wait

#Install SSSMS
Start-Process -FilePath $SSMSFileDestination -ArgumentList "/passive /norestart" -NoNewWindow -Wait

#END Install SQL
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Register SPNs

Start-Process -FilePath setspn -ArgumentList "-A MSSQLSvc/$($ComputerName).$(domain).ch:1433  $($sqlserviceuserNoDomain)  " -NoNewWindow -Wait -Passthru
Start-Process -FilePath setspn -ArgumentList "-A MSSQLSvc/$($ComputerName).$(domain).ch $($sqlserviceuserNoDomain)  " -NoNewWindow -Wait -Passthru

#END Register SPNs
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Auto Load SQL PS Module

#The included SQL module isn't kept up to date, so we're going to install the latest module from MS git
Install-Module sqlserver -AllowClobber

#Import the module
Import-Module sqlserver -DisableNameChecking

#End Auto Load SQL PS Module
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Configure SQL, all SQL servers

#SQL Object
$SQLObject = New-Object Microsoft.SqlServer.Management.Smo.Server

#Getting the server information
$server = New-Object Microsoft.SqlServer.Management.Smo.Server $env:ComputerName

#Configure SQL Memory
$MaxMemory = $($server.PhysicalMemory) - 4096
$MinMemory = $($server.PhysicalMemory) / 2

Invoke-Sqlcmd -Database Master -Query "EXEC  sp_configure'Show Advanced Options',1;RECONFIGURE;"
Invoke-Sqlcmd -Database Master -Query "EXEC  sp_configure'max server memory (MB)',$MaxMemory;RECONFIGURE;"
Invoke-Sqlcmd -Database Master -Query "EXEC  sp_configure'min server memory (MB)',$MinMemory;RECONFIGURE;"

#End Configure SQL, all SQL servers
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Install Cluster feature

Install-WindowsFeature -Name Failover-Clustering ?IncludeManagementTools

#END Install Cluster feature
#----------------------------------------------------------------------------------------------------


#!!!!!!!!!!!!!!!!!!!!THIS NEXT STEP ONLY NEEDS TO BE RUN ON ONE NODE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


#----------------------------------------------------------------------------------------------------
#Setup and configure cluster (only one node)

#Configure cluster (only run once on eaither node)
New-Cluster ?Name $ClusterCNO -Node $node1,$node2 ?StaticAddress $clusterip -nostorage

#Configure file share witness folder
if ((Test-Path $filesharewitness) -eq $false)
{
  New-Item -Path $filesharewitness -ItemType Container
}

#Set file share permissions
Start-Process -FilePath "icacls.exe" -ArgumentList """$filesharewitness"" /grant ""$(domain)\$ClusterCNO$"":(OI)(CI)(F) /C" -NoNewWindow -Wait

#Set quorum for the cluster
#Note 1:  This is for AAG's only, if you are setting up a traditional cluster, you'll need to setup a disk based quorum
Set-ClusterQuorum ?NodeAndFileShareMajority $filesharewitness

#Set Cluster Timeout to 10 seconds
(Get-Cluster).SameSubnetThreshold = 10

#Stop the cluster service so you can give it the correct AD rights
Get-Cluster -Name $ClusterCNO | Stop-Cluster -Force -confirm:$false



#!!!!!!!!!!!!!Add the cluster CNO to the same AD group that you added the invidvidual nodes to

#After assigning the rights, start the cluster service
Get-Service -Name ClusSvc -ComputerName $node1 | Start-Service
Get-Service -Name ClusSvc -ComputerName $node2 | Start-Service

#END Setup and configure cluster (only one node)
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#Enable SQL AAG, AAG only

#Enable SQL Always on (run on both nodes)

#NOTE: This may fail once, wait a minute, then try again.
Enable-SqlAlwaysOn -ServerInstance $($env:ComputerName) -confirm:$false -NoServiceRestart:$false -Force:$true

#End Enable SQL AAG, AAG only
#----------------------------------------------------------------------------------------------------

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Run these next steps only from one node !!!!!!!!!!!!!!!!!!!!!!!!!!!!

#----------------------------------------------------------------------------------------------------
#Prepare SQL for new AAG (only one node)

#Create a DB per listener.  Typically two, but sometimes more / less

#DB1
$db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database ($SQLObject,$DB1Name)
$db.Create()

#DB2
$db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database ($SQLObject,$DB2Name)
$db.Create()

#DB3
$db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database ($SQLObject,$DB3Name)
$db.Create()

#DB4
$db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database ($SQLObject,$DB4Name)
$db.Create()

#Confirm, list databases in your current instance
$SQLObject.Databases | Select-Object Name,Status,Owner,CreateDate

#Configure the backup share
if ((Test-Path $BackupSharePath) -eq $false)
{
  New-Item -Path $BackupSharePath -ItemType Container
}



#Now we need to backup all of the newly created DB's
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB1Name -BackupFile $TestDB1FullPath
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB2Name -BackupFile $TestDB2FullPath
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB3Name -BackupFile $TestDB3FullPath
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB4Name -BackupFile $TestDB4FullPath

#END Prepare SQL for new AAG (only one node)
#----------------------------------------------------------------------------------------------------

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Run these next steps only from one node !!!!!!!!!!!!!!!!!!!!!!!!!!!!

#----------------------------------------------------------------------------------------------------
#Setup the AAG (only one node)

#Create the endpoints for each SQL AAG replica
New-SqlHADREndpoint -Path "SQLSERVER:\SQL\$($node1)\Default" -Name $($SQLAAGEndPointName) -Port 5022 -EncryptionAlgorithm Aes -Encryption Required
New-SqlHADREndpoint -Path "SQLSERVER:\SQL\$($node2)\Default" -Name $($SQLAAGEndPointName) -Port 5022 -EncryptionAlgorithm Aes -Encryption Required

#Stare the endpoints for each AAG replica
Set-SqlHADREndpoint -Path "SQLSERVER:\SQL\$($node1)\Default\Endpoints\$($SQLAAGEndPointName)" -State Started
Set-SqlHADREndpoint -Path "SQLSERVER:\SQL\$($node2)\Default\Endpoints\$($SQLAAGEndPointName)" -State Started

#Create a SQL login for the SQL service account so each server can connect to each other.
$createLogin = ?CREATE LOGIN [$($sqlserviceuser)] FROM WINDOWS; Where-Object
$grantConnectPermissions = ?GRANT CONNECT ON ENDPOINT::$($SQLAAGEndPointName) TO [$($sqlserviceuser)]; Where-Object
Invoke-Sqlcmd -ServerInstance $($node1) -Query $createLogin
Invoke-Sqlcmd -ServerInstance $($node1) -Query $grantConnectPermissions
Invoke-Sqlcmd -ServerInstance $($node2) -Query $createLogin
Invoke-Sqlcmd -ServerInstance $($node2) -Query $grantConnectPermissions

#Create replicas

##########This is for non-seeded AAG's (traditional backup / restore AAGs)

#Create the replicas
$primaryReplica = New-SqlAvailabilityReplica -Name $($node1) -EndpointUrl ?TCP://$($node1).$(domain).ch:5022? -AvailabilityMode ?SynchronousCommit? -FailoverMode 'Automatic' -AsTemplate -Version $SQLObject.version
$secondaryReplica = New-SqlAvailabilityReplica -Name $($node2) -EndpointUrl ?TCP://$($node2).$(domain).ch:5022? -AvailabilityMode ?SynchronousCommit? -FailoverMode 'Automatic' -AsTemplate -Version $SQLObject.version

#Buildthe AAG's
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG1Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -Database $DB1Name -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG2Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -Database $DB2Name -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG3Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -Database $DB3Name -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG4Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -Database $DB4Name -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc

#Now we need to backup all db's (both full and log)
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB1Name -BackupFile $TestDB1FullPath
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB2Name -BackupFile $TestDB2FullPath
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB3Name -BackupFile $TestDB3FullPath
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB4Name -BackupFile $TestDB4FullPath

Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB1Name -BackupFile $TestLog1FullPath -BackupAction Log
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB2Name -BackupFile $TestLog2FullPath -BackupAction Log
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB3Name -BackupFile $TestLog3FullPath -BackupAction Log
Backup-SqlDatabase -ServerInstance $($env:ComputerName) -Database $DB4Name -BackupFile $TestLog4FullPath -BackupAction Log

#Now we need to restore the DB's
Restore-SqlDatabase -Database $DB1Name -BackupFile $TestDB1FullPath -ServerInstance $($node2) -NoRecovery
Restore-SqlDatabase -Database $DB2Name -BackupFile $TestDB2FullPath -ServerInstance $($node2) -NoRecovery
Restore-SqlDatabase -Database $DB3Name -BackupFile $TestDB3FullPath -ServerInstance $($node2) -NoRecovery
Restore-SqlDatabase -Database $DB4Name -BackupFile $TestDB4FullPath -ServerInstance $($node2) -NoRecovery

Restore-SqlDatabase -Database $DB1Name -BackupFile $TestLog1FullPath -ServerInstance $($node2) -NoRecovery -RestoreAction 'Log'
Restore-SqlDatabase -Database $DB2Name -BackupFile $TestLog2FullPath -ServerInstance $($node2) -NoRecovery -RestoreAction 'Log'
Restore-SqlDatabase -Database $DB3Name -BackupFile $TestLog3FullPath -ServerInstance $($node2) -NoRecovery -RestoreAction 'Log'
Restore-SqlDatabase -Database $DB4Name -BackupFile $TestLog4FullPath -ServerInstance $($node2) -NoRecovery -RestoreAction 'Log'

#Now we need to join the secondary nodes copy of the DB to the AAG
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node2)\Default\AvailabilityGroups\$($AAG1Name)" -Database $DB1Name
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node2)\default\AvailabilityGroups\$($AAG2Name)" -Database $DB2Name
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node2)\default\AvailabilityGroups\$($AAG3Name)" -Database $DB3Name
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node2)\default\AvailabilityGroups\$($AAG4Name)" -Database $DB4Name

########## END This is for non-seeded AAG's (traditional backup / restore AAGs)

#This is for seeded DB's, which is what we're doing in SQL 2017+

#Create the replica's
$primaryReplica = New-SqlAvailabilityReplica -Name $($node1) -EndpointUrl ?TCP://$($node1).$(domain).ch:5022? -AvailabilityMode ?SynchronousCommit? -FailoverMode 'Automatic' -AsTemplate -Version $SQLObject.version -SeedingMode Automatic
$secondaryReplica = New-SqlAvailabilityReplica -Name $($node2) -EndpointUrl ?TCP://$($node2).$(domain).ch:5022? -AvailabilityMode ?SynchronousCommit? -FailoverMode 'Automatic' -AsTemplate -Version $SQLObject.version -SeedingMode Automatic

#Create the AAG
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG1Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG2Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG3Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc
New-SqlAvailabilityGroup -InputObject $($node1) -Name $AAG4Name -AvailabilityReplica ($primaryReplica,$secondaryReplica) -DtcSupportEnabled -DatabaseHealthTrigger -ClusterType Wsfc

#Join secondary node to the AAG's
Join-SqlAvailabilityGroup -Path ?SQLSERVER:\SQL\$($node2)\Default? -Name $AAG1Name
Join-SqlAvailabilityGroup -Path ?SQLSERVER:\SQL\$($node2)\Default? -Name $AAG2Name
Join-SqlAvailabilityGroup -Path ?SQLSERVER:\SQL\$($node2)\Default? -Name $AAG3Name
Join-SqlAvailabilityGroup -Path ?SQLSERVER:\SQL\$($node2)\Default? -Name $AAG4Name

#Grant the AAG the rights to create a DB (only needed for seeding mode)
$AAG1CreateCommand = "ALTER AVAILABILITY GROUP [$($AAG1Name)] GRANT CREATE ANY DATABASE"
$AAG2CreateCommand = "ALTER AVAILABILITY GROUP [$($AAG2Name)] GRANT CREATE ANY DATABASE"
$AAG3CreateCommand = "ALTER AVAILABILITY GROUP [$($AAG3Name)] GRANT CREATE ANY DATABASE"
$AAG4CreateCommand = "ALTER AVAILABILITY GROUP [$($AAG4Name)] GRANT CREATE ANY DATABASE"

Invoke-Sqlcmd -ServerInstance $($node1) -Query $AAG1CreateCommand
Invoke-Sqlcmd -ServerInstance $($node2) -Query $AAG1CreateCommand

Invoke-Sqlcmd -ServerInstance $($node1) -Query $AAG2CreateCommand
Invoke-Sqlcmd -ServerInstance $($node2) -Query $AAG2CreateCommand

Invoke-Sqlcmd -ServerInstance $($node1) -Query $AAG3CreateCommand
Invoke-Sqlcmd -ServerInstance $($node2) -Query $AAG3CreateCommand

Invoke-Sqlcmd -ServerInstance $($node1) -Query $AAG4CreateCommand
Invoke-Sqlcmd -ServerInstance $($node2) -Query $AAG4CreateCommand

#Now we need to join the primary nodes copy of the DB to the AAG
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node1)\Default\AvailabilityGroups\$($AAG1Name)" -Database $DB1Name
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node1)\default\AvailabilityGroups\$($AAG2Name)" -Database $DB2Name
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node1)\default\AvailabilityGroups\$($AAG3Name)" -Database $DB3Name
Add-SqlAvailabilityDatabase -Path "SQLSERVER:\SQL\$($node1)\default\AvailabilityGroups\$($AAG4Name)" -Database $DB4Name



#Now we need to setup the listners (for both seeded and non-seeded AAG's)
New-SqlAvailabilityGroupListener -Name $($AAG1Name) -staticIP $AAG1IP -Port 1433 -Path "SQLSERVER:\SQL\$($node1)\DEFAULT\AvailabilityGroups\$($AAG1Name)"
New-SqlAvailabilityGroupListener -Name $($AAG2Name) -staticIP $AAG2IP -Port 1433 -Path "SQLSERVER:\SQL\$($node1)\DEFAULT\AvailabilityGroups\$($AAG2Name)"
New-SqlAvailabilityGroupListener -Name $($AAG3Name) -staticIP $AAG3IP -Port 1433 -Path "SQLSERVER:\SQL\$($node1)\DEFAULT\AvailabilityGroups\$($AAG3Name)"
New-SqlAvailabilityGroupListener -Name $($AAG4Name) -staticIP $AAG4IP -Port 1433 -Path "SQLSERVER:\SQL\$($node1)\DEFAULT\AvailabilityGroups\$($AAG4Name)"

#End Setup the AAG (only one node)
#----------------------------------------------------------------------------------------------------


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Run these next steps only from one node !!!!!!!!!!!!!!!!!!!!!!!!!!!!
#----------------------------------------------------------------------------------------------------
#Fix cluster setting and test cluster post AAG (only one node)

#Note you should be ready to walk through the wizzard to setup the AAG.  At somepoint I'll script this when I have more time.

#Fix cluster multi-subnet SQL listner setting
$ClusterResource = Get-ClusterResource | Where-Object { $_.ResourceType -eq "network name" -and $_.ownergroup -ne "Cluster Group" }
$ClusterResource | Set-ClusterParameter -Create RegisterAllProvidersIP 0
$ClusterResource | ForEach-Object { Stop-ClusterResource -Name $_.Name }
Get-ClusterResource | Where-Object { $_.ResourceType -eq "SQL Server Availability Group" } | ForEach-Object { Start-ClusterResource -Name $_.Name }

#Finally test the cluster
Test-Cluster

#END Fix cluster setting and test cluster post AAG(only one node)
#----------------------------------------------------------------------------------------------------






