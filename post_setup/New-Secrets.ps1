Import-Module -Name AWSPowerShell

# Initialize-AWSDefaults
$region = 'eu-west-1'
# Create secrets for the lab

$secrets = (
  'ez-lab.xyz/ad/joinuser',
  'ez-lab.xyz/ad/fjacquet',
  'ez-lab.xyz/ad/adbackups',
  'ez-lab.xyz/ad/simpana-install',
  'ez-lab.xyz/ad/simpana-ad',
  'ez-lab.xyz/ad/simpana-sql',
  'ez-lab.xyz/ad/simpana-push',
  'ez-lab.xyz/guacamole/mysqlroot',
  'ez-lab.xyz/guacamole/mysqluser',
  'ez-lab.xyz/glpi/mysqlroot',
  'ez-lab.xyz/glpi/mysqluser',
  'ez-lab.xyz/guacamole/keystore',
  'ez-lab.xyz/guacamole/mail',
  'ez-lab.xyz/sharepoint/sp_farm',
  'ez-lab.xyz/redis/root',
  'ez-lab.xyz/sharepoint/sp_services',
  'ez-lab.xyz/sharepoint/sp_portalAppPool',
  'ez-lab.xyz/sharepoint/sp_profilesAppPool',
  'ez-lab.xyz/sharepoint/sp_searchService',
  'ez-lab.xyz/sharepoint/sp_cacheSuperUser',
  'ez-lab.xyz/sharepoint/sp_cacheSuperReader',
  'ez-lab.xyz/sql/svc-sql',
  'ez-lab.xyz/sql/svc-sql-sccm',
  'ez-lab.xyz/pki/svc-ndes')


foreach ($secret in $secrets) {
  $secvalue = Get-SECRandomPassword -region $region -ExcludePunctuation $true -IncludeSpace $false
  New-SECSecret `
     -SecretString $secvalue `
     -Name $secret `
     -region $region
}
