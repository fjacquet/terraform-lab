Initialize-AWSDefaults

$username = "fjacquet"
$secret = (Get-SECSecretValue -SecretId "evlab/ad/$($username)").SecretString | ConvertFrom-Json
$password = $secret.fjacquet | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password
$Domain = (Get-ADDomain).DistinguishedName

New-ADUser `
   -ChangePasswordAtLogon $false `
   -City "Montreux" `
   -Company "evlab" `
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
   -AccountPassword $sec `
   -UserPrincipalName "$($username)@$($Domain)"

$secrets = ('evlab/ad/joinuser',
    'evlab/guacamole/mysqlroot',
    'evlab/guacamole/mysqluser',
    'evlab/glpi/mysqlroot',
    'evlab/glpi/mysqluser',
    'evlab/guacamole/keystore',
    'evlab/guacamole/mail',
    'evlab/sharepoint/sp_farm',
    'evlab/sharepoint/sp_services',
    'evlab/sharepoint/sp_portalAppPool',
    'evlab/sharepoint/sp_profilesAppPool',
    'evlab/sharepoint/sp_searchService',
    'evlab/sharepoint/sp_cacheSuperUser',
    'evlab/sharepoint/sp_cacheSuperReader',
    'evlab/sql/svc-sql',
    'evlab/pki/svc-ndes')
foreach ($secret in $secrets) {
  
    $username = $secret.Split("/")[2]
    $secretstring = (Get-SECSecretValue -SecretId "evlab/pki/$($username)").SecretString | ConvertFrom-Json
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

# $username = "svc-sql-sccm"
# $secret = (Get-SECSecretValue -SecretId "evlab/sccm/$($username)").SecretString | ConvertFrom-Json

# $params = @{
#   Name = $username
#   AccountPassword = (ConvertTo-SecureString -AsPlainText $secret -Force)
#   CannotChangePassword = $true
#   PasswordNeverExpires = $false
#   Enabled = $true
# }
# New-ADUser @params

# $username = "joinuser"
# $secret = (Get-SECSecretValue -SecretId "evlab/ad/$($username)").SecretString | ConvertFrom-Json

# $params = @{
#   Name = $username
#   AccountPassword = (ConvertTo-SecureString -AsPlainText $secret -Force)
#   CannotChangePassword = $true
#   PasswordNeverExpires = $false
#   Enabled = $true
#   ChangePasswordAtLogon = $false
#   DisplayName = "Join User"
#   EmailAddress = "$($username)@$($Domain)" `

# }

# New-ADUser @params
