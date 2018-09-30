# You’ll want a GPO for your SQL servers OU that creates a firewall rule to allow port 1433 and 5022.
# https://www.ericcsinger.com/powershell-scripting-installing-sql-setting-up-alwayson-availability-groups/

#######################################################################################################
 
#Parameters
 
 
 
#File Path to local GPO function.
 
$LocalGPOFunctionName = "Add-ECSLocalGPOUserRightAssignment.ps1"
 
$LocalGPOFunctionFilePath = "\\a1-file-04\SysAdminStuff\SQL Servers\Functions" + "\" + $LocalGPOFunctionName
 
 
 
#File Path to SQL config file
 
$ConfigFileName = "ConfigurationFile_Template_2017plus.ini"
 
$ConfigFileSource = "\\a1-file-04\SysAdminStuff\SQL Servers\" + $ConfigFileName
 
$ConfigFileDestination = "K:\" + $ConfigFileName
 
 
 
#File path to SSMS
 
$SSMSFileName = "SSMS-Setup-ENU.exe"
 
$SSMSFileSource = "\\YOURDOMAINHERE.local\Servers\ISG Software\Microsoft\SQL Server Management Studio\17.4\" + $SSMSFileName
 
$SSMSFileDestination = "K:\" + $SSMSFileName
 
 
 
#File Path to SQL ISO of your choice
 
$ISOFileName = "SW_DVD9_NTRL_SQL_Svr_Ent_Core_2017_64Bit_English_OEM_VL_X21-56995.ISO"
 
$ISOFileSource = "\\YOURDOMAINHERE.local\Servers\ISG Software\Microsoft\SQL Enterprise 2017\" + $ISOFileName
 
$ISOFileDestination = "K:\" + $ISOFileName
 
 
 
#Service Account
 
$sqlserviceuserNoDomain = "usrsqlpc15svc"
 
$sqlserviceuser = "YOURDOMAINHERE\" + $sqlserviceuserNoDomain
 
$sqlagentuserNoDomain = "usrsqlpc15agt"
 
$sqlagentuser = "YOURDOMAINHERE\" + $sqlagentuserNoDomain
 
 
 
 
 
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
 
 
 
<# Note 1: FSW is only needed if you're setting up an AAG. Traditional failover clusters, don't need this, instead they need a quorum disk. This script does not cover that. Note 2: There are currently four different file share wittness locations. See below Odd numbered clusters (for example a1-sqluc-01, 03, 05, etc.) go here UAT = \\a1-fswus1-02\Clusters PRD = \\a1-fswps1-02\Clusters Even numbered clusters (for example a1-sqluc-02, 04, 06, etc.) go here UAT = \\a1-fswus2-02\Clusters PRD = \\a1-fswps2-02\Clusters #>
 
$filesharewitness = "\\a1-fswps1-02\Clusters\$($ClusterCNO)"
 
 
 
#Backup Share
 
 
 
<# This step is only needed if you're setting up an AAG, otherwise the DBA's will do this. Here are the following paths \\YOURDOMAINHERE.local\Backups\SQL Backups 2\DEV \\YOURDOMAINHERE.local\Backups\SQL Backups 2\PRD \\YOURDOMAINHERE.local\Backups\SQL Backups 2\STG \\YOURDOMAINHERE.local\Backups\SQL Backups 2\TST \\YOURDOMAINHERE.local\Backups\SQL Backups 2\UAT #>
 
$BackupSharePath = "\\YOURDOMAINHERE.local\Backups\SQL Backups 2\PRD\$($node1)"
 
 
 
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
 
While ($sqlagentuserpassword -eq $null -or $sqlagentuserpassword -eq "")
{
 
    $sqlagentuserpassword = Read-Host -Prompt "Enter your SQL Agent Account Password Here"
 
}
 
 
 
$sqlserviceuserpassword = Read-Host -Prompt "Enter your SQL Service Account Password Here"
 
While ($sqlserviceuserpassword -eq $null -or $sqlserviceuserpassword -eq "")
{
 
    $sqlserviceuserpassword = Read-Host -Prompt "Enter your SQL Service Account Password Here"
 
}
 
 
 
#Temp Directory
 
$TempDirectory = Get-childitem -Path env: | where-object {$_.name -eq "Temp"} | select-object -ExpandProperty value
 
$LocalGPOFunctionNameTempPath = $TempDirectory + "\" + $LocalGPOFunctionName
 
 
 
#ComputerName
 
$ComputerName = Get-childitem -path env: | where-object {$_.name -like "ComputerName"} | select-object -expandproperty value
 
 
 
#END Parameters
 
#######################################################################################################
