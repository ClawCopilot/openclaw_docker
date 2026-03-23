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

# 生成 docker-compose.yml
cat > docker-compose.yml << EOF
# 公共配置锚点
x-base-service:
  &base-service
  build: .
  environment:
    - PORT=18789
    - NODE_ENV=\${OPENCLAW_NODE_ENV:-production}
    - npm_config_registry=\${npm_config_registry:-https://registry.npmmirror.com/}
    - pnpm_config_registry=\${pnpm_config_registry:-https://registry.npmmirror.com/}
    - TZ=\${TZ:-Asia/Shanghai}
  restart: \${CONTAINER_RESTART_POLICY:-unless-stopped}
  mem_limit: \${CONTAINER_MEM_LIMIT:-2g}
  logging:
    driver: json-file
    options:
      max-size: "\${LOG_MAX_SIZE:-10m}"
      max-file: "\${LOG_MAX_FILE:-3}"
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:18789/health"]
    interval: \${HEALTHCHECK_INTERVAL:-30s}
    timeout: \${HEALTHCHECK_TIMEOUT:-10s}
    start_period: \${HEALTHCHECK_START_PERIOD:-5s}
    retries: \${HEALTHCHECK_RETRIES:-3}
  privileged: true
  network_mode: \${NETWORK_MODE:-bridge}

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
EOF

  if [ -n "$ports" ]; then
    cat >> docker-compose.yml << EOF
    ports:
      $ports
EOF
  fi

  cat >> docker-compose.yml << EOF
    volumes:
      - ./$gateway_id/.openclaw:/home/node/.openclaw:U,z          # Config and data
      - ./$gateway_id/workspace:/home/node/workspace:U,z          # Agent workspace
      - ./$gateway_id/apps:/home/node/apps:U,z                    # Config apps
      - ./share:/home/node/share:U,z                             # Config share
    environment:
      - GATEWAY_ID=$gateway_id
EOF



  cat >> docker-compose.yml << EOF

EOF
  i=$((i+1))
done

echo "Generated docker-compose.yml with ${#services[@]} gateways"
