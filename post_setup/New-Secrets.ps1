Import-module -name AWSPowerShell

# Initialize-AWSDefaults
$region = 'eu-west-1'
# Create secrets for the lab

$secrets = (
    'evlab.ch/ad/joinuser',
    'evlab.ch/ad/fjacquet',
    'evlab.ch/ad/adbackups',
    'evlab.ch/ad/simpana-install',
    'evlab.ch/ad/simpana-ad',
    'evlab.ch/ad/simpana-sql',
    'evlab.ch/ad/simpana-push',
    'evlab.ch/guacamole/mysqlroot',
    'evlab.ch/guacamole/mysqluser',
    'evlab.ch/glpi/mysqlroot',
    'evlab.ch/glpi/mysqluser',
    'evlab.ch/guacamole/keystore',
    'evlab.ch/guacamole/mail',
    'evlab.ch/sharepoint/sp_farm',
    'evlab.ch/redis/root',
    'evlab.ch/sharepoint/sp_services',
    'evlab.ch/sharepoint/sp_portalAppPool',
    'evlab.ch/sharepoint/sp_profilesAppPool',
    'evlab.ch/sharepoint/sp_searchService',
    'evlab.ch/sharepoint/sp_cacheSuperUser',
    'evlab.ch/sharepoint/sp_cacheSuperReader',
    'evlab.ch/sql/svc-sql',
    'evlab.ch/sql/svc-sql-sccm',
    'evlab.ch/pki/svc-ndes')


foreach ($secret in $secrets) {
    $secvalue = Get-SECRandomPassword -Region $region -ExcludePunctuation $true -IncludeSpace $false
    New-SECSecret `
        -SecretString $secvalue `
        -Name $secret `
        -Region $region
}
