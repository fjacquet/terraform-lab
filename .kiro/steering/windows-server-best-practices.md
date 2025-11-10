# Windows Server Best Practices

## Overview

Windows Server is Microsoft's enterprise server operating system providing services for networking, identity management, web hosting, virtualization, and application hosting. This guide covers best practices for deploying and managing Windows Server infrastructure.

**Core Services:**

- **Active Directory Domain Services (AD DS)**: Identity and access management
- **DNS**: Domain Name System services
- **DHCP**: Dynamic Host Configuration Protocol
- **IIS**: Internet Information Services web server
- **Group Policy**: Centralized configuration management
- **PowerShell**: Automation and scripting
- **Hyper-V**: Virtualization platform

## Active Directory Domain Services

**Domain Controller Deployment**

```powershell
# Install AD DS role
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Create new forest (first DC)
Install-ADDSForest `
    -DomainName "corp.contoso.com" `
    -DomainNetbiosName "CORP" `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -InstallDns `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) `
    -Force

# Add additional domain controller
Install-ADDSDomainController `
    -DomainName "corp.contoso.com" `
    -Credential (Get-Credential CORP\Administrator) `
    -InstallDns `
    -SiteName "Default-First-Site-Name" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) `
    -Force
```

**AD DS Best Practices:**

- Deploy at least two domain controllers per domain for redundancy
- Use separate physical/virtual machines for domain controllers
- Place domain controllers in different sites for geographic redundancy
- Use Windows Server Core for domain controllers when possible
- Implement proper backup and recovery procedures
- Use Read-Only Domain Controllers (RODCs) for branch offices
- Regularly monitor AD replication health
- Implement proper DNS configuration
- Use Sites and Services for replication topology
- Enable AD Recycle Bin for object recovery

**User and Group Management**

```powershell
# Create organizational unit
New-ADOrganizationalUnit -Name "Engineering" -Path "DC=corp,DC=contoso,DC=com"

# Create user account
New-ADUser `
    -Name "John Doe" `
    -GivenName "John" `
    -Surname "Doe" `
    -SamAccountName "jdoe" `
    -UserPrincipalName "jdoe@corp.contoso.com" `
    -Path "OU=Engineering,DC=corp,DC=contoso,DC=com" `
    -AccountPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true

# Create security group
New-ADGroup `
    -Name "Engineering-Users" `
    -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=Engineering,DC=corp,DC=contoso,DC=com" `
    -Description "Engineering department users"

# Add user to group
Add-ADGroupMember -Identity "Engineering-Users" -Members "jdoe"

# Add user to multiple groups
Add-ADPrincipalGroupMembership `
    -Identity "CN=John Doe,OU=Engineering,DC=corp,DC=contoso,DC=com" `
    -MemberOf "CN=Domain Admins,CN=Users,DC=corp,DC=contoso,DC=com"
```

**Fine-Grained Password Policies**

```powershell
# Create fine-grained password policy
New-ADFineGrainedPasswordPolicy `
    -Name "AdminPasswordPolicy" `
    -Precedence 10 `
    -ComplexityEnabled $true `
    -LockoutDuration "00:30:00" `
    -LockoutObservationWindow "00:30:00" `
    -LockoutThreshold 3 `
    -MaxPasswordAge "60.00:00:00" `
    -MinPasswordAge "1.00:00:00" `
    -MinPasswordLength 14 `
    -PasswordHistoryCount 24 `
    -ReversibleEncryptionEnabled $false

# Apply policy to group
Add-ADFineGrainedPasswordPolicySubject `
    -Identity "AdminPasswordPolicy" `
    -Subjects "Domain Admins"

# View resultant password policy for user
Get-ADUserResultantPasswordPolicy -Identity "jdoe"
```

### DNS Configuration

**DNS Server Setup**

```powershell
# Install DNS role
Install-WindowsFeature DNS -IncludeManagementTools

# Create AD-integrated primary zone
Add-DnsServerPrimaryZone `
    -Name "contoso.com" `
    -ReplicationScope "Domain" `
    -PassThru

# Create reverse lookup zone
Add-DnsServerPrimaryZone `
    -NetworkID "10.0.0.0/24" `
    -ReplicationScope "Domain"

# Add DNS A record
Add-DnsServerResourceRecordA `
    -Name "web01" `
    -ZoneName "contoso.com" `
    -IPv4Address "10.0.0.10"

# Add DNS CNAME record
Add-DnsServerResourceRecordCName `
    -Name "www" `
    -HostNameAlias "web01.contoso.com" `
    -ZoneName "contoso.com"

