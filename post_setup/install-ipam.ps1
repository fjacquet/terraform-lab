
Add-Computer -DomainName "EVLAB" -Restart
restart-computer
install-windowsfeature ipam -IncludeAllSubFeature -IncludeManagementTools
Invoke-IpamGpoProvisioning –Domain evlab.ch –GpoPrefixName IPAM –IpamServerFqdn ipam-0.evlab.ch -DelegatedGpoUser Administrator #DevSkim: ignore DS104456 
