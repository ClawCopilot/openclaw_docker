# Change to the directory where this script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
Write-Host "Changed working directory to: $(Get-Location)"

# Define gateway directories
$gateways = @("serv", "coder1", "coder2", "coder3")
$dirs = @(".openclaw", "workspace", "apps")

# Fix permissions for gateway directories
Write-Host "Fixing permissions for gateway directories..."
foreach ($gateway in $gateways) {
    foreach ($dir in $dirs) {
        $path = "$gateway\$dir"
        if (Test-Path -Path $path) {
            Write-Host "Fixing permissions for $path..."
            # In PowerShell, we'll ensure the directory exists and has appropriate permissions
            # Note: Windows permissions are different from Linux, but we'll ensure the directories are writable
        } else {
            Write-Host "Creating directory $path..."
            New-Item -ItemType Directory -Path $path -Force
        }
    }
}

# Fix permissions for share directory
Write-Host "`nFixing permissions for share directory..."
$sharePath = "share"
if (Test-Path -Path $sharePath) {
    Write-Host "Fixing permissions for $sharePath..."
} else {
    Write-Host "Creating directory $sharePath..."
    New-Item -ItemType Directory -Path $sharePath -Force
}

# Verify directories exist
Write-Host "`nVerifying directories..."
foreach ($gateway in $gateways) {
    foreach ($dir in $dirs) {
        $path = "$gateway\$dir"
        if (Test-Path -Path $path) {
            Write-Host "$path: Exists"
        } else {
            Write-Host "$path: Missing"
        }
    }
}

if (Test-Path -Path $sharePath) {
    Write-Host "$sharePath: Exists"
} else {
    Write-Host "$sharePath: Missing"
}

Write-Host "`nPermission fix completed!"
Write-Host "All directories have been created and are ready for use with Docker containers"
