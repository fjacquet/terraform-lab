
Install-WindowsFeature RSAT-ADDS
# Install Prerequisites
Install-WindowsFeature Server-Media-Foundation, `
    NET-Framework-45-Features, `
    RPC-over-HTTP-proxy, `
    RSAT-Clustering, `
    RSAT-Clustering-CmdInterface, `
    RSAT-Clustering-Mgmt, `
    RSAT-Clustering-PowerShell, `
    WAS-Process-Model, `
    Web-Asp-Net45, `
    Web-Basic-Auth, `
    Web-Client-Auth, `
    Web-Digest-Auth, `
    Web-Dir-Browsing, `
    Web-Dyn-Compression, `
    Web-Http-Errors, `
    Web-Http-Logging, `
    Web-Http-Redirect, `
    Web-Http-Tracing, `
    Web-ISAPI-Ext, `
    Web-ISAPI-Filter, `
    Web-Lgcy-Mgmt-Console, `
    Web-Metabase, Web-Mgmt-Console, `
    Web-Mgmt-Service, `
    Web-Net-Ext45, `
    Web-Request-Monitor, `
    Web-Server, `
    Web-Stat-Compression, `
    Web-Static-Content, `
    Web-Windows-Auth, `
    Web-WMI, `
    Windows-Identity-Foundation, `
    RSAT-ADDS
# Prepare AD schema for Excahnge
setup.exe /PrepareSchema /IAcceptExchangeServerLicenseTerms
Setup.exe /IAcceptExchangeServerLicenseTerms /PrepareAllDomains
setup.exe /PrepareAD /OrganizationName:"evLab" /IAcceptExchangeServerLicenseTerms
# Install mailbox role
setup.exe /Mode:Install /Role:Mailbox /IAcceptExchangeServerLicenseTerms
