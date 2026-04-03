#!/bin/bash

# Change to the directory where this script is located
cd "$(dirname "$0")"
echo "Changed working directory to: $(pwd)"

# 加载环境变量
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | xargs)
fi

# 设置默认值
GATEWAY_SERVICES=${GATEWAY_SERVICES:-serv,coder1,coder2,coder3}

# 解析服务列表
IFS=',' read -ra gateways <<< "$GATEWAY_SERVICES"

# 定义子目录
dirs=("supervisor/conf.d",".openclaw" "workspace" "apps")

# Create gateway directories
for gateway in "${gateways[@]}"; do
    for dir in "${dirs[@]}"; do
        mkdir -p "$gateway/$dir"
        chown -R 1000:1000 "$gateway/$dir"
    done
done

# Create between gateway share directories
mkdir -p "share"
chown -R 1000:1000 "share"

# Build and start Docker containers
docker-compose up -d --build

# Show deployment info
echo "OpenClaw multi-gateway deployment completed!"
echo ""
echo "Configured gateways: ${gateways[*]}"
echo ""
echo "Access addresses (if port mapping configured):"
for gateway in "${gateways[@]}"; do
    echo "  - $gateway"
done
echo ""
echo "Waiting 15 seconds for containers to start..."
sleep 15

echo "Check container status: docker-compose ps"
docker-compose ps

echo "Check container logs: docker-compose logs -f"
docker-compose logs -f
