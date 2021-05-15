# new-Partition -PartitionNumber 2  -DriveLetter D  | Format-Volume  -FileSystem NTFS   -Force:$true   -Compress   -UseLargeFRS  -Confirm:$false
Set-SmbServerConfiguration `
    -EnableSMB1Protocol $false `
    -Confirm:$false

Set-SmbServerConfiguration `
    -RequireSecuritySignature $true `
    -EnableSecuritySignature $true `
    -EncryptData $true `
    -Confirm:$false

Set-SmbServerConfiguration -AutoShareServer $false `
    -AutoShareWorkstation $false `
    -Confirm:$false

Set-SmbServerConfiguration -ServerHidden $true `
    -AnnounceServer $false `
    -Confirm:$false

Restart-Service -Name lanmanserver -Force:$true

import-module -name DFSN
Add-WindowsFeature -name RSAT-AD-PowerShell
Import-Module -Name ActiveDirectory

$ad = get-addomain
$Domain = $ad.DNSRoot

mkdir D:\samples
New-SmbShare `
    -Description "Sample file share" `
    -FolderEnumerationMode AccessBased `
    -CachingMode None `
    -Path D:\samples `
    -Name samples `
    -EncryptData $true `
    -Confirm:$false

Revoke-SmbShareAccess -Name samples `
    -AccountName 'Everyone' `
    -Confirm:$false | Out-Null
Grant-SmbShareAccess -Name samples -AccessRight Read `
    -AccountName 'evlab\fjacquet' `
    -Confirm:$false | Out-Null
Grant-SmbShareAccess -Name samples -AccessRight Full `
    -AccountName 'NT Authority\SYSTEM' `
    -Confirm:$False | Out-Null
Grant-SmbShareAccess -Name samples -AccessRight Full `
    -AccountName 'CREATOR OWNER' `
    -Confirm:$false | Out-Null

New-DfsnRoot -Path \\$($domain)\samples `
    -TargetPath \\$($env:computername).$($Domain)\samples `
    -Type DomainV2 `
    -Description 'Samples Data DFS Root'

New-DfsReplicationGroup `
    -GroupName FSsamplesRG `
    -DomainName $($domain) `
    -Description 'Replication Group for FS-0,FS-1 shares' | Out-Null

Add-DfsrMember -GroupName FSsamplesRG `
    -Description 'File Server members' `
    -ComputerName $($env:computername).$($Domain), `
    -DomainName $($Domain) | Out-Null
New-DfsReplicatedFolder -GroupName FSsamplesRG `
    -FolderName Samples `
    -Domain $($Domain)`
    -Description 'Samples' `
    -DfsnPath \\$($Domain)\Samples | Out-Null