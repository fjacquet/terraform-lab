Get-NetAdapter -Name ethernet |Set-DnsClientServerAddress -ServerAddresses ("10.0.52.80","10.0.51.99") 
Set-DnsClientGlobalSetting -SuffixSearchList ("evlab.ch","eu-west-1.ec2-utilities.amazonaws.com","us-east-1.ec2-utilities.amazonaws.com", "eu-west-1.compute.internal")
add-computer –domainname "evlab.ch" -Credential "evlab\fjacquet" -restart –force 