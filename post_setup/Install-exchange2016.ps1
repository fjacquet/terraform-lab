# Prepare AD schema for Excahnge
setup.exe /PrepareSchema /IAcceptExchangeServerLicenseTerms
setup.exe /PrepareAD /OrganizationName:"evLab" /IAcceptExchangeServerLicenseTerms
# Install mailbox role 
setup.exe /Mode:Install /Role:Mailbox /IAcceptExchangeServerLicenseTerms
