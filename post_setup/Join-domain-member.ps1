#Requires -Version 5.1

<#
.SYNOPSIS
    Joins a Windows server to an Active Directory domain.

.DESCRIPTION
    This script retrieves domain join credentials from AWS Secrets Manager and joins
    the server to the specified Active Directory domain. It uses IMDSv2 for metadata
    retrieval and implements comprehensive error handling with Windows Event Log logging.

.NOTES
    Author: Infrastructure Team
    Version: 2.0.0
    Last Modified: 2024-01-10
#>

# Initialize error handling
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

# Ensure Event Log source exists
$eventSource = "DomainJoin"
if (-not [System.Diagnostics.EventLog]::SourceExists($eventSource)) {
    try {
        New-EventLog -LogName Application -Source $eventSource -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "Could not create event log source: $_"
    }
}

function Write-EventLogSafely {
    <#
    .SYNOPSIS
        Writes to Windows Event Log with error handling.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Error', 'Warning', 'Information')]
        [string]$EntryType,
        
        [Parameter(Mandatory)]
        [int]$EventId,
        
        [Parameter(Mandatory)]
        [string]$Message
    )
    
    try {
        Write-EventLog -LogName Application -Source $eventSource `
            -EntryType $EntryType -EventId $EventId -Message $Message
    }
    catch {
        Write-Warning "Failed to write to event log: $_"
    }
}

function Get-IMDSv2Token {
    <#
    .SYNOPSIS
        Retrieves an IMDSv2 token for secure metadata access.
    
    .DESCRIPTION
        Requests a session token from the EC2 Instance Metadata Service v2.
        This token is required for all subsequent metadata API calls.
    
    .OUTPUTS
        String. The IMDSv2 session token.
    #>
    [CmdletBinding()]
    param()
    
    try {
        Write-Verbose "Retrieving IMDSv2 token"
        
        $tokenUri = "http://169.254.169.254/latest/api/token"
        $tokenResponse = Invoke-RestMethod -Uri $tokenUri `
            -Method PUT `
            -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"} `
            -TimeoutSec 5 `
            -ErrorAction Stop
        
        Write-Verbose "Successfully retrieved IMDSv2 token"
        return $tokenResponse
    }
    catch {
        $errorMessage = "Failed to retrieve IMDSv2 token: $_"
        Write-Error $errorMessage
        Write-EventLogSafely -EntryType Error -EventId 1001 -Message $errorMessage
        throw
    }
}

function Get-EC2MetadataWithToken {
    <#
    .SYNOPSIS
        Retrieves EC2 instance metadata using IMDSv2.
    
    .PARAMETER Token
        The IMDSv2 session token.
    
    .PARAMETER Path
        The metadata path to retrieve (e.g., 'placement/region').
    
    .OUTPUTS
        String. The requested metadata value.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Token,
        
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    try {
        $metadataUri = "http://169.254.169.254/latest/meta-data/$Path"
        Write-Verbose "Retrieving metadata from: $Path"
        
        $metadata = Invoke-RestMethod -Uri $metadataUri `
            -Headers @{"X-aws-ec2-metadata-token" = $Token} `
            -TimeoutSec 5 `
            -ErrorAction Stop
        
        Write-Verbose "Successfully retrieved metadata: $Path"
        return $metadata
    }
    catch {
        $errorMessage = "Failed to retrieve metadata from path '$Path': $_"
        Write-Error $errorMessage
        Write-EventLogSafely -EntryType Error -EventId 1002 -Message $errorMessage
        throw
    }
}

function Get-SecretSafely {
    <#
    .SYNOPSIS
        Retrieves a secret from AWS Secrets Manager with comprehensive error handling.
    
    .PARAMETER SecretId
        The ID or ARN of the secret to retrieve.
    
    .PARAMETER Region
        The AWS region where the secret is stored.
    
    .OUTPUTS
        String. The secret value.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SecretId,
        
        [Parameter(Mandatory)]
        [string]$Region
    )
    
    try {
        Write-Verbose "Retrieving secret: $SecretId from region: $Region"
        
        $secretValue = (Get-SECSecretValue -SecretId $SecretId -Region $Region -ErrorAction Stop).SecretString
        
        # Validate secret value is not null or empty
        if ([string]::IsNullOrEmpty($secretValue)) {
            throw "Secret value is null or empty for SecretId: $SecretId"
        }
        
        Write-Verbose "Successfully retrieved secret: $SecretId"
        return $secretValue
    }
    catch {
        $errorMessage = "Failed to retrieve secret '$SecretId' from region '$Region': $_"
        Write-Error $errorMessage
        Write-EventLogSafely -EntryType Error -EventId 1003 -Message $errorMessage
        throw
    }
}

# Main script execution
try {
    Write-Output "Starting domain join process"
    Write-EventLogSafely -EntryType Information -EventId 1000 -Message "Domain join process started"
    
    # Initialize AWS defaults
    Initialize-AWSDefaults
    
    # Get IMDSv2 token
    $token = Get-IMDSv2Token
    
    # Retrieve region from instance metadata using IMDSv2
    $region = Get-EC2MetadataWithToken -Token $token -Path "placement/region"
    Write-Output "Detected region: $region"
    
    # Domain configuration
    $domain = 'ez-lab.xyz'
    $username = "joinuser"
    
    # Retrieve domain join credentials from Secrets Manager
    Write-Output "Retrieving domain join credentials from Secrets Manager"
    $secret = Get-SecretSafely -SecretId "$($domain)/ad/$($username)" -Region $region
    
    # Create credential object
    $password = ConvertTo-SecureString -AsPlainText -Force $secret
    $credential = New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList $username, $password
    
    # Configure DNS suffix search list
    Write-Output "Configuring DNS suffix search list"
    try {
        Set-DnsClientGlobalSetting -SuffixSearchList @(
            $domain,
            "$($region).ec2-utilities.amazonaws.com",
            "us-east-1.ec2-utilities.amazonaws.com",
            "$($region).compute.internal"
        ) -ErrorAction Stop
        
        Write-Verbose "DNS suffix search list configured successfully"
    }
    catch {
        $errorMessage = "Failed to configure DNS suffix search list: $_"
        Write-Warning $errorMessage
        Write-EventLogSafely -EntryType Warning -EventId 1004 -Message $errorMessage
        # Continue execution as this is not critical
    }
    
    # Join the domain
    Write-Output "Joining domain: $domain"
    Add-Computer -DomainName $domain `
        -Credential $credential `
        -Restart:$false `
        -Force `
        -ErrorAction Stop
    
    Write-Output "Successfully joined domain: $domain"
    Write-EventLogSafely -EntryType Information -EventId 1005 `
        -Message "Successfully joined domain: $domain. Restart required to complete domain join."
    
    Write-Output "Domain join completed successfully. Please restart the computer to complete the process."
}
catch {
    $errorMessage = "Domain join failed: $_"
    Write-Error $errorMessage
    Write-EventLogSafely -EntryType Error -EventId 1099 -Message $errorMessage
    
    # Exit with error code
    exit 1
}
