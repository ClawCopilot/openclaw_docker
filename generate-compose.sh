#!/bin/bash

# 切换到脚本所在目录
cd "$(dirname "$0")"

# 加载环境变量
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | xargs)
fi

# 设置默认值
GATEWAY_SERVICES=${GATEWAY_SERVICES:-serv,coder1,coder2,coder3}
GATEWAY_PORTS=${GATEWAY_PORTS:-}
GATEWAY_VOLUMES=${GATEWAY_VOLUMES:-}

# 解析服务列表
IFS=',' read -ra services <<< "$GATEWAY_SERVICES"

# 解析端口配置
declare -A port_map
IFS=',' read -ra ports <<< "$GATEWAY_PORTS"
for port in "${ports[@]}"; do
  IFS=':' read -ra parts <<< "$port"
  if [ ${#parts[@]} -eq 2 ]; then
    port_map[${parts[0]}]=${parts[1]}
  fi
done

# 解析额外 volumes 配置
declare -A volume_map
IFS=',' read -ra volumes <<< "$GATEWAY_VOLUMES"
for volume in "${volumes[@]}"; do
  IFS=':' read -ra parts <<< "$volume"
  if [ ${#parts[@]} -eq 3 ]; then
    service="${parts[0]}"
    host_path="${parts[1]}"
    container_path="${parts[2]}"
    if [ -z "${volume_map[$service]}" ]; then
      volume_map[$service]="$host_path:$container_path"
    else
      volume_map[$service]="${volume_map[$service]},$host_path:$container_path"
    fi
  fi
done

# 生成 docker-compose.yml
cat > docker-compose.yml << 'EOF'
# 公共配置锚点
x-base-service:
  &base-service
  build:
    context: .
    args:
      - BASE_IMAGE=${BASE_IMAGE:-ghcr.m.daocloud.io/openclaw/openclaw:latest}
      - CONTAINER_HOME=${CONTAINER_HOME:-/home/node}
      - TZ=${TZ:-Asia/Shanghai}
      - PIP_MIRROR=${PIP_MIRROR:-tuna}
      - RUST_VERSION=${RUST_VERSION:-stable}
      - RUSTUP_MIRROR=${RUSTUP_MIRROR:-tuna}
      - RUST_CRATES_MIRROR=${RUST_CRATES_MIRROR:-tuna}
      - GO_VERSION=${GO_VERSION:-1.25.8}
      - GOPROXY_MIRRORS=${GOPROXY_MIRRORS:-goproxy.cn,goproxy.io,direct}
      - DOCKER_HUB_MIRRORS=${DOCKER_HUB_MIRRORS:-daocloud,aliyun,tuna}
      - OPENCLAW_VERSION=${OPENCLAW_VERSION:-latest}
      - INSTALL_DOCKER=${INSTALL_DOCKER:-false}
      - INSTALL_PODMAN=${INSTALL_PODMAN:-true}
      - INSTALL_DOCKER_COMPOSE=${INSTALL_DOCKER_COMPOSE:-false}
      - DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-latest}
  environment:
    - PORT=18789
    - NODE_ENV=${OPENCLAW_NODE_ENV:-production}
    - npm_config_registry=${npm_config_registry:-https://registry.npmmirror.com/}
    - pnpm_config_registry=${pnpm_config_registry:-https://registry.npmmirror.com/}
    - TZ=${TZ:-Asia/Shanghai}
    - OPENCLAW_VERSION=${OPENCLAW_VERSION:-latest}
  restart: ${CONTAINER_RESTART_POLICY:-unless-stopped}
  logging:
    driver: json-file
    options:
      max-size: "${LOG_MAX_SIZE:-10m}"
      max-file: "${LOG_MAX_FILE:-3}"
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:18789/health"]
    interval: ${HEALTHCHECK_INTERVAL:-30s}
    timeout: ${HEALTHCHECK_TIMEOUT:-10s}
    start_period: ${HEALTHCHECK_START_PERIOD:-5s}
    retries: ${HEALTHCHECK_RETRIES:-3}
  privileged: true
  network_mode: ${NETWORK_MODE:-bridge}

# 服务配置
services:
EOF

# 生成网关服务配置
i=1
for service_name in "${services[@]}"; do
  container_name="$service_name"
  gateway_id="$service_name"

  # 检查是否需要端口映射
  if [[ ${port_map[$gateway_id]+_} ]]; then
    ports="- \"${port_map[$gateway_id]}:18789\""
  else
    ports=""
  fi

  cat >> docker-compose.yml << EOF
  # 网关 $i - $gateway_id
  $service_name:
    <<: *base-service
    container_name: $container_name
    extra_hosts:
      - "host.docker.internal:host-gateway"
EOF

  # 添加 deploy.resources（如果设置了 CONTAINER_MEM_LIMIT）
  if [ -n "$CONTAINER_MEM_LIMIT" ]; then
    cat >> docker-compose.yml << EOF
    deploy:
      resources:
        limits:
          memory: $CONTAINER_MEM_LIMIT
EOF
  fi

  if [ -n "$ports" ]; then
    cat >> docker-compose.yml << EOF
    ports:
      $ports
EOF
  fi

  # 添加固定 volumes
  cat >> docker-compose.yml << EOF
    volumes:
      - ./$gateway_id/supervisor/conf.d:/etc/supervisor/conf.d     # Supervisor config
      - ./$gateway_id/.openclaw:/home/node/.openclaw:U,z          # Config and data
      - ./$gateway_id/workspace:/home/node/workspace:U,z          # Agent workspace
      - ./$gateway_id/apps:/home/node/apps:U,z                    # Config apps
      - ./share:/home/node/share:U,z                              # Config share
EOF

  # 添加额外 volumes（如果存在）
  if [[ ${volume_map[$gateway_id]+_} ]]; then
    IFS=',' read -ra extra_volumes <<< "${volume_map[$gateway_id]}"
    for extra_vol in "${extra_volumes[@]}"; do
      IFS=':' read -ra vol_parts <<< "$extra_vol"
      if [ ${#vol_parts[@]} -eq 2 ]; then
        echo "      - ${vol_parts[0]}:${vol_parts[1]}:U,z" >> docker-compose.yml
      fi
    done
  fi

  cat >> docker-compose.yml << EOF
    environment:
      - GATEWAY_ID=$gateway_id
EOF

  cat >> docker-compose.yml << EOF

EOF
  i=$((i+1))
done

echo "Generated docker-compose.yml with ${#services[@]} gateways"
