Initialize-AWSDefaults

# Create secrets for the lab

$secrets = ('evlab/ad/joinuser',
  'evlab/ad/fjacquet',
  'evlab/guacamole/mysqlroot',
  'evlab/guacamole/mysqluser',
  'evlab/glpi/mysqlroot',
  'evlab/glpi/mysqluser',
  'evlab/guacamole/keystore',
  'evlab/guacamole/mail',
  'evlab/sharepoint/sp_farm',
  'evlab/sharepoint/sp_services',
  'evlab/sharepoint/sp_portalAppPool',
  'evlab/sharepoint/sp_profilesAppPool',
  'evlab/sharepoint/sp_searchService',
  'evlab/sharepoint/sp_cacheSuperUser',
  'evlab/sharepoint/sp_cacheSuperReader',
  'evlab/sql/svc-sql',
  'evlab/pki/svc-ndes')
foreach ($secret in $secrets) {
  New-SECSecret
  -SecretString $random
  -Name $secret
}
