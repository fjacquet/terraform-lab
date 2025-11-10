<powershell>
#Requires -Version 5.1

<#
.SYNOPSIS
    EC2 Windows instance initialization script with enhanced security and error handling.

.DESCRIPTION
    This script configures a Windows EC2 instance with:
    - IMDSv2 token-based metadata access
    - Secrets Manager integration for credentials
    - Comprehensive error handling and logging
    - Ansible remote management setup

.NOTES
    Author: terraform-lab
    Version: 2.0
    Requires: AWS Tools for PowerShell, IMDSv2 enabled on instance
#>

# Ensure event log source exists
try {
    if (-not [System.Diagnostics.EventLog]::SourceExists("EC2Config")) {
        New-EventLog -LogName Application -Source "EC2Config" -ErrorAction Stop
    }
}
catch {
    Write-Warning "Could not create event log source: $_"
}

#region Helper Functions

function Get-IMDSv2Token {
    <#
    .SYNOPSIS
        Retrieves an IMDSv2 token for secure metadata access.
    
    .DESCRIPTION
        Makes a PUT request to the EC2 metadata service to obtain a session token
        required for IMDSv2 authentication.
    
    .PARAMETER TTLSeconds
        Time-to-live for the token in seconds. Default is 21600 (6 hours).
    
    .OUTPUTS
        String containing the IMDSv2 token.
    
    .EXAMPLE
        $token = Get-IMDSv2Token
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$TTLSeconds = 21600
    )
    
    try {
        $tokenUri = "http://169.254.169.254/latest/api/token"
        $headers = @{
            "X-aws-ec2-metadata-token-ttl-seconds" = $TTLSeconds.ToString()
        }
        
        $token = Invoke-RestMethod -Uri $tokenUri -Method PUT -Headers $headers -TimeoutSec 5 -ErrorAction Stop
        
        if ([string]::IsNullOrEmpty($token)) {
            throw "IMDSv2 token is empty"
        }
        
        Write-Verbose "Successfully retrieved IMDSv2 token"
        return $token
    }
    catch {
        $errorMessage = "Failed to retrieve IMDSv2 token: $_"
        Write-Error $errorMessage
        
        try {
            Write-EventLog -LogName Application -Source "EC2Config" `
                -EntryType Error -EventId 1000 `
                -Message $errorMessage
        }
        catch {
            Write-Warning "Could not write to event log: $_"
        }
        
        throw
    }
}

function Get-EC2Metadata {
    <#
    .SYNOPSIS
        Retrieves EC2 instance metadata using IMDSv2.
    
    .DESCRIPTION
        Makes authenticated requests to the EC2 metadata service using IMDSv2 tokens.
    
    .PARAMETER Path
        The metadata path to retrieve (e.g., 'instance-id', 'placement/region').
    
    .PARAMETER Token
        The IMDSv2 token for authentication.
    
    .OUTPUTS
        String containing the requested metadata value.
    
    .EXAMPLE
        $token = Get-IMDSv2Token
        $instanceId = Get-EC2Metadata -Path "instance-id" -Token $token
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [string]$Token
    )
    
    try {
        $metadataUri = "http://169.254.169.254/latest/meta-data/$Path"
        $headers = @{
            "X-aws-ec2-metadata-token" = $Token
        }
        
        $metadata = Invoke-RestMethod -Uri $metadataUri -Headers $headers -TimeoutSec 5 -ErrorAction Stop
        
        if ([string]::IsNullOrEmpty($metadata)) {
            throw "Metadata value is empty for path: $Path"
        }
        
        Write-Verbose "Successfully retrieved metadata for path: $Path"
        return $metadata
    }
    catch {
        $errorMessage = "Failed to retrieve metadata for path '$Path': $_"
        Write-Error $errorMessage
        
        try {
            Write-EventLog -LogName Application -Source "EC2Config" `
                -EntryType Error -EventId 1002 `
                -Message $errorMessage
        }
        catch {
            Write-Warning "Could not write to event log: $_"
        }
        
        throw
    }
}

