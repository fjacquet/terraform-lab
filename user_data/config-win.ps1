<powershell>

Initialize-AWSDefaults
$instanceId = Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/instance-id #DevSkim: ignore DS104456
$instance = (Get-EC2Instance -InstanceId $instanceId).Instances[0]
$instanceName = ($instance.Tags | Where-Object { $_.Key -eq "Name" } | Select-Object -Expand Value)

Rename-Computer -NewName $instanceName -Force -Confirm:$false

# net user ansible NotS0S3cr3t! /add /expires:never
# net localgroup administrators ansible /add

$NewLocalAdmin = "ansible"
$Password = "NotS0S3cr3t!"

New-LocalUser "$NewLocalAdmin" -Password $Password -FullName "$NewLocalAdmin" -Description "Temporary local admin"
Add-LocalGroupMember -Group "Administrators" -Member "$NewLocalAdmin"



$url = 'https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/ConfigureRemotingForAnsible.ps1'
Invoke-Expression ((New-Object System.Net.Webclient).DownloadString($url)) #DevSkim: ignore DS104456



# winrm quickconfig -q
# winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
# winrm set winrm/config '@{MaxTimeoutms="1800000"}'
# winrm set winrm/config/service '@{AllowUnencrypted="true"}'
# winrm set winrm/config/service/auth '@{Basic="true"}'

# netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
# netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow

# Stop-Service -Name "WinRM" -ErrorAction Stop
# Set-Service -Name "WinRM" -StartupType Automatic
# Start-Service -Name "WinRM" -ErrorAction Stop

</powershell>
