## PowerShell Core Best Practices

### Cross-Platform Compatibility

**PowerShell Core (7+) Considerations**

- PowerShell Core runs on Windows, Linux, and macOS
- Use cross-platform cmdlets and avoid Windows-specific dependencies when possible
- Test scripts on target platforms to ensure compatibility
- Be aware of path separator differences (`\` on Windows, `/` on Unix-like systems)

**Platform Detection**

```powershell
# Check operating system
if ($IsWindows) {
    # Windows-specific code
} elseif ($IsLinux) {
    # Linux-specific code
} elseif ($IsMacOS) {
    # macOS-specific code
}

# Use platform-agnostic paths
$configPath = Join-Path $HOME ".config" "myapp"
```

### Module Structure and Design

**Standard Module Layout**

```
MyModule/
├── MyModule.psd1          # Module manifest
├── MyModule.psm1          # Root module script
├── Public/                # Exported functions
│   ├── Get-Something.ps1
│   └── Set-Something.ps1
├── Private/               # Internal functions
│   └── Helper.ps1
├── Classes/               # PowerShell classes (optional)
├── en-US/                 # Help files
│   └── about_MyModule.help.txt
└── Tests/                 # Pester tests
    └── MyModule.Tests.ps1
```

**Module Manifest Best Practices**

```powershell
# MyModule.psd1
@{
    ModuleVersion = '1.0.0'
    GUID = 'unique-guid-here'
    Author = 'Your Name'
    Description = 'Module description'
    
    # Minimum PowerShell version
    PowerShellVersion = '7.0'
    
    # Explicitly list exported functions (recommended)
    FunctionsToExport = @('Get-Something', 'Set-Something')
    
    # Don't export everything with wildcards in production
    # FunctionsToExport = '*'  # Avoid this
    
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    
    # Required modules
    RequiredModules = @('Microsoft.PowerShell.Management')
    
    # Private data
    PrivateData = @{
        PSData = @{
            Tags = @('automation', 'utility')
            LicenseUri = 'https://github.com/user/repo/blob/main/LICENSE'
            ProjectUri = 'https://github.com/user/repo'
        }
    }
}
```

**Loading Module Functions**

```powershell
# In MyModule.psm1 - dot source all public functions
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

# Export only public functions
Export-ModuleMember -Function $Public.BaseName
```

### Function Design

**Advanced Function Template**

```powershell
function Verb-Noun {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Description of parameter"
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,
        
        [Parameter()]
        [ValidateSet('Start', 'Stop', 'Restart')]
        [string]$Action = 'Start',
        
        [Parameter()]
        [ValidateRange(1, 100)]
        [int]$Timeout = 30
    )
    
    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        # Initialization code
    }
    
    process {
        foreach ($Computer in $ComputerName) {
            if ($PSCmdlet.ShouldProcess($Computer, $Action)) {
                try {
                    # Main logic here
                    Write-Verbose "Processing $Computer"
                }
                catch {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
    }
    
    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
        # Cleanup code
    }
}
```

**Parameter Validation**

```powershell
# Built-in validation attributes
[ValidateNotNull()]
[ValidateNotNullOrEmpty()]
[ValidateCount(1, 5)]
[ValidateLength(1, 10)]
[ValidateRange(0, 100)]
[ValidateSet('Low', 'Medium', 'High')]
[ValidatePattern('^[A-Z]{3}-\d{4}$')]
[ValidateScript({ Test-Path $_ })]

# Custom validation
[ValidateScript({
    if (Test-Path $_) {
        $true
    } else {
        throw "Path $_ does not exist"
    }
})]
```

### Error Handling

**Comprehensive Error Handling**

```powershell
function Get-DataSafely {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    try {
        # Use -ErrorAction Stop to convert non-terminating to terminating
        $data = Get-Content -Path $Path -ErrorAction Stop
        
        # Process data
        return $data
    }
    catch [System.IO.FileNotFoundException] {
        # Handle specific exception type
        Write-Error "File not found: $Path"
        return $null
    }
    catch [System.UnauthorizedAccessException] {
        Write-Error "Access denied: $Path"
        return $null
    }
    catch {
        # Generic catch for all other errors
        Write-Error "Unexpected error: $_"
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
    finally {
        # Cleanup code that always runs
        Write-Verbose "Cleanup completed"
    }
}
```

**Using $PSCmdlet for Better Error Handling**

```powershell
function Invoke-SafeOperation {
    [CmdletBinding()]
    param()
    
    process {
        try {
            # Your code here
        }
        catch {
            # Use $PSCmdlet.ThrowTerminatingError for cleaner output
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
```

**Error Action Preferences**

```powershell
# Control error behavior
$ErrorActionPreference = 'Stop'        # Treat all errors as terminating
$ErrorActionPreference = 'Continue'    # Display error and continue (default)
$ErrorActionPreference = 'SilentlyContinue'  # Suppress errors
$ErrorActionPreference = 'Inquire'     # Prompt user
$ErrorActionPreference = 'Ignore'      # Completely ignore errors

# Per-command error action
Get-Item /nonexistent -ErrorAction SilentlyContinue
```

### Output and Formatting

**Proper Output Methods**

```powershell
# Use Write-Output for pipeline output (or just output directly)
Write-Output $result
$result  # Implicit output

# Use Write-Verbose for detailed information
Write-Verbose "Processing item $i of $total"

# Use Write-Warning for warnings
Write-Warning "This operation may take a long time"

# Use Write-Error for errors
Write-Error "Failed to process item"

# Use Write-Debug for debugging information
Write-Debug "Variable value: $myVar"

# Use Write-Information for informational messages (PS 5.0+)
Write-Information "Operation completed successfully" -InformationAction Continue

# AVOID Write-Host except for user interaction
# Write-Host "This bypasses the pipeline"  # Use sparingly
```

**Creating Custom Objects**

```powershell
# Use [PSCustomObject] for better performance
$result = [PSCustomObject]@{
    ComputerName = $Computer
    Status = 'Online'
    LastCheck = Get-Date
    IPAddress = '192.168.1.1'
}

# Add type name for formatting
$result.PSObject.TypeNames.Insert(0, 'MyModule.ComputerStatus')

# Output to pipeline
$result
```

### Performance Optimization

**Efficient Collection Handling**

```powershell
# AVOID += for large collections (creates new array each time)
$results = @()
foreach ($item in $items) {
    $results += Process-Item $item  # Slow for large datasets
}

# BETTER: Use ArrayList or Generic List
$results = [System.Collections.ArrayList]::new()
foreach ($item in $items) {
    [void]$results.Add((Process-Item $item))
}

# BEST: Use pipeline or collect at end
$results = foreach ($item in $items) {
    Process-Item $item
}

# Or with pipeline
$results = $items | ForEach-Object { Process-Item $_ }
```

**String Building**

```powershell
# AVOID string concatenation in loops
$output = ""
foreach ($item in $items) {
    $output += "$item`n"  # Slow
}

# BETTER: Use StringBuilder
$sb = [System.Text.StringBuilder]::new()
foreach ($item in $items) {
    [void]$sb.AppendLine($item)
}
$output = $sb.ToString()

# BEST: Use -join
$output = $items -join "`n"
```

**Filtering and Where-Object**

```powershell
# Use .Where() method for better performance (PS 4.0+)
$filtered = $collection.Where({ $_.Status -eq 'Active' })

# Traditional Where-Object (slower for large collections)
$filtered = $collection | Where-Object { $_.Status -eq 'Active' }

# Use ForEach method instead of ForEach-Object for performance
$results = $collection.ForEach({ $_.Name })
```

### Security Best Practices

**Credential Handling**

```powershell
# Accept PSCredential parameter
function Connect-Service {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCredential]$Credential
    )
    
    # Use credential securely
    $username = $Credential.UserName
    $password = $Credential.GetNetworkCredential().Password
}

# Prompt for credentials
$cred = Get-Credential -Message "Enter service credentials"

# Store credentials securely (Windows only)
$cred | Export-Clixml -Path "$env:USERPROFILE\cred.xml"
$cred = Import-Clixml -Path "$env:USERPROFILE\cred.xml"
```

**Secrets Management**

```powershell
# Use SecretManagement module (cross-platform)
Install-Module Microsoft.PowerShell.SecretManagement
Install-Module Microsoft.PowerShell.SecretStore

# Register vault
Register-SecretVault -Name LocalStore -ModuleName Microsoft.PowerShell.SecretStore

# Store secret
Set-Secret -Name 'APIKey' -Secret 'your-secret-value'

# Retrieve secret
$apiKey = Get-Secret -Name 'APIKey' -AsPlainText
```

**Input Validation and Sanitization**

```powershell
# Validate and sanitize user input
function Invoke-SafeCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9_-]+$')]
        [string]$Name
    )
    
    # Additional validation
    if ($Name -match '[;&|]') {
        throw "Invalid characters in name"
    }
    
    # Use parameterized commands, avoid string concatenation
    Invoke-Expression is dangerous - avoid it
}
```

### Testing with Pester

**Basic Pester Test Structure**

```powershell
# MyModule.Tests.ps1
BeforeAll {
    Import-Module "$PSScriptRoot/../MyModule.psd1" -Force
}

