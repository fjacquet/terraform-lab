Initialize-AWSDefaults
$secret = (Get-SECSecretValue -SecretId "ez-lab.xyz/mdt/service").SecretString | ConvertFrom-Json
$deploymentdrive = "D:"
$script = "setup-mdt8450auto.ps1"
$url = 'https://raw.githubusercontent.com/fjacquet/terraform-lab/master/post_setup/$($script)'

Invoke-WebRequest -Uri $url -OutFile $script #DevSkim: ignore DS104456
powershell -ExecutionPolicy bypass -File $script `
   -office365 `
   -applications `
   -DeploymentShareDrive $deploymentdrive `
   -ServiceAccountPassword $secret
