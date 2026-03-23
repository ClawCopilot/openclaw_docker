# 切换到脚本所在目录
$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $scriptDir) {
    $scriptDir = Get-Location
}
Set-Location -Path $scriptDir

# 加载环境变量
if (Test-Path -Path ".env") {
    Get-Content ".env" | Where-Object { $_ -notmatch "^#" -and $_ -match "=" } | ForEach-Object {
        $key, $value = $_ -split "=", 2
        [Environment]::SetEnvironmentVariable($key.Trim(), $value.Trim().Trim('"'))
    }
}

# 设置默认值
$gatewayServices = "serv,coder1,coder2,coder3"
$gatewayPorts = ""

if ($env:GATEWAY_SERVICES) {
    $gatewayServices = $env:GATEWAY_SERVICES
}

if ($env:GATEWAY_PORTS) {
    $gatewayPorts = $env:GATEWAY_PORTS
}

# 解析服务列表
$services = $gatewayServices.Split(',')

# 解析端口配置
$portMap = @{}
if ($gatewayPorts) {
    $gatewayPorts.Split(',') | ForEach-Object {
        $parts = $_.Split(':')
        if ($parts.Length -eq 2) {
            $portMap[$parts[0].Trim()] = $parts[1].Trim()
        }
    }
}

# 使用 .NET UTF8Encoding 获取正确的中文字符串
$utf8Encoding = New-Object System.Text.UTF8Encoding $true
$textPublicConfig = $utf8Encoding.GetString([byte[]](0xE5, 0x85, 0xAC, 0xE5, 0x85, 0xB1, 0xE9, 0x85, 0x8D, 0xE7, 0xBD, 0xAE, 0xE9, 0x94, 0x9A, 0xE7, 0x82, 0xB9))
$textServiceConfig = $utf8Encoding.GetString([byte[]](0xE6, 0x9C, 0x8D, 0xE5, 0x8A, 0xA1, 0xE9, 0x85, 0x8D, 0xE7, 0xBD, 0xAE))
$textGateway = $utf8Encoding.GetString([byte[]](0xE7, 0xBD, 0x91, 0xE5, 0x85, 0xB3))

# 构建内容
$lines = @()

# 添加头部
$lines += "# $textPublicConfig"
$lines += "x-base-service:"
$lines += "  &base-service"
$lines += "  build: ."
$lines += "  environment:"
$lines += "    - PORT=18789"
$lines += '    - NODE_ENV=${OPENCLAW_NODE_ENV:-production}'
$lines += '    - npm_config_registry=${npm_config_registry:-https://registry.npmmirror.com/}'
$lines += '    - pnpm_config_registry=${pnpm_config_registry:-https://registry.npmmirror.com/}'
$lines += '    - TZ=${TZ:-Asia/Shanghai}'
$lines += '  restart: ${CONTAINER_RESTART_POLICY:-unless-stopped}'
$lines += '  mem_limit: ${CONTAINER_MEM_LIMIT:-2g}'
$lines += "  logging:"
$lines += "    driver: json-file"
$lines += "    options:"
$lines += '      max-size: "${LOG_MAX_SIZE:-10m}"'
$lines += '      max-file: "${LOG_MAX_FILE:-3}"'
$lines += "  healthcheck:"
$lines += '    test: ["CMD", "curl", "-f", "http://localhost:18789/health"]'
$lines += '    interval: ${HEALTHCHECK_INTERVAL:-30s}'
$lines += '    timeout: ${HEALTHCHECK_TIMEOUT:-10s}'
$lines += '    start_period: ${HEALTHCHECK_START_PERIOD:-5s}'
$lines += '    retries: ${HEALTHCHECK_RETRIES:-3}'
$lines += "  privileged: true"
$lines += '  network_mode: ${NETWORK_MODE:-bridge}'
$lines += ""
$lines += "# $textServiceConfig"
$lines += "services:"

# 生成网关服务配置
$i = 1
foreach ($serviceName in $services) {
    $serviceName = $serviceName.Trim()
    $containerName = $serviceName
    $gatewayId = $serviceName

    $lines += ""
    $lines += "  # $textGateway $i - $gatewayId"
    $lines += "  $serviceName`:"

    if ($portMap.ContainsKey($gatewayId)) {
        $port = $portMap[$gatewayId]
        $lines += "    ports:"
        $lines += "      - `"$port`:18789`""
    }

    $lines += "    volumes:"
    $lines += "      - ./$gatewayId/.openclaw:/home/node/.openclaw:U,z          # Config and data"
    $lines += "      - ./$gatewayId/workspace:/home/node/workspace:U,z          # Agent workspace"
    $lines += "      - ./$gatewayId/apps:/home/node/apps:U,z                    # Config apps"
    $lines += "      - ./share:/home/node/share:U,z                             # Config share"
    $lines += "    environment:"
    $lines += "      - GATEWAY_ID=$gatewayId"

    $i++
}

# 使用 UTF-8 without BOM 编码写入文件
$content = $lines -join "`n"
$utf8 = [System.Text.Encoding]::UTF8
$bytes = $utf8.GetBytes($content)
[System.IO.File]::WriteAllBytes(".\docker-compose.yml", $bytes)

Write-Host "Generated docker-compose.yml with $($services.Length) gateways"