Describe 'Get-Something' {
    Context 'When valid input is provided' {
        It 'Returns expected result' {
            $result = Get-Something -Name 'Test'
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be 'Test'
        }
    }
    
    Context 'When invalid input is provided' {
        It 'Throws an error' {
            { Get-Something -Name '' } | Should -Throw
        }
    }
}

Describe 'Module Manifest' {
    It 'Has a valid manifest' {
        Test-ModuleManifest "$PSScriptRoot/../MyModule.psd1" | Should -Not -BeNullOrEmpty
    }
}
```

**Mocking Dependencies**

```powershell
Describe 'Function with dependencies' {
    BeforeAll {
        Mock Get-Service { 
            [PSCustomObject]@{ Name = 'TestService'; Status = 'Running' }
        }
    }
    
    It 'Calls Get-Service' {
        Get-MyServiceStatus
        Should -Invoke Get-Service -Times 1
    }
}
```

### Common Patterns

**Splatting Parameters**

```powershell
# Use splatting for readability
$params = @{
    ComputerName = 'Server01'
    Credential = $cred
    ErrorAction = 'Stop'
    Verbose = $true
}
Invoke-Command @params -ScriptBlock { Get-Process }
```

**Pipeline Processing**

```powershell
function Process-Items {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$InputObject
    )
    
    begin {
        $count = 0
    }
    
    process {
        $count++
        # Process each pipeline item
        [PSCustomObject]@{
            Item = $InputObject
            Index = $count
        }
    }
    
    end {
        Write-Verbose "Processed $count items"
    }
}

