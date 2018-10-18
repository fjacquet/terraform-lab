Import-Module -name activedirectory
Import-Module -name admpwd.ps

$ad = get-addomain
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
    -Identity "CN=Frederic Jacquet,OU=Users,$($domain)" `
    -Server $dc
Add-ADGroupMember `
    -Identity $Group `
    -Members $User `
    -Server $dc 
$User = Get-ADUser `
    -Identity "CN=Administrator,OU=Users,$($domain)" `
    -Server $dc
Add-ADGroupMember -Identity $Group `
    -Members $User `
    -Server $dc 

Set-AdmPwdComputerSelfPermission `
    –OrgUnit s$serversou 
Set-AdmPwdReadPasswordPermission `
    –orgunit $serversou  `
    –AllowedPrincipals $group 
Set-AdmPwdResetPasswordPermission `
    -OrgUnit $serversou  `
    -AllowedPrincipals $group 

new-gpo -name TestGPO `
    | new-gplink -target "ou=marketing,$domain" `
    | set-gppermissions `
    -permissionlevel gpoedit `
    -targetname "Marketing Admins" `
    -targettype group 
