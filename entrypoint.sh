#!/bin/bash

# 整理 PATH 环境变量，去除重复路径（保留首次出现的）
if [ -n "$PATH" ]; then
    NEW_PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '!arr[$0]++{print $0}' | sed 's/:$//')
    if [ "$NEW_PATH" != "$PATH" ]; then
        export PATH="$NEW_PATH"
        echo "[ENTRYPOINT] PATH 已整理去重"
    fi
fi

echo "[ENTRYPOINT] OpenClaw 容器启动脚本"

echo "[ENTRYPOINT] 检查 OpenClaw 是否已安装..."
if ! command -v openclaw &> /dev/null; then
    echo "[ENTRYPOINT] OpenClaw 未安装，开始安装..."
    
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$PATH"
    
    OPENCLAW_VERSION="${OPENCLAW_VERSION:-latest}"
    echo "[ENTRYPOINT] 安装 OpenClaw@$OPENCLAW_VERSION..."
    npm install -g "openclaw@$OPENCLAW_VERSION"
    if [ $? -eq 0 ]; then
        echo "[ENTRYPOINT] OpenClaw 安装成功"
    else
        echo "[ENTRYPOINT] OpenClaw 安装失败，请检查网络连接或 npm 配置"
        exit 1
    fi
else
    echo "[ENTRYPOINT] OpenClaw 已安装: $(openclaw --version 2>/dev/null || echo 'version unknown')"
fi

echo "[ENTRYPOINT] 启动 Supervisor..."
if command -v supervisord &> /dev/null; then
    if [ -f /etc/supervisor/supervisord.conf ]; then
        mkdir -p "$HOME/.supervisor"
        supervisord -c /etc/supervisor/supervisord.conf
        echo "[ENTRYPOINT] Supervisor 已启动"
    else
        echo "[ENTRYPOINT] 警告: /etc/supervisor/supervisord.conf 不存在，跳过 Supervisor 启动"
    fi
else
    echo "[ENTRYPOINT] 警告: supervisord 未安装，跳过 Supervisor 启动"
fi

echo "[ENTRYPOINT] 启动 OpenClaw Gateway 服务..."
echo "[ENTRYPOINT] GATEWAY_ID: ${GATEWAY_ID:-not set}"
echo "[ENTRYPOINT] PORT: ${PORT:-18789}"

cd "$HOME"

if [ -n "$GATEWAY_ID" ]; then
    echo "[ENTRYPOINT] 使用 GATEWAY_ID: $GATEWAY_ID 启动..."
    export GATEWAY_ID
    exec openclaw gateway --port "${PORT:-18789}" --allow-unconfigured
else
    echo "[ENTRYPOINT] 使用默认配置启动..."
    exec openclaw gateway --port "${PORT:-18789}" --allow-unconfigured
fi
