Import-Module -Name AWSPowerShell

# Function to retrieve IMDSv2 token
function Get-IMDSv2Token {
    [CmdletBinding()]
    param(
        [int]$TTLSeconds = 21600
    )
    
    try {
        $tokenUri = 'http://169.254.169.254/latest/api/token'
        $token = Invoke-RestMethod -Uri $tokenUri -Method PUT -Headers @{
            'X-aws-ec2-metadata-token-ttl-seconds' = $TTLSeconds.ToString()
        } -TimeoutSec 5 -ErrorAction Stop
        
        return $token
    }
    catch {
        Write-EventLog -LogName Application -Source 'Application' `
            -EntryType Error -EventId 1003 `
            -Message "Failed to retrieve IMDSv2 token: $_"
        throw "Failed to retrieve IMDSv2 token: $_"
    }
}

# Function to get metadata using IMDSv2
function Get-EC2MetadataWithToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Token,
        
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    try {
        $metadataUri = "http://169.254.169.254/latest/meta-data/$Path"
        $result = Invoke-RestMethod -Uri $metadataUri -Headers @{
            'X-aws-ec2-metadata-token' = $Token
        } -TimeoutSec 5 -ErrorAction Stop
        
        return $result
    }
    catch {
        Write-EventLog -LogName Application -Source 'Application' `
            -EntryType Error -EventId 1004 `
            -Message "Failed to retrieve metadata from path '$Path': $_"
        throw "Failed to retrieve metadata from path '$Path': $_"
    }
}

# Retrieve region from instance metadata using IMDSv2
try {
    Write-Host "Retrieving region from instance metadata..."
    $token = Get-IMDSv2Token
    $region = Get-EC2MetadataWithToken -Token $token -Path 'placement/region'
    Write-Host "Region detected: $region"
}
catch {
    Write-Error "Failed to retrieve region from metadata. Falling back to default region 'eu-west-1'"
    $region = 'eu-west-1'
}

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

$successCount = 0
$failureCount = 0

foreach ($secret in $secrets) {
    try {
        Write-Host "Processing secret: $secret"
        
        # Generate random password with error handling
        try {
            $secvalue = Get-SECRandomPassword -Region $region -ExcludePunctuation $true -IncludeSpace $false -ErrorAction Stop
            
            # Validate that password was generated
            if ([string]::IsNullOrEmpty($secvalue)) {
                throw "Generated password is null or empty"
            }
            
            Write-Host "  Generated password for $secret"
        }
        catch {
            $errorMessage = "Failed to generate random password for secret '$secret': $_"
            Write-Error $errorMessage
            Write-EventLog -LogName Application -Source 'Application' `
                -EntryType Error -EventId 1005 `
                -Message $errorMessage
            $failureCount++
            continue
        }
        
        # Create secret with error handling
        try {
            $result = New-SECSecret `
                -SecretString $secvalue `
                -Name $secret `
                -Region $region `
                -ErrorAction Stop
            
            # Validate secret creation success
            if ($null -eq $result -or [string]::IsNullOrEmpty($result.ARN)) {
                throw "Secret creation returned null or invalid result"
            }
            
            Write-Host "  Successfully created secret: $secret (ARN: $($result.ARN))" -ForegroundColor Green
            $successCount++
        }
        catch {
            $errorMessage = "Failed to create secret '$secret': $_"
            Write-Error $errorMessage
            Write-EventLog -LogName Application -Source 'Application' `
                -EntryType Error -EventId 1006 `
                -Message $errorMessage
            $failureCount++
        }
    }
    catch {
        $errorMessage = "Unexpected error processing secret '$secret': $_"
        Write-Error $errorMessage
        Write-EventLog -LogName Application -Source 'Application' `
            -EntryType Error -EventId 1007 `
            -Message $errorMessage
        $failureCount++
    }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Secret Creation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total secrets processed: $($secrets.Count)"
Write-Host "Successfully created: $successCount" -ForegroundColor Green
Write-Host "Failed: $failureCount" -ForegroundColor $(if ($failureCount -gt 0) { 'Red' } else { 'Green' })
Write-Host "========================================`n" -ForegroundColor Cyan

if ($failureCount -gt 0) {
    Write-Warning "Some secrets failed to create. Check the Application Event Log for details."
    exit 1
}
else {
    Write-Host "All secrets created successfully!" -ForegroundColor Green
    exit 0
}
