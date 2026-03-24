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
dirs=(".openclaw" "workspace" "apps")

# Fix permissions for gateway directories
echo "Fixing permissions for gateway directories..."
for gateway in "${gateways[@]}"; do
    for dir in "${dirs[@]}"; do
        if [ -d "$gateway/$dir" ]; then
            echo "Fixing permissions for $gateway/$dir..."
            chown -R 1000:1000 "$gateway/$dir"
            chmod -R 755 "$gateway/$dir"
        else
            echo "Creating directory $gateway/$dir..."
            mkdir -p "$gateway/$dir"
            chown -R 1000:1000 "$gateway/$dir"
            chmod -R 755 "$gateway/$dir"
        fi
    done
done

# Fix permissions for share directory
echo ""
echo "Fixing permissions for share directory..."
if [ -d "share" ]; then
    echo "Fixing permissions for share..."
    chown -R 1000:1000 "share"
    chmod -R 755 "share"
else
    echo "Creating directory share..."
    mkdir -p "share"
    chown -R 1000:1000 "share"
    chmod -R 755 "share"
fi

# Verify permissions
echo ""
echo "Verifying permissions..."
for gateway in "${gateways[@]}"; do
    for dir in "${dirs[@]}"; do
        if [ -d "$gateway/$dir" ]; then
            echo "$gateway/$dir: $(stat -c "%u:%g" "$gateway/$dir")"
        fi
    done
done

if [ -d "share" ]; then
    echo "share: $(stat -c "%u:%g" "share")"
fi

echo ""
echo "Permission fix completed!"
echo "All directories now have correct permissions for the node user (UID: 1000, GID: 1000)"
