#!/bin/bash

# 定义支持的容器名称
valid_containers=("serv" "coder1" "coder2" "coder3")

# 检查参数
if [ $# -eq 0 ]; then
    container_name="all"
elif [ $# -eq 1 ]; then
    container_name="$1"
else
    echo "Error: Too many arguments"
    echo "Usage: $0 [container_name]"
    echo "Valid container names: all, serv, coder1, coder2, coder3"
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
        echo "Valid container names: all, serv, coder1, coder2, coder3"
        exit 1
    fi
fi

# 停止容器
if [ "$container_name" == "all" ]; then
    echo "Stopping all OpenClaw containers..."
    docker-compose down
else
    echo "Stopping container: $container_name..."
    docker-compose stop $container_name
fi

# 显示状态
echo ""
echo "Container status:"
docker-compose ps

echo ""
echo "Done."
