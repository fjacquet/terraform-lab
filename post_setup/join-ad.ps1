Install-ADDSDomainController `
    -InstallDns `
    -Credential (Get-Credential "EVLAB\Administrator") `
    -DomainName "evlab.ch"