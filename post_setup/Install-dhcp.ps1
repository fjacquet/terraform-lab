# New-NetIPAddress -IPAddress 10.0.0.3 -InterfaceAlias "Ethernet" -DefaultGateway 10.0.0.1 -AddressFamily IPv4 -PrefixLength 24
# Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.0.0.2
# Rename-Computer -Name DHCP1
# Restart-Computer
Initialize-AWSDefaults
$secret = (Get-SECSecretValue -SecretId "evlab/ad/fjacquet" -region eu-west-1).SecretString 
$username = "fjacquet@evlab.ch"
$password =  ConvertTo-SecureString -AsPlainText -Force $secret
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password

$dhcp0 = Resolve-DnsName -Name dhcp-0.evlab.ch -Type a
$dhcp1 = Resolve-DnsName -Name dhcp-1.evlab.ch -Type a

Add-DhcpServerInDC  -DnsName $dhcp0.name -IPAddress $dhcp0.ipaddress
Add-DhcpServerInDC -DnsName $dhcp1.name  -IPAddress $dhcp1.ipaddress
Get-DhcpServerInDC
$reg ='registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12'
Set-ItemProperty –Path $reg  –Name ConfigurationState –Value 2

Set-DhcpServerv4DnsSetting -ComputerName $dhcp0.name -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True
Set-DhcpServerv4DnsSetting -ComputerName $dhcp1.name  -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True
Set-DhcpServerDnsCredential -Credential $Credential -ComputerName $dhcp0.name
Set-DhcpServerDnsCredential -Credential $Credential -ComputerName $dhcp1.name

# Configure scope Corpnet
Add-DhcpServerv4Scope -Name "Corpnet" -StartRange 10.0.0.1 -EndRange 10.0.0.254 -SubnetMask 255.255.255.0 -State Active
Add-DhcpServerv4ExclusionRange -ScopeID 10.0.0.0 -StartRange 10.0.0.1 -EndRange 10.0.0.15
Set-DhcpServerv4OptionValue -OptionID 3 -Value 10.0.0.1 -ScopeID 10.0.0.0 -ComputerName $dhcp1.name
Set-DhcpServerv4OptionValue -DnsDomain evlab.ch -DnsServer 10.0.0.2

# Configure scope Corpnet2
Add-DhcpServerv4Scope -Name "Corpnet2" -StartRange 10.0.1.1 -EndRange 10.0.1.254 -SubnetMask 255.255.255.0 -State Active
Add-DhcpServerv4ExclusionRange -ScopeID 10.0.1.0 -StartRange 10.0.1.1 -EndRange 10.0.1.15
Set-DhcpServerv4OptionValue -OptionID 3 -Value 10.0.1.1 -ScopeID 10.0.1.0 -ComputerName $dhcp1.name
