Import-module -name AWSPowerShell

# Initialize-AWSDefaults
$region = 'eu-west-1' 
# Create secrets for the lab

$secrets = ('evlab/ad/joinuser',
    'evlab/ad/adbackups',
    'evlab/ad/simpana-install',
    'evlab/ad/simpana-ad',
    'evlab/ad/simpana-sql',
    'evlab/ad/simpana-push',
    'evlab/guacamole/mysqlroot',
    'evlab/guacamole/mysqluser',
    'evlab/glpi/mysqlroot',
    'evlab/glpi/mysqluser',
    'evlab/guacamole/keystore',
    'evlab/guacamole/mail',
    'evlab/sharepoint/sp_farm',
    'evlab/redis/root',
    'evlab/sharepoint/sp_services',
    'evlab/sharepoint/sp_portalAppPool',
    'evlab/sharepoint/sp_profilesAppPool',
    'evlab/sharepoint/sp_searchService',
    'evlab/sharepoint/sp_cacheSuperUser',
    'evlab/sharepoint/sp_cacheSuperReader',
    'evlab/sql/svc-sql',
    'evlab/sql/svc-sql-sccm',
    'evlab/pki/svc-ndes')


foreach ($secret in $secrets) {
    $secvalue = Get-SECRandomPassword -Region $region -ExcludePunctuation $true -IncludeSpace $false
    New-SECSecret `
        -SecretString $secvalue `
        -Name $secret `
        -Region $region
}
