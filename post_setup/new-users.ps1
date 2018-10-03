$sec = "xx." | ConvertTo-SecureString -AsPlainText -Force

New-ADUser `
    -ChangePasswordAtLogon $false `
    -City "Montreux" `
    -Company "evlab" `
    -Country "CH" `
    -DisplayName "Frederic Jacquet" `
    -EmailAddress "fjacquet@evlab.ch" `
    -EmployeeNumber "42" `
    -Enabled $true `
    -GivenName "Frederic" `
    -Name "Frederic Jacquet" `
    -PostalCode "1820" `
    -SamAccountName fjacquet `
    -State "VD" `
    -Surname "Jacquet" `
    -Title "Mr" `
    -AccountPassword $sec `
    -UserPrincipalName "fjacquet@evlab.ch"
