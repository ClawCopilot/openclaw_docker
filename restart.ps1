param(
    [string]$ContainerName = "all"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
Write-Host "Changed working directory to: $(Get-Location)"

if (Test-Path -Path ".env") {
    Get-Content ".env" | Where-Object { $_ -notmatch "^#" -and $_ -match "=" } | ForEach-Object {
        $key, $value = $_ -split "=", 2
        [Environment]::SetEnvironmentVariable($key.Trim(), $value.Trim().Trim('"'))
    }
}

$gatewayServices = "serv,coder1,coder2,coder3"

if ($env:GATEWAY_SERVICES) {
    $gatewayServices = $env:GATEWAY_SERVICES
}

$ValidContainers = $gatewayServices.Split(',') | ForEach-Object { $_.Trim() }

if ($ContainerName -ne "all" -and $ValidContainers -notcontains $ContainerName) {
    Write-Host "Error: Invalid container name. Valid containers are: all, $($ValidContainers -join ', ')"
    exit 1
}

if ($ContainerName -eq "all") {
    Write-Host "Restarting all OpenClaw containers..."
    docker-compose restart
} else {
    Write-Host "Restarting container: ${ContainerName}..."
    docker-compose restart $ContainerName
}

Write-Host ""
Write-Host "Container status:"
docker-compose ps

Write-Host ""
Write-Host "Done."