function Get-SecretSafely {
    <#
    .SYNOPSIS
        Safely retrieves a secret from AWS Secrets Manager with error handling.
    
    .DESCRIPTION
        Retrieves a secret value from AWS Secrets Manager with comprehensive error
        handling, validation, and logging to Windows Event Log.
    
    .PARAMETER SecretId
        The ID or ARN of the secret to retrieve.
    
    .PARAMETER Region
        The AWS region where the secret is stored.
    
    .OUTPUTS
        String containing the secret value.
    
    .EXAMPLE
        $password = Get-SecretSafely -SecretId "my-secret" -Region "us-east-1"
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
        
        $secret = (Get-SECSecretValue -SecretId $SecretId -Region $Region -ErrorAction Stop).SecretString
        
        if ([string]::IsNullOrEmpty($secret)) {
            throw "Secret value is empty for SecretId: $SecretId"
        }
        
        Write-Verbose "Successfully retrieved secret: $SecretId"
        
        try {
            Write-EventLog -LogName Application -Source "EC2Config" `
                -EntryType Information -EventId 1003 `
                -Message "Successfully retrieved secret: $SecretId"
        }
        catch {
            Write-Warning "Could not write to event log: $_"
        }
        
        return $secret
    }
    catch {
        $errorMessage = "Failed to retrieve secret '$SecretId' from region '$Region': $_"
        Write-Error $errorMessage
        
        try {
            Write-EventLog -LogName Application -Source "EC2Config" `
                -EntryType Error -EventId 1001 `
                -Message $errorMessage
        }
        catch {
            Write-Warning "Could not write to event log: $_"
        }
        
        throw
    }
}

function Invoke-SafeOperation {
    <#
    .SYNOPSIS
        Executes a script block with comprehensive error handling and logging.
    
    .DESCRIPTION
        Wraps script block execution with try-catch error handling and logs
        operations to Windows Event Log for audit and troubleshooting purposes.
    
    .PARAMETER OperationName
        Descriptive name of the operation being performed.
    
    .PARAMETER ScriptBlock
        The script block to execute.
    
    .OUTPUTS
        Returns the result of the script block execution.
    
    .EXAMPLE
        Invoke-SafeOperation -OperationName "Install Software" -ScriptBlock {
            Install-Package -Name "MyApp"
        }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$OperationName,
        
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock
    )
    
    try {
        Write-Verbose "Starting operation: $OperationName"
        
        try {
            Write-EventLog -LogName Application -Source "EC2Config" `
                -EntryType Information -EventId 1004 `
                -Message "Starting operation: $OperationName"
        }
        catch {
            Write-Warning "Could not write to event log: $_"
        }
        
        $result = & $ScriptBlock
        
        Write-Verbose "Completed operation: $OperationName"
        
        try {
            Write-EventLog -LogName Application -Source "EC2Config" `
                -EntryType Information -EventId 1005 `
                -Message "Completed operation: $OperationName"
        }
        catch {
            Write-Warning "Could not write to event log: $_"
        }
        
        return $result
    }
    catch {
        $errorMessage = "Operation failed: $OperationName - $_"
        Write-Error $errorMessage
        
        try {
            Write-EventLog -LogName Application -Source "EC2Config" `
                -EntryType Error -EventId 1006 `
                -Message $errorMessage
        }
        catch {
            Write-Warning "Could not write to event log: $_"
        }
        
        throw
    }
}

#endregion

#region Main Script

