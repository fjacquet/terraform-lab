Import-Module -Name ActiveDirectory
Import-Module -Name admpwd.ps

$ad = Get-ADDomain
$domain = $ad.DistinguishedName
$dns = $ad.DNSRoot

Update-AdmPwdADSchema

New-ADOrganizationalUnit -Name "eu-west-1" -Path $($domain)
New-ADOrganizationalUnit -Name "servers" -Path "OU=eu-west-1,$($domain)"

$dc = "dc-0.$($dns)"
$group = New-ADGroup `
   -Name "LAPS Admins" `
   -SamAccountName lapsadmins `
   -GroupCategory Security `
   -GroupScope Global `
   -DisplayName "LAPS Administrators" `
   -Path "CN=Users," `
   -Description "Members of this group are LAPS Administrators"

$serversou = "servers"

$User = Get-ADUser `
   -Identity "fjacquet" `
   -Server $dc

Add-ADGroupMember `
   -Identity $Group `
   -Members $User `
   -Server $dc

$User = Get-ADUser `
   -Identity "Administrator" `
   -Server $dc

Add-ADGroupMember -Identity $Group `
   -Members $User `
   -Server $dc


Set-AdmPwdReadPasswordPermission `
   -AllowedPrincipals $group.SamAccountName `
   -Identity $serversou.Name

Set-AdmPwdResetPasswordPermission `
   -AllowedPrincipals $group.SamAccountName `
   -Identity $serversou.Name

Set-AdmPwdComputerSelfPermission `
   -Identity $serversou.Name
