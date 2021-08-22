Import-Module ActiveDirectory
# Get the distinguished name of the Active Directory domain
$Domain = (Get-ADDomain).DistinguishedName
Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target $Domain -Confirm:$false
