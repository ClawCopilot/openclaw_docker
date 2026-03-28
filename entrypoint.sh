#!/bin/bash

echo "[ENTRYPOINT] OpenClaw 容器启动脚本"

echo "[ENTRYPOINT] 检查 OpenClaw 是否已安装..."
if ! command -v openclaw &> /dev/null; then
    echo "[ENTRYPOINT] OpenClaw 未安装，开始安装..."
    
    # 设置 npm 全局安装目录到用户目录
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$PATH"
    
    npm install -g openclaw@latest
    if [ $? -eq 0 ]; then
        echo "[ENTRYPOINT] OpenClaw 安装成功"
    else
        echo "[ENTRYPOINT] OpenClaw 安装失败，请检查网络连接或 npm 配置"
        exit 1
    fi
else
    echo "[ENTRYPOINT] OpenClaw 已安装: $(openclaw --version 2>/dev/null || echo 'version unknown')"
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
