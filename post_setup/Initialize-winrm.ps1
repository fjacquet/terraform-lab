$admin = [adsi]("WinNT://./${var.win_username}, user")
$admin.PSBase.Invoke("SetPassword", "${var.win_password}")
$url = 'https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'
Invoke-Expression ((New-Object System.Net.Webclient).DownloadString($url)) #DevSkim: ignore DS104456 
