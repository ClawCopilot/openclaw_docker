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
$gatewayVolumes = ""

if ($env:GATEWAY_SERVICES) {
    $gatewayServices = $env:GATEWAY_SERVICES
}

if ($env:GATEWAY_PORTS) {
    $gatewayPorts = $env:GATEWAY_PORTS
}

if ($env:GATEWAY_VOLUMES) {
    $gatewayVolumes = $env:GATEWAY_VOLUMES
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

# 解析额外 volumes 配置
$volumeMap = @{}
if ($gatewayVolumes) {
    $gatewayVolumes.Split(',') | ForEach-Object {
        $parts = $_.Split(':')
        if ($parts.Length -eq 3) {
            $serviceName = $parts[0].Trim()
            $hostPath = $parts[1].Trim()
            $containerPath = $parts[2].Trim()
            $volumeEntry = "$hostPath`:$containerPath"
            if (-not $volumeMap.ContainsKey($serviceName)) {
                $volumeMap[$serviceName] = @()
            }
            $volumeMap[$serviceName] += $volumeEntry
        }
    }
}

# 构建内容
$lines = @()

# 添加头部
$lines += "# 公共配置锚点"
$lines += "x-base-service:"
$lines += "  &base-service"
$lines += "  build:"
$lines += "    context: ."
$lines += "    args:"
$lines += "      - BASE_IMAGE=`${BASE_IMAGE:-ghcr.m.daocloud.io/openclaw/openclaw:latest}"
$lines += "      - CONTAINER_HOME=`${CONTAINER_HOME:-/home/node}"
$lines += "      - TZ=`${TZ:-Asia/Shanghai}"
$lines += "      - PIP_MIRROR=`${PIP_MIRROR:-tuna}"
$lines += "      - RUST_VERSION=`${RUST_VERSION:-stable}"
$lines += "      - RUSTUP_MIRROR=`${RUSTUP_MIRROR:-tuna}"
$lines += "      - RUST_CRATES_MIRROR=`${RUST_CRATES_MIRROR:-tuna}"
$lines += "      - GO_VERSION=`${GO_VERSION:-1.25.8}"
$lines += "      - GOPROXY_MIRRORS=`${GOPROXY_MIRRORS:-goproxy.cn,goproxy.io,direct}"
$lines += "      - DOCKER_HUB_MIRRORS=`${DOCKER_HUB_MIRRORS:-daocloud,aliyun,tuna}"
$lines += "      - OPENCLAW_VERSION=`${OPENCLAW_VERSION:-latest}"
$lines += "      - INSTALL_DOCKER=`${INSTALL_DOCKER:-false}"
$lines += "      - INSTALL_PODMAN=`${INSTALL_PODMAN:-true}"
$lines += "      - INSTALL_DOCKER_COMPOSE=`${INSTALL_DOCKER_COMPOSE:-false}"
$lines += "      - DOCKER_COMPOSE_VERSION=`${DOCKER_COMPOSE_VERSION:-latest}"
$lines += "      - INSTALL_OLLAMA=`${INSTALL_OLLAMA:-false}"
$lines += "      - OLLAMA_MIRROR=`${OLLAMA_MIRROR:-modelscope}"
$lines += "      - INSTALL_VLLM=`${INSTALL_VLLM:-false}"
$lines += "      - VLLM_MIRROR=`${VLLM_MIRROR:-tuna}"
$lines += "      - INSTALL_UV=`${INSTALL_UV:-false}"
$lines += "      - UV_MIRROR=`${UV_MIRROR:-ghproxy}"
$lines += "  environment:"
$lines += "    - PORT=18789"
$lines += "    - NODE_ENV=`${OPENCLAW_NODE_ENV:-production}"
$lines += "    - npm_config_registry=`${npm_config_registry:-https://registry.npmmirror.com/}"
$lines += "    - pnpm_config_registry=`${pnpm_config_registry:-https://registry.npmmirror.com/}"
$lines += "    - TZ=`${TZ:-Asia/Shanghai}"
$lines += "    - OPENCLAW_VERSION=`${OPENCLAW_VERSION:-latest}"
$lines += "  restart: `${CONTAINER_RESTART_POLICY:-unless-stopped}"
$lines += "  logging:"
$lines += "    driver: json-file"
$lines += "    options:"
$lines += "      max-size: `"`${LOG_MAX_SIZE:-10m}`""
$lines += "      max-file: `"`${LOG_MAX_FILE:-3}`""
$lines += "  healthcheck:"
$lines += "    test: [`"CMD`", `"curl`", `"-f`", `"http://localhost:18789/health`"]"
$lines += "    interval: `${HEALTHCHECK_INTERVAL:-30s}"
$lines += "    timeout: `${HEALTHCHECK_TIMEOUT:-10s}"
$lines += "    start_period: `${HEALTHCHECK_START_PERIOD:-5s}"
$lines += "    retries: `${HEALTHCHECK_RETRIES:-3}"
$lines += "  privileged: true"
$lines += "  network_mode: `${NETWORK_MODE:-bridge}"
$lines += ""
$lines += "# 服务配置"
$lines += "services:"

# 生成网关服务配置
$i = 1
foreach ($serviceName in $services) {
    $serviceName = $serviceName.Trim()
    $containerName = $serviceName
    $gatewayId = $serviceName

    $lines += "  # 网关 $i - $gatewayId"
    $lines += "  $serviceName`:"
    $lines += "    <<: *base-service"
    $lines += "    container_name: $containerName"
    $lines += "    extra_hosts:"
    $lines += "      - `"host.docker.internal:host-gateway`""

    # 添加 deploy.resources（如果设置了 CONTAINER_MEM_LIMIT）
    if ($env:CONTAINER_MEM_LIMIT) {
        $lines += "    deploy:"
        $lines += "      resources:"
        $lines += "        limits:"
        $lines += "          memory: $($env:CONTAINER_MEM_LIMIT)"
    }

    if ($portMap.ContainsKey($gatewayId)) {
        $port = $portMap[$gatewayId]
        $lines += "    ports:"
        $lines += "      - `"$port`:18789`""
    }

    $lines += "    volumes:"
    $lines += "      - ./$gatewayId/supervisor/conf.d:/etc/supervisor/conf.d     # Supervisor config"
    $lines += "      - ./$gatewayId/supervisor/log:/var/log/supervisor          # Supervisor log"
    $lines += "      - ./$gatewayId/.ssh:/home/node/.ssh:U,z                    # Config ssh"
    $lines += "      - ./$gatewayId/.openclaw:/home/node/.openclaw:U,z          # Config and data"
    $lines += "      - ./$gatewayId/workspace:/home/node/workspace:U,z          # Agent workspace"
    $lines += "      - ./$gatewayId/apps:/home/node/apps:U,z                    # Config apps"
    $lines += "      - ./share:/home/node/share:U,z                              # Config share"

    # 添加额外 volumes（如果存在）
    if ($volumeMap.ContainsKey($gatewayId)) {
        foreach ($vol in $volumeMap[$gatewayId]) {
            $volParts = $vol -split ':'
            if ($volParts.Length -eq 2) {
                $lines += "      - $($volParts[0]):$($volParts[1]):U,z"
            }
        }
    }

    $lines += "    environment:"
    $lines += "      - GATEWAY_ID=$gatewayId"
    $lines += ""

    $i++
}

# 使用 UTF-8 without BOM 编码写入文件
$content = $lines -join "`n"
$content += "`n"
$utf8 = [System.Text.Encoding]::UTF8
$bytes = $utf8.GetBytes($content)
[System.IO.File]::WriteAllBytes(".\docker-compose.yml", $bytes)

Write-Host "Generated docker-compose.yml with $($services.Length) gateways"
