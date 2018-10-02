Install-ADDSDomainController `
    -InstallDns `
    -Credential (Get-Credential "EVLAB\fjacquet") `
    -DomainName "evlab.ch"