# Configure DNS forwarders
Add-DnsServerForwarder -IPAddress "8.8.8.8","8.8.4.4"

# Configure conditional forwarder
Add-DnsServerConditionalForwarderZone `
    -Name "partner.com" `
    -MasterServers "192.168.1.10"
```

**DNS Best Practices:**

- Use AD-integrated zones for automatic replication
- Configure secure dynamic updates
- Implement DNS scavenging for stale records
- Use forwarders for external name resolution
- Configure reverse lookup zones
- Monitor DNS query performance
- Implement DNS policies for split-brain scenarios
- Use DNSSEC for enhanced security
- Regular backup of DNS zones
- Document DNS architecture

### DHCP Configuration

**DHCP Server Setup**

```powershell
# Install DHCP role
Install-WindowsFeature DHCP -IncludeManagementTools

# Create DHCP security groups
netsh dhcp add securitygroups

# Restart DHCP service
Restart-Service dhcpserver

# Authorize DHCP server in AD
Add-DhcpServerInDC `
    -DnsName "dhcp01.corp.contoso.com" `
    -IPAddress "10.0.0.5"

# Verify authorization
Get-DhcpServerInDC

# Create DHCP scope
Add-DhcpServerv4Scope `
    -Name "Corporate Network" `
    -StartRange "10.0.0.100" `
    -EndRange "10.0.0.200" `
    -SubnetMask "255.255.255.0" `
    -State Active `
    -LeaseDuration "8.00:00:00"

# Configure scope options
Set-DhcpServerv4OptionValue `
    -ScopeId "10.0.0.0" `
    -Router "10.0.0.1" `
    -DnsServer "10.0.0.2","10.0.0.3" `
    -DnsDomain "corp.contoso.com"

# Add exclusion range
Add-DhcpServerv4ExclusionRange `
    -ScopeId "10.0.0.0" `
    -StartRange "10.0.0.1" `
    -EndRange "10.0.0.50"

# Create DHCP reservation
Add-DhcpServerv4Reservation `
    -ScopeId "10.0.0.0" `
    -IPAddress "10.0.0.150" `
    -ClientId "00-15-5D-00-00-01" `
    -Description "Print Server"
```

**DHCP Best Practices:**

- Authorize DHCP servers in Active Directory
- Use 80/20 rule for scope distribution across servers
- Configure DHCP failover for high availability
- Implement proper lease duration (8 hours for workstations)
- Use reservations for servers and network devices
- Configure scope options at appropriate levels
- Enable DHCP audit logging
- Regular backup of DHCP database
- Monitor DHCP scope utilization
- Document DHCP configuration

### Group Policy Management

**Group Policy Configuration**

```powershell
# Import Group Policy module
Import-Module GroupPolicy

# Create new GPO
New-GPO -Name "Corporate Security Policy" -Comment "Security settings for all users"

# Link GPO to OU
New-GPLink `
    -Name "Corporate Security Policy" `
    -Target "OU=Engineering,DC=corp,DC=contoso,DC=com" `
    -LinkEnabled Yes

# Set GPO registry value
Set-GPRegistryValue `
    -Name "Corporate Security Policy" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" `
    -ValueName "NoAutoUpdate" `
    -Type DWord `
    -Value 0

# Configure password policy via GPO
Set-GPRegistryValue `
    -Name "Corporate Security Policy" `
    -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -ValueName "MinimumPasswordLength" `
    -Type DWord `
    -Value 12

# Backup GPO
Backup-GPO `
    -Name "Corporate Security Policy" `
    -Path "C:\GPOBackups"

# Restore GPO
Restore-GPO `
    -Name "Corporate Security Policy" `
    -Path "C:\GPOBackups" `
    -BackupId "{GUID}"

# Generate GPO report
Get-GPOReport `
    -Name "Corporate Security Policy" `
    -ReportType Html `
    -Path "C:\Reports\GPOReport.html"
```

**Common Group Policy Settings**

```powershell
# Disable Windows Defender (for servers with third-party AV)
Set-GPRegistryValue -Name "Server Policy" `
    -Key "HKLM\Software\Policies\Microsoft\Windows Defender" `
    -ValueName "DisableAntiSpyware" -Type DWord -Value 1

