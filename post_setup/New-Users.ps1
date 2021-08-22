Initialize-AWSDefaults

Import-Module -name ActiveDirectory
$ad = get-addomain
$DomainDN = $ad.DistinguishedName
$Domain = $ad.DNSRoot
$username = "fjacquet"
$secret = (Get-SECSecretValue -SecretId "$($domain)/ad/$($username)").SecretString
$password = $secret | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

New-ADUser `
    -ChangePasswordAtLogon $false `
    -City "Montreux" `
    -Company "ezlab" `
    -Country "CH" `
    -DisplayName "Frederic Jacquet" `
    -EmailAddress "$($username)@$($Domain)" `
    -EmployeeNumber "42" `
    -Enabled $true `
    -GivenName "Frederic" `
    -Name "Frederic Jacquet" `
    -PostalCode "1820" `
    -SAMAccountName $($username) `
    -State "VD" `
    -Surname "Jacquet" `
    -Title "Mr" `
    -AccountPassword $password `
    -UserPrincipalName "$($username)@$($Domain)"

$secrets = (
    "$($Domain)/ad/joinuser",
    "$($Domain)/ad/adbackups",
    "$($Domain)/ad/simpana-install",
    "$($Domain)/ad/simpana-ad",
    "$($Domain)/ad/simpana-sql",
    "$($Domain)/ad/simpana-push",
    "$($Domain)/ad/dns-admin",
    "$($Domain)/guacamole/mysqlroot",
    "$($Domain)/guacamole/mysqluser",
    "$($Domain)/glpi/mysqlroot",
    "$($Domain)/glpi/mysqluser",
    "$($Domain)/guacamole/keystore",
    "$($Domain)/guacamole/mail",
    "$($Domain)/sharepoint/sp_farm",
    "$($Domain)/sharepoint/sp_services",
    "$($Domain)/sharepoint/sp_portalAppPool",
    "$($Domain)/sharepoint/sp_profilesAppPool",
    "$($Domain)/sharepoint/sp_searchService",
    "$($Domain)/sharepoint/sp_cacheSuperUser",
    "$($Domain)/sharepoint/sp_cacheSuperReader",
    "$($Domain)/sql/svc-sql",
    "$($Domain)/sql/svc-sql-sccm",
    "$($Domain)/pki/svc-ndes"
)
foreach ($secret in $secrets) {

    $username = $secret.Split("/")[2]
    write-host $username
    $secretstring = (Get-SECSecretValue -SecretId "$($secret)").SecretString
    write-host $secretstring
    $params = @{
        Name                  = $username
        AccountPassword       = (ConvertTo-SecureString -AsPlainText $secretstring -Force)
        CannotChangePassword  = $true
        PasswordNeverExpires  = $false
        Enabled               = $true
        ChangePasswordAtLogon = $false
        DisplayName           = $username
        EmailAddress          = "$($username)@$($Domain)" `
    }
    New-ADUser @params
}

Add-ADPrincipalGroupMembership `
    -Identity `
    "CN=DNS-ADMIN,CN=Users,$($DomainDN)" `
    -MemberOf `
    "CN=Enterprise Admins,CN=Users,$($DomainDN)", `
    "CN=Domain Admins,CN=Users,$($DomainDN)"

Add-ADPrincipalGroupMembership `
    -Identity `
    "CN=fjacquet,CN=Users,$($DomainDN)" `
    -MemberOf `
    "CN=Enterprise Admins,CN=Users,$($DomainDN)", `
    "CN=Domain Admins,CN=Users,$($DomainDN)"

Add-DnsServerPrimaryZone `
    -Name '0.10.in-addr.arpa' `
    -ReplicationScope Forest `
    -DynamicUpdate Secure `
    -ResponsiblePerson "DNS-ADMIN.$($Domain)."

Set-DNSServerEDns -CacheTimeout '0:30:00' `
    -Computername "DC-0" `
    -EnableProbes $true `
    -EnableReception $true