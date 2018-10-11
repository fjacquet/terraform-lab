Initialize-AWSDefaults
$instanceId = Invoke-RestMethod -Uri http://169.254.169.254/latest/meta-data/instance-id #DevSkim: ignore DS104456 
$instance = (Get-EC2Instance -InstanceId $instanceId).Instances[0]
$instanceName = ($instance.Tags | Where-Object { $_.Key -eq "Name" } | Select-Object -Expand Value)
Rename-Computer -NewName $instanceName -force -confirm:$false
 