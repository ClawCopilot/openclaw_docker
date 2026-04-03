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
$gateways = $gatewayServices.Split(',') | ForEach-Object { $_.Trim() }

# Create gateway directories
foreach ($gateway in $gateways) {
    New-Item -ItemType Directory -Path "$gateway\supervisor\conf.d" -Force
    New-Item -ItemType Directory -Path "$gateway\supervisor\log" -Force
    New-Item -ItemType Directory -Path "$gateway\.ssh" -Force
    New-Item -ItemType Directory -Path "$gateway\.openclaw" -Force
    New-Item -ItemType Directory -Path "$gateway\workspace" -Force
    New-Item -ItemType Directory -Path "$gateway\apps" -Force
}

# Create between gateway share directories
New-Item -ItemType Directory -Path "share" -Force

# Build and start Docker containers
docker-compose up -d --build

# Show deployment info
Write-Host "OpenClaw multi-gateway deployment completed!"
Write-Host ""
Write-Host "Configured gateways: $($gateways -join ', ')"
Write-Host ""
Write-Host "Access addresses (if port mapping configured):"
foreach ($gateway in $gateways) {
    Write-Host "  - $gateway"
}
Write-Host ""
Write-Host "Waiting 15 seconds for containers to start..."
Start-Sleep -Seconds 15
Write-Host "Check container status: docker-compose ps"
docker-compose ps
Write-Host "Check container logs: docker-compose logs -f"
docker-compose logs -f
