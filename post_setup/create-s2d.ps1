$nodes = ("EC2AMAZ-2SEE361", "EC2AMAZ-6CTPLJM", "EC2AMAZ-A5B3OR2",
    "EC2AMAZ-BUI8JUF", "EC2AMAZ-F40N9E1", "EC2AMAZ-LSUBUHA", "EC2AMAZ-OV4RR2R")

Restart-Computer -ComputerName $nodes -Wait -For Wmi -Force
Install-WindowsFeature -Name RSAT-Clustering

$report = Test-Cluster -Node $nodes -Include 'Storage Spaces Direct', 'Inventory', 'Network', 'System Configuration'

$reportFilePath = $report.FullNameå
Start-Process $reportFilePath

$vips = ("10.0.0.236", "10.0.0.117", "10.0.0.242", "10.0.0.27", "10.0.0.177", "10.0.0.226", "10.0.0.199")
New-Cluster -Name S2D -Node $nodes -NoStorage

New-Item -ItemType Directory -Path c:\Shaare\Witness
[string]$DomainName = (Get-WmiObject win32_computersystem).domain
New-SmbShare -Name fsw -Path c:\Share\Witness -FullAccess ($DomainName + "\Domain Computers")
$env:COMPUTERNAME
Set-ClusterQuorum -Cluster S2D -FileShareWitness \\EC2AMAZ-2UNRVBQ\fsw

Enable-ClusterS2D -PoolFriendlyName S2DPool -Confirm:$false -SkipEligibilityChecks:$true -CimSession $nodes[0]
