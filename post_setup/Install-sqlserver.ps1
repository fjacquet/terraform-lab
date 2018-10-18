
Initialize-AWSDefaults
$svcsecret = (Get-SECSecretValue -SecretId "evlab/sql/svc-sql").SecretString | ConvertFrom-Json

$domain = "evlab"
$svcuser = "svc-sql"
$arguments = "/ACTION=install "
$arguments += "/QS "
$arguments += "/IACCEPTSQLSERVERLICENSETERMS=1 "
$arguments += "/FEATURES=SQLENGINE,RS "
$arguments += "/SQLSYSADMINACCOUNTS=$($domain)\SQL Admins "
$arguments += "/SQLCOLLATION=SQL_Latin1_General_CP1_CI_AS "
$arguments += "/SQLSVCACCOUNT=$($domain)\$($svcuser) "
$arguments += "/SQLSVCPASSWORD=$($svcsecret) "
$arguments += "/INSTANCENAME=MSSQLSERVER"

$file = "E:\Setup.exe"
$params = @{
  FilePath = $file
  Wait = $true
  ArgumentList = $arguments
}
Start-Process -FilePath $file -ArgumentList @params