try {
    Write-Output "Starting EC2 Windows instance configuration..."
    
    # Initialize AWS defaults
    Invoke-SafeOperation -OperationName "Initialize AWS Defaults" -ScriptBlock {
        Initialize-AWSDefaults -ErrorAction Stop
    }
    
    # Get IMDSv2 token
    Write-Output "Retrieving IMDSv2 token..."
    $token = Get-IMDSv2Token
    
    # Get instance metadata using IMDSv2
    Write-Output "Retrieving instance metadata..."
    $instanceId = Get-EC2Metadata -Path "instance-id" -Token $token
    $region = Get-EC2Metadata -Path "placement/region" -Token $token
    
    Write-Output "Instance ID: $instanceId"
    Write-Output "Region: $region"
    
    # Get instance details
    Invoke-SafeOperation -OperationName "Get EC2 Instance Details" -ScriptBlock {
        $instance = (Get-EC2Instance -InstanceId $instanceId -Region $region -ErrorAction Stop).Instances[0]
        $instanceName = ($instance.Tags | Where-Object { $_.Key -eq "Name" } | Select-Object -Expand Value)
        
        if ([string]::IsNullOrEmpty($instanceName)) {
            throw "Instance name tag not found"
        }
        
        Write-Output "Instance Name: $instanceName"
        
        # Rename computer
        Write-Output "Renaming computer to: $instanceName"
        Rename-Computer -NewName $instanceName -Force -Confirm:$false -ErrorAction Stop
    }
    
    # Create local admin user with password from Secrets Manager
    Invoke-SafeOperation -OperationName "Create Local Admin User" -ScriptBlock {
        $newLocalAdmin = "ansible"
        $secretId = "ez-lab.xyz/ansible/localadmin"
        
        Write-Output "Retrieving password from Secrets Manager..."
        $password = Get-SecretSafely -SecretId $secretId -Region $region
        
        Write-Output "Creating local user: $newLocalAdmin"
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        
        # Check if user already exists
        $existingUser = Get-LocalUser -Name $newLocalAdmin -ErrorAction SilentlyContinue
        if ($existingUser) {
            Write-Output "User $newLocalAdmin already exists, updating password..."
            Set-LocalUser -Name $newLocalAdmin -Password $securePassword -ErrorAction Stop
        }
        else {
            New-LocalUser -Name $newLocalAdmin -Password $securePassword `
                -FullName $newLocalAdmin `
                -Description "Ansible automation user" `
                -ErrorAction Stop
        }
        
        # Add to Administrators group
        Write-Output "Adding user to Administrators group..."
        $adminGroup = Get-LocalGroup -Name "Administrators" -ErrorAction Stop
        $isMember = Get-LocalGroupMember -Group $adminGroup -ErrorAction SilentlyContinue | 
            Where-Object { $_.Name -like "*$newLocalAdmin" }
        
        if (-not $isMember) {
            Add-LocalGroupMember -Group "Administrators" -Member $newLocalAdmin -ErrorAction Stop
        }
        else {
            Write-Output "User is already a member of Administrators group"
        }
    }
    
    # Configure Ansible remoting
    Invoke-SafeOperation -OperationName "Configure Ansible Remoting" -ScriptBlock {
        Write-Output "Configuring WinRM for Ansible..."
        
        # Set TLS 1.2 for secure downloads
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
        $file = "$env:temp\ConfigureRemotingForAnsible.ps1"
        
        Write-Output "Downloading Ansible configuration script..."
        
        try {
            (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
        }
        catch {
            $errorMessage = "Failed to download ConfigureRemotingForAnsible.ps1: $_"
            Write-Error $errorMessage
            
            try {
                Write-EventLog -LogName Application -Source "EC2Config" `
                    -EntryType Error -EventId 1007 `
                    -Message $errorMessage
            }
            catch {
                Write-Warning "Could not write to event log: $_"
            }
            
            throw
        }
        
        # Verify download succeeded
        if (-not (Test-Path -Path $file)) {
            $errorMessage = "Downloaded file not found at: $file"
            Write-Error $errorMessage
            
            try {
                Write-EventLog -LogName Application -Source "EC2Config" `
                    -EntryType Error -EventId 1008 `
                    -Message $errorMessage
            }
            catch {
                Write-Warning "Could not write to event log: $_"
            }
            
            throw
        }
        
        Write-Output "Executing Ansible configuration script..."
        
        try {
            $output = powershell.exe -ExecutionPolicy ByPass -File $file 2>&1
            $exitCode = $LASTEXITCODE
            
            if ($exitCode -ne 0) {
                throw "Script execution failed with exit code: $exitCode. Output: $output"
            }
            
            Write-Output "Ansible remoting configured successfully"
        }
        catch {
            $errorMessage = "Failed to execute ConfigureRemotingForAnsible.ps1: $_"
            Write-Error $errorMessage
            
            try {
                Write-EventLog -LogName Application -Source "EC2Config" `
                    -EntryType Error -EventId 1009 `
                    -Message $errorMessage
            }
            catch {
                Write-Warning "Could not write to event log: $_"
            }
            
            throw
        }
    }
    
    Write-Output "EC2 Windows instance configuration completed successfully!"
    
    try {
        Write-EventLog -LogName Application -Source "EC2Config" `
            -EntryType Information -EventId 1010 `
            -Message "EC2 Windows instance configuration completed successfully"
    }
    catch {
        Write-Warning "Could not write to event log: $_"
    }
}
catch {
    $errorMessage = "EC2 Windows instance configuration failed: $_"
    Write-Error $errorMessage
    
    try {
        Write-EventLog -LogName Application -Source "EC2Config" `
            -EntryType Error -EventId 1099 `
            -Message $errorMessage
    }
    catch {
        Write-Warning "Could not write to event log: $_"
    }
    
    # Exit with error code
    exit 1
}

#endregion
</powershell>
