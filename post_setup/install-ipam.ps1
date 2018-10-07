
$Domain = (Get-ADDomain).DistinguishedName
install-windowsfeature ipam -IncludeAllSubFeature -IncludeManagementTools
Invoke-IpamGpoProvisioning –Domain $Domain  ` #DevSkim: ignore DS104456 
    –GpoPrefixName IPAM `
    –IpamServerFqdn ipam-0.$domain `
    -DelegatedGpoUser Administrator 