# Configure Windows Update settings
Set-GPRegistryValue -Name "Server Policy" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" `
    -ValueName "AUOptions" -Type DWord -Value 4

# Enable RDP
Set-GPRegistryValue -Name "Server Policy" `
    -Key "HKLM\System\CurrentControlSet\Control\Terminal Server" `
    -ValueName "fDenyTSConnections" -Type DWord -Value 0

# Configure firewall via GPO
Set-GPRegistryValue -Name "Server Policy" `
    -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\DomainProfile" `
    -ValueName "EnableFirewall" -Type DWord -Value 1
```

**Group Policy Best Practices:**

- Use descriptive GPO names
- Link GPOs at appropriate OU levels
- Use security filtering for targeted application
- Implement WMI filters when needed
- Regular GPO backups
- Document GPO purposes and settings
- Use GPO comments
- Test GPOs in non-production first
- Monitor GPO application with gpresult
- Clean up unused GPOs
- Use starter GPOs for templates
- Implement proper delegation

### PowerShell Remoting

**Enable and Configure PowerShell Remoting**

```powershell
# Enable PS Remoting
Enable-PSRemoting -Force

# Configure trusted hosts (for workgroup)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "server01,server02" -Force

# Test connection
Test-WSMan -ComputerName "server01"

# Create remote session
$session = New-PSSession -ComputerName "server01" -Credential (Get-Credential)

# Run command on remote computer
Invoke-Command -ComputerName "server01" -ScriptBlock {
    Get-Service | Where-Object {$_.Status -eq "Running"}
}

# Run command in existing session
Invoke-Command -Session $session -ScriptBlock {
    Get-Process
}

# Enter interactive session
Enter-PSSession -ComputerName "server01"

# Copy files to remote session
Copy-Item -Path "C:\Scripts\script.ps1" -Destination "C:\Scripts\" -ToSession $session

# Close session
Remove-PSSession $session
```

### Windows Server Security

**Security Hardening**

```powershell
# Disable SMBv1
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart

# Configure Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Allow RDP through firewall
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Configure audit policy
auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable
auditpol /set /category:"Account Management" /success:enable /failure:enable

# Enable Windows Defender (if applicable)
Set-MpPreference -DisableRealtimeMonitoring $false

# Configure Windows Update
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" `
    -Name "NoAutoUpdate" -Value 0

# Disable unnecessary services
Stop-Service -Name "Print Spooler" -Force
Set-Service -Name "Print Spooler" -StartupType Disabled

# Configure account lockout policy
net accounts /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30

# Set minimum password length
net accounts /minpwlen:12

# Set maximum password age
net accounts /maxpwage:60
```

**Security Best Practices:**

- Keep systems patched and updated
- Disable unnecessary services and features
- Use strong passwords and MFA
- Implement least privilege access
- Enable and monitor security logs
- Use BitLocker for disk encryption
- Disable SMBv1 protocol
- Configure Windows Firewall
- Implement AppLocker or WDAC
- Regular security audits
- Use Credential Guard on supported systems
- Implement LAPS for local admin passwords

### IIS Web Server

**IIS Installation and Configuration**

```powershell
# Install IIS with management tools
Install-WindowsFeature Web-Server -IncludeManagementTools

# Install additional IIS features
Install-WindowsFeature Web-Asp-Net45,Web-Net-Ext45,Web-ISAPI-Ext,Web-ISAPI-Filter

# Import IIS module
Import-Module WebAdministration

# Create new website
New-Website -Name "MyWebsite" `
    -Port 80 `
    -PhysicalPath "C:\inetpub\wwwroot\mysite" `
    -ApplicationPool "DefaultAppPool"

# Create application pool
New-WebAppPool -Name "MyAppPool"

# Configure application pool
Set-ItemProperty IIS:\AppPools\MyAppPool `
    -Name managedRuntimeVersion -Value "v4.0"
Set-ItemProperty IIS:\AppPools\MyAppPool `
    -Name processModel.identityType -Value "NetworkService"

# Bind SSL certificate
New-WebBinding -Name "MyWebsite" `
    -Protocol https `
    -Port 443 `
    -IPAddress "*" `
    -HostHeader "www.contoso.com"

# Configure default document
Set-WebConfigurationProperty `
    -Filter "//defaultDocument/files" `
    -PSPath "IIS:\Sites\MyWebsite" `
    -Name "Collection" `
    -Value @{value='index.html'}

# Enable directory browsing
Set-WebConfigurationProperty `
    -Filter /system.webServer/directoryBrowse `
    -PSPath "IIS:\Sites\MyWebsite" `
    -Name enabled `
    -Value $true

# Configure request filtering
Set-WebConfigurationProperty `
    -Filter "/system.webServer/security/requestFiltering" `
    -PSPath "IIS:\Sites\MyWebsite" `
    -Name "allowDoubleEscaping" `
    -Value $false
```

