# Change to the directory where this script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
Write-Host "Changed working directory to: $(Get-Location)"

# Create gateway directories
$gateways = @("serv", "coder1", "coder2", "coder3")
foreach ($gateway in $gateways) {
    New-Item -ItemType Directory -Path "$gateway\.openclaw" -Force
    New-Item -ItemType Directory -Path "$gateway\workspace" -Force
    New-Item -ItemType Directory -Path "$gateway\apps" -Force
}

# Create between gateway share directories
New-Item -ItemType Directory -Path "share" -Force

# Build and start Docker containers
docker-compose up -d --build

# Show deployment info
$servPort = if (Test-Path ".env") { (Get-Content ".env" | Where-Object { $_ -match "^SERV_PORT=" } | ForEach-Object { $_.Split("=")[1] }) } else { "42700" }
Write-Host "OpenClaw multi-gateway deployment completed!"
Write-Host ""
Write-Host "Access addresses:"
Write-Host "Serv: http://localhost:$servPort"
Write-Host "Coder1: No external port mapping"
Write-Host "Coder2: No external port mapping"
Write-Host "Coder3: No external port mapping"
Write-Host ""
Write-Host "Waiting 15 seconds for containers to start..."
Start-Sleep -Seconds 15
Write-Host "Check container status: docker-compose ps"
docker-compose ps
Write-Host "Check container logs: docker-compose logs -f"
docker-compose logs -f
