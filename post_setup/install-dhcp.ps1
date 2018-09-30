# New-NetIPAddress -IPAddress 10.0.0.3 -InterfaceAlias "Ethernet" -DefaultGateway 10.0.0.1 -AddressFamily IPv4 -PrefixLength 24
# Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.0.0.2
# Rename-Computer -Name DHCP1
# Restart-Computer

Add-Computer -DomainName "EVLAB" -Restart

Install-WindowsFeature DHCP -IncludeManagementTools
netsh dhcp add securitygroups
Restart-service dhcpserver

Add-DhcpServerInDC -DnsName DHCP-0.evlab.ch -IPAddress 10.0.0.3
Add-DhcpServerInDC -DnsName DHCP-1.evlab.ch -IPAddress 10.0.0.3
Get-DhcpServerInDC
Set-ItemProperty –Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2

Set-DhcpServerv4DnsSetting -ComputerName "DHCP-0.evlab.ch" -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True
Set-DhcpServerv4DnsSetting -ComputerName "DHCP-1.evlab.ch" -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True
rem At prompt, supply credential in form DOMAIN\user, password
$Credential = Get-Credential
Set-DhcpServerDnsCredential -Credential $Credential -ComputerName "DHCP-1.evlab.ch"

rem Configure scope Corpnet
Add-DhcpServerv4Scope -name "Corpnet" -StartRange 10.0.0.1 -EndRange 10.0.0.254 -SubnetMask 255.255.255.0 -State Active
Add-DhcpServerv4ExclusionRange -ScopeID 10.0.0.0 -StartRange 10.0.0.1 -EndRange 10.0.0.15
Set-DhcpServerv4OptionValue -OptionID 3 -Value 10.0.0.1 -ScopeID 10.0.0.0 -ComputerName DHCP1.evlab.ch
Set-DhcpServerv4OptionValue -DnsDomain evlab.ch -DnsServer 10.0.0.2

rem Configure scope Corpnet2
Add-DhcpServerv4Scope -name "Corpnet2" -StartRange 10.0.1.1 -EndRange 10.0.1.254 -SubnetMask 255.255.255.0 -State Active
Add-DhcpServerv4ExclusionRange -ScopeID 10.0.1.0 -StartRange 10.0.1.1 -EndRange 10.0.1.15
Set-DhcpServerv4OptionValue -OptionID 3 -Value 10.0.1.1 -ScopeID 10.0.1.0 -ComputerName DHCP1.evlab.ch