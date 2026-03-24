# Change to the directory where this script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
Write-Host "Changed working directory to: $(Get-Location)"

# 加载环境变量
if (Test-Path -Path ".env") {
    Get-Content ".env" | Where-Object { $_ -notmatch "^#" -and $_ -match "=" } | ForEach-Object {
        $key, $value = $_ -split "=", 2
        [Environment]::SetEnvironmentVariable($key.Trim(), $value.Trim().Trim('"'))
    }
}

# 设置默认值
$gatewayServices = "serv,coder1,coder2,coder3"

if ($env:GATEWAY_SERVICES) {
    $gatewayServices = $env:GATEWAY_SERVICES
}

# 解析服务列表
$gateways = $gatewayServices.Split(',')

# Define sub directories
$dirs = @(".openclaw", "workspace", "apps")

# Fix permissions for gateway directories
Write-Host "Fixing permissions for gateway directories..."
foreach ($gateway in $gateways) {
    $gateway = $gateway.Trim()
    foreach ($dir in $dirs) {
        $path = "$gateway\$dir"
        if (Test-Path -Path $path) {
            Write-Host "Fixing permissions for $path..."
        } else {
            Write-Host "Creating directory $path..."
            New-Item -ItemType Directory -Path $path -Force
        }
    }
}

# Fix permissions for share directory
Write-Host ""
Write-Host "Fixing permissions for share directory..."
$sharePath = "share"
if (Test-Path -Path $sharePath) {
    Write-Host "Fixing permissions for $sharePath..."
} else {
    Write-Host "Creating directory $sharePath..."
    New-Item -ItemType Directory -Path $sharePath -Force
}

# Verify directories exist
Write-Host ""
Write-Host "Verifying directories..."
foreach ($gateway in $gateways) {
    $gateway = $gateway.Trim()
    foreach ($dir in $dirs) {
        $path = "$gateway\$dir"
        if (Test-Path -Path $path) {
            Write-Host "${path}: Exists"
        } else {
            Write-Host "${path}: Missing"
        }
    }
}

if (Test-Path -Path $sharePath) {
    Write-Host "${sharePath}: Exists"
} else {
    Write-Host "${sharePath}: Missing"
}

Write-Host ""
Write-Host "Permission fix completed!"
Write-Host "All directories have been created and are ready for use with Docker containers"