**IIS Best Practices:**

- Use dedicated application pools per application
- Configure appropriate application pool recycling
- Enable HTTP/2 for better performance
- Implement URL rewrite rules
- Use request filtering for security
- Enable failed request tracing
- Configure proper logging
- Use SSL/TLS certificates
- Implement IP restrictions when needed
- Regular security updates
- Monitor application pool health
- Use compression for static content

### File Server Configuration

**File Server Setup**

```powershell
# Install File Server role
Install-WindowsFeature FS-FileServer -IncludeManagementTools

# Create shared folder
New-Item -Path "C:\Shares\Department" -ItemType Directory
New-SmbShare -Name "Department" `
    -Path "C:\Shares\Department" `
    -FullAccess "CORP\Domain Admins" `
    -ChangeAccess "CORP\Department-Users" `
    -ReadAccess "CORP\Domain Users"

# Set NTFS permissions
$acl = Get-Acl "C:\Shares\Department"
$permission = "CORP\Department-Users","Modify","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl "C:\Shares\Department" $acl

# Enable access-based enumeration
Set-SmbShare -Name "Department" -FolderEnumerationMode AccessBased

# Configure shadow copies
vssadmin add shadowstorage /for=C: /on=C: /maxsize=10%
$class = [WMICLASS]"root\cimv2:Win32_ShadowCopy"
$class.Create("C:\", "ClientAccessible")

# Create DFS namespace
Install-WindowsFeature FS-DFS-Namespace -IncludeManagementTools
New-DfsnRoot -Path "\\corp.contoso.com\Files" `
    -TargetPath "\\fileserver01\Files" `
    -Type DomainV2

# Add DFS folder
New-DfsnFolder -Path "\\corp.contoso.com\Files\Department" `
    -TargetPath "\\fileserver01\Department"
```

### Backup and Recovery

**Windows Server Backup**

```powershell
# Install Windows Server Backup
Install-WindowsFeature Windows-Server-Backup

# Create backup policy
$policy = New-WBPolicy

# Add system state to backup
Add-WBSystemState -Policy $policy

# Add volumes to backup
$volume = Get-WBVolume -VolumePath "C:"
Add-WBVolume -Policy $policy -Volume $volume

# Set backup target
$target = New-WBBackupTarget -VolumePath "E:"
Add-WBBackupTarget -Policy $policy -Target $target

# Set backup schedule (daily at 11 PM)
Set-WBSchedule -Policy $policy -Schedule "23:00"

# Apply policy
Set-WBPolicy -Policy $policy

# Start immediate backup
Start-WBBackup -Policy $policy

# Restore files
Start-WBFileRecovery -BackupSet $backupSet `
    -SourcePath "C:\Data\file.txt" `
    -TargetPath "C:\Restore\"

# Restore system state
Start-WBSystemStateRecovery -BackupSet $backupSet
```

**Active Directory Backup**

```powershell
# Backup AD (System State includes AD)
wbadmin start systemstatebackup -backupTarget:E: -quiet

# Restore AD (requires Directory Services Restore Mode)
# Boot into DSRM, then:
wbadmin start systemstaterecovery -version:01/15/2024-23:00 -backupTarget:E:

# Perform authoritative restore
ntdsutil
activate instance ntds
authoritative restore
restore subtree "OU=Engineering,DC=corp,DC=contoso,DC=com"
quit
quit
```

**Backup Best Practices:**

- Implement 3-2-1 backup strategy
- Regular backup testing
- Automate backup processes
- Monitor backup job status
- Store backups off-site
- Document recovery procedures
- Test disaster recovery plans
- Use incremental backups
- Encrypt backup data
- Maintain backup retention policy

### Monitoring and Performance

**Performance Monitoring**

```powershell
# Get system information
Get-ComputerInfo

# Check CPU usage
Get-Counter '\Processor(_Total)\% Processor Time'

# Check memory usage
Get-Counter '\Memory\Available MBytes'