# Usage
'Item1', 'Item2', 'Item3' | Process-Items
```

**Using -WhatIf and -Confirm**

```powershell
function Remove-CustomItem {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    if ($PSCmdlet.ShouldProcess($Path, 'Remove item')) {
        Remove-Item -Path $Path -Force
    }
}

# Usage
Remove-CustomItem -Path 'C:\temp\file.txt' -WhatIf
Remove-CustomItem -Path 'C:\temp\file.txt' -Confirm
```

### Windows-Specific Considerations

**WinRM and Remote Management**

```powershell
# Configure WinRM (run as administrator)
Enable-PSRemoting -Force

# Create remote session
$session = New-PSSession -ComputerName 'Server01' -Credential $cred

# Execute commands remotely
Invoke-Command -Session $session -ScriptBlock {
    Get-Service | Where-Object Status -eq 'Running'
}

# Copy files to/from remote session
Copy-Item -Path 'C:\local\file.txt' -Destination 'C:\remote\' -ToSession $session

# Clean up
Remove-PSSession $session
```

**Working with Windows Features**

```powershell
# Check if running on Windows
if ($IsWindows) {
    # Install Windows feature
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools
    
    # Manage services
    Get-Service -Name 'W3SVC' | Start-Service
    
    # Registry operations
    Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion'
}
```

### Documentation

**Comment-Based Help**

```powershell
function Get-Something {
    <#
    .SYNOPSIS
        Brief description of the function.
    
    .DESCRIPTION
        Detailed description of what the function does.
    
    .PARAMETER Name
        Description of the Name parameter.
    
    .PARAMETER Path
        Description of the Path parameter.
    
    .EXAMPLE
        Get-Something -Name 'Test'
        
        Description of what this example does.
    
    .EXAMPLE
        Get-Something -Name 'Test' -Path 'C:\Temp'
        
        Description of this example with multiple parameters.
    
    .INPUTS
        System.String
        You can pipe strings to this function.
    
    .OUTPUTS
        System.Management.Automation.PSCustomObject
        Returns custom objects with properties.
    
    .NOTES
        Author: Your Name
        Version: 1.0.0
        Last Modified: 2024-01-01
    
    .LINK
        https://github.com/user/repo
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter()]
        [string]$Path
    )
    
    # Function implementation
}
```

### Debugging

**Debugging Techniques**

```powershell
# Set breakpoints
Set-PSBreakpoint -Script .\MyScript.ps1 -Line 10
Set-PSBreakpoint -Command Get-Process

# Debug mode
Set-PSDebug -Trace 1  # Trace script execution
Set-PSDebug -Trace 2  # Trace with variable assignments
Set-PSDebug -Off      # Turn off tracing

# Use Write-Debug
Write-Debug "Variable value: $myVar"  # Only shows with -Debug parameter

# Verbose output
Write-Verbose "Processing item $i"  # Only shows with -Verbose parameter

# Use $PSCmdlet.WriteDebug in advanced functions
$PSCmdlet.WriteDebug("Debug message")
```

### Version Compatibility

**Checking PowerShell Version**

```powershell
# Check version
$PSVersionTable.PSVersion

# Require minimum version in script
#Requires -Version 7.0

# Conditional code based on version
if ($PSVersionTable.PSVersion.Major -ge 7) {
    # PowerShell 7+ specific code
} else {
    # Fallback for older versions
}
```
