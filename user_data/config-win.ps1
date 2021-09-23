<powershell>
Initialize-AWSDefaults
$instanceId = Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/instance-id #DevSkim: ignore DS104456
$instance = (Get-EC2Instance -InstanceId $instanceId).Instances[0]
$instanceName = ($instance.Tags | Where-Object { $_.Key -eq "Name" } | Select-Object -Expand Value)

Rename-Computer -NewName $instanceName -Force -Confirm:$false

$NewLocalAdmin = "ansible"
$Password = "NotS0S3cr3t!"
$SecurePassword=ConvertTo-SecureString $Password -asplaintext -force

New-LocalUser "$NewLocalAdmin" -Password $SecurePassword -FullName "$NewLocalAdmin" -Description "Temporary local admin"
Add-LocalGroupMember -Group "Administrators" -Member "$NewLocalAdmin"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

powershell.exe -ExecutionPolicy ByPass -File $file
</powershell>