# Check disk performance
Get-Counter '\PhysicalDisk(_Total)\Avg. Disk Queue Length'

# Create performance counter data collector
$counterSet = New-Object System.Diagnostics.PerformanceCounterCategory
logman create counter PerfLog -c "\Processor(_Total)\% Processor Time" `
    "\Memory\Available MBytes" `
    "\PhysicalDisk(_Total)\Avg. Disk Queue Length" `
    -f bin -si 00:00:01 -o "C:\PerfLogs\PerfLog.blg"

# Start data collector
logman start PerfLog

# View event logs
Get-EventLog -LogName System -Newest 100 -EntryType Error

# Get Windows events (newer method)
Get-WinEvent -LogName System -MaxEvents 100 | Where-Object {$_.LevelDisplayName -eq "Error"}

# Export event log
wevtutil epl System C:\Logs\System.evtx

# Check service status
Get-Service | Where-Object {$_.Status -eq "Running"}

# Monitor specific service
Get-Service -Name "W3SVC" | Select-Object Name,Status,StartType
```

**Windows Admin Center**

```powershell
# Install Windows Admin Center
msiexec /i WindowsAdminCenter.msi /qn /L*v log.txt `
    SME_PORT=443 `
    SSL_CERTIFICATE_OPTION=generate

# Register with Azure (optional)
# Done through WAC GUI: Settings > Azure > Register
```

### Windows Server Core

**Server Core Management**

```powershell
# Configure server name
Rename-Computer -NewName "SERVER01" -Restart

# Configure network settings
New-NetIPAddress -InterfaceAlias "Ethernet" `
    -IPAddress "10.0.0.10" `
    -PrefixLength 24 `
    -DefaultGateway "10.0.0.1"

Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
    -ServerAddresses "10.0.0.2","10.0.0.3"

# Join domain
Add-Computer -DomainName "corp.contoso.com" `
    -Credential (Get-Credential) `
    -Restart

# Configure Windows Update
sconfig

# Enable Remote Desktop
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" `
    -Name "fDenyTSConnections" -Value 0

Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Configure time zone
Set-TimeZone -Name "Eastern Standard Time"

# View installed roles and features
Get-WindowsFeature | Where-Object {$_.Installed -eq $true}
```

**Server Core Best Practices:**

- Use for domain controllers and infrastructure servers
- Smaller attack surface
- Lower resource requirements
- Reduced patching requirements
- Manage remotely via PowerShell
- Use Windows Admin Center for GUI management
- Implement proper remote management
- Document server configurations

### Clustering and High Availability

**Failover Clustering**

```powershell
# Install Failover Clustering feature
Install-WindowsFeature Failover-Clustering -IncludeManagementTools

# Test cluster configuration
Test-Cluster -Node "SERVER01","SERVER02"

# Create cluster
New-Cluster -Name "CLUSTER01" `
    -Node "SERVER01","SERVER02" `
    -StaticAddress "10.0.0.100"

# Add cluster node
Add-ClusterNode -Name "SERVER03" -Cluster "CLUSTER01"

# Create file server role
Add-ClusterFileServerRole -Name "FS01" `
    -Storage "Cluster Disk 1" `
    -StaticAddress "10.0.0.101"

# Configure cluster quorum
Set-ClusterQuorum -NodeAndFileShareMajority "\\fileserver\quorum"

# View cluster resources
Get-ClusterResource

# Move cluster group
Move-ClusterGroup -Name "FS01" -Node "SERVER02"
```

**Network Load Balancing**

```powershell
# Install NLB feature
Install-WindowsFeature NLB -IncludeManagementTools

# Create NLB cluster
New-NlbCluster -InterfaceName "Ethernet" `
    -ClusterName "WEB-CLUSTER" `
    -ClusterPrimaryIP "10.0.0.200" `
    -SubnetMask "255.255.255.0"

# Add NLB node
Add-NlbClusterNode -InterfaceName "Ethernet" `
    -NewNodeName "WEB02" `
    -NewNodeInterface "Ethernet"

# Add port rule
Add-NlbClusterPortRule -Protocol Tcp `
    -Mode Multiple `
    -StartPort 80 `
    -EndPort 80 `
    -Affinity Single
```

### Automation and Scripting

**Common Administrative Tasks**

