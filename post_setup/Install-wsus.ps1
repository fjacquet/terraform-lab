
add-windowsfeature -Name UpdateServices,RSAT -IncludeManagementTools

$WSUSContentDir = 'D:\WSUS'
New-Item -Path $WSUSContentDir -ItemType Directory

& "$env:ProgramFiles\Update Services\Tools\WsusUtil.exe" postinstall CONTENT_DIR=$WSUSContentDir

$WSUSServer = Get-WsusServer
$WSUSServerURL = "http{2}://{0}:{1}" -f `
    $WSUSServer.Name, `
    $WSUSServer.PortNumber, `
('', 's')[$WSUSServer.UseSecureConnection]
$WSUSServerURL

$PolicyName = "WSUS Client"

New-GPO -Name $PolicyName
New-GPLink -Name $PolicyName -Target "DC=EVLAB,DC=CH"
$key = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU'
Set-GPRegistryValue -Name $PolicyName `
    -Key $key `
    -ValueName 'UseWUServer' `
    -Type DWORD -Value 1
$key = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU'
Set-GPRegistryValue -Name $PolicyName `
    -Key $key `
    -ValueName 'AUOptions' `
    -Type DWORD `
    -Value 2
$key = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate'
Set-GPRegistryValue -Name $PolicyName `
    -Key $key `
    -ValueName 'WUServer' `
    -Type String `
    -Value $WSUSServerURL
$key = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate'
Set-GPRegistryValue -Name $PolicyName `
    -Key $key `
    -ValueName 'WUStatusServer' `
    -Type String -Value $WSUSServerURL


$WSUSServer = Get-WsusServer
$WSUSServer.CreateComputerTargetGroup('Domain Controllers')
Get-WsusComputer -NameIncludes 'DC-0' | Add-WsusComputer -TargetGroupName 'Domain Controllers'
Get-WsusComputer -NameIncludes 'DC-1' | Add-WsusComputer -TargetGroupName 'Domain Controllers'

$DCGroup = $WSUSServer.GetComputerTargetGroups() | Where-Object -Property Name -eq 'Domain Controllers'
Get-WsusComputer | Where-Object -Property ComputerTargetGroupIDs -Contains $DCGroup.Id

$WSUSServer = Get-WsusServer
$ApprovalRule = $WSUSServer.CreateInstallApprovalRule('Critical Updates')
$type = 'Microsoft.UpdateServices.Administration.AutomaticUpdateApprovalDeadline'
$RuleDeadLine = New-Object -Typename $type
$RuleDeadLine.DayOffset = 3
$RuleDeadLine.MinutesAfterMidnight = 180
$ApprovalRule.Deadline = $RuleDeadLine

$UpdateClassification = $ApprovalRule.GetUpdateClassifications()
$UpdateClassification.Add(($WSUSServer.GetUpdateClassifications() | Where-Object -Property Title -eq 'Critical Updates'))
$UpdateClassification.Add(($WSUSServer.GetUpdateClassifications() | Where-Object -Property Title -eq 'Definition Updates'))
$ApprovalRule.SetUpdateClassifications($UpdateClassification)

$TargetGroups = New-Object Microsoft.UpdateServices.Administration.ComputerTargetGroupCollection
$TargetGroups.Add(($WSUSServer.GetComputerTargetGroups() | Where-Object -Property Name -eq "Domain Controllers"))
$ApprovalRule.SetComputerTargetGroups($TargetGroups)

$ApprovalRule.Enabled = $true
$ApprovalRule.Save()