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
IFS=',' read -ra valid_containers <<< "$GATEWAY_SERVICES"

# 检查参数
if [ $# -eq 0 ]; then
    container_name="all"
elif [ $# -eq 1 ]; then
    container_name="$1"
else
    echo "Error: Too many arguments"
    echo "Usage: $0 [container_name]"
    echo "Valid container names: all, ${valid_containers[*]}"
    exit 1
fi

# 检查容器名称是否有效
if [ "$container_name" != "all" ]; then
    valid=false
    for c in "${valid_containers[@]}"; do
        if [ "$c" == "$container_name" ]; then
            valid=true
            break
        fi
    done
    if [ "$valid" == "false" ]; then
        echo "Error: Invalid container name"
        echo "Valid container names: all, ${valid_containers[*]}"
        exit 1
    fi
fi

# 重启容器
if [ "$container_name" == "all" ]; then
    echo "Restarting all OpenClaw containers..."
    docker-compose restart
else
    echo "Restarting container: $container_name..."
    docker-compose restart $container_name
fi

# 显示状态
echo ""
echo "Container status:"
docker-compose ps

echo ""
echo "Done."