```powershell
# Bulk user creation from CSV
$users = Import-Csv "C:\Users.csv"
foreach ($user in $users) {
    New-ADUser `
        -Name "$($user.FirstName) $($user.LastName)" `
        -GivenName $user.FirstName `
        -Surname $user.LastName `
        -SamAccountName $user.Username `
        -UserPrincipalName "$($user.Username)@corp.contoso.com" `
        -Path $user.OU `
        -AccountPassword (ConvertTo-SecureString $user.Password -AsPlainText -Force) `
        -Enabled $true
}

# Disable inactive user accounts
$inactiveDate = (Get-Date).AddDays(-90)
Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 -UsersOnly | 
    Disable-ADAccount

# Find and remove old computer accounts
$staleDate = (Get-Date).AddDays(-180)
Get-ADComputer -Filter {LastLogonDate -lt $staleDate} -Properties LastLogonDate |
    Remove-ADComputer -Confirm:$false

# Export AD users to CSV
Get-ADUser -Filter * -Properties * | 
    Select-Object Name,SamAccountName,EmailAddress,Department,Title |
    Export-Csv "C:\ADUsers.csv" -NoTypeInformation

# Check AD replication status
Get-ADReplicationPartnerMetadata -Target "DC01" -Scope Domain

# Force AD replication
repadmin /syncall /AdeP

# Get disk space information
Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" |
    Select-Object DeviceID,
        @{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}},
        @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
        @{Name="PercentFree";Expression={[math]::Round(($_.FreeSpace/$_.Size)*100,2)}}

# Clean up old files
Get-ChildItem "C:\Logs" -Recurse -File | 
    Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-30)} |
    Remove-Item -Force
```

### Troubleshooting

**Common Troubleshooting Commands**

```powershell
# Test network connectivity
Test-Connection -ComputerName "server01" -Count 4

# Test port connectivity
Test-NetConnection -ComputerName "server01" -Port 3389

# Check DNS resolution
Resolve-DnsName "server01.corp.contoso.com"

# Flush DNS cache
Clear-DnsClientCache

# View routing table
Get-NetRoute

# Check firewall rules
Get-NetFirewallRule | Where-Object {$_.Enabled -eq $true}

# View active connections
Get-NetTCPConnection -State Established

# Check AD replication
repadmin /replsummary
repadmin /showrepl

# Verify SYSVOL replication
dfsrdiag replicationstate

# Check domain controller health
dcdiag /v

# Test domain controller connectivity
nltest /dsgetdc:corp.contoso.com

# View Group Policy results
gpresult /h "C:\GPResult.html"

# Force Group Policy update
gpupdate /force

# Check Windows activation
slmgr /dlv

# View installed updates
Get-HotFix | Sort-Object InstalledOn -Descending

# Check system uptime
(Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
```

### Best Practices Summary

**General Best Practices:**

- Use Windows Server Core when possible
- Implement proper naming conventions
- Document all configurations
- Regular patching and updates
- Use PowerShell for automation
- Implement monitoring and alerting
- Regular backups and DR testing
- Follow principle of least privilege
- Use Group Policy for configuration management
- Implement proper change management

**Domain Controller Best Practices:**

- Minimum of two DCs per domain
- Place DCs in different physical locations
- Use separate physical/virtual machines
- Regular AD health checks
- Monitor replication status
- Implement proper backup procedures
- Use RODCs for branch offices
- Protect DSRM password
- Enable AD Recycle Bin
- Regular security audits

**DNS Best Practices:**

- Use AD-integrated zones
- Configure secure dynamic updates
- Implement DNS scavenging
- Use forwarders appropriately
- Configure reverse lookup zones
- Monitor DNS performance
- Regular zone backups
- Document DNS architecture

**DHCP Best Practices:**

- Authorize in Active Directory
- Implement DHCP failover
- Use appropriate lease durations
- Configure scope options correctly
- Monitor scope utilization
- Regular database backups
- Enable audit logging
- Document DHCP configuration

**Security Best Practices:**

- Keep systems patched
- Disable unnecessary services
- Use strong passwords and MFA
- Implement least privilege
- Enable security logging
- Use BitLocker encryption
- Disable SMBv1
- Configure Windows Firewall
- Regular security audits
- Implement LAPS

**Performance Best Practices:**

- Right-size server resources
- Monitor performance metrics
- Implement proper disk configuration
- Use SSDs for high I/O workloads
- Configure page file appropriately
- Regular performance reviews
- Optimize services and startup programs
- Use performance baselines
