# 基础镜像：使用 Ubuntu 24 LTS
# ARG BASE_IMAGE=ghcr.io/openclaw/openclaw:latest
ARG BASE_IMAGE=ghcr.m.daocloud.io/openclaw/openclaw:latest
FROM ${BASE_IMAGE}

# 定义用户主目录
ARG CONTAINER_HOME=/home/node
ENV HOME=${CONTAINER_HOME}

# 切换到 root 用户执行需要权限的操作
USER root

# 以下路径可能是权限造成的，需要创建及修复, 做兼容修复
RUN mkdir -p "/.npm" && chown -R 1000:1000 "/.npm"
RUN mkdir -p "/.cache/pip" && chown -R 1000:1000 "/.cache/pip"

# 安装 sudo
RUN apt-get update -y --allow-unauthenticated && \
    apt-get install -y --no-install-recommends sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 定义环境变量，方便后续修改镜像地址
# 这里使用阿里云镜像，如需更换可在此处修改
ARG MIRROR_URL="mirrors.aliyun.com"
ARG DEBIAN_VERSION_CODENAME=""

# ---------------------------------------------------------
# 步骤 1: 智能判断版本并替换源 (核心逻辑)
# ---------------------------------------------------------
# 使用外部脚本配置源，提高可读性和可维护性
# ---------------------------------------------------------
# 复制并执行源配置脚本
COPY configure_sources.sh /tmp/configure_sources.sh
RUN chmod +x /tmp/configure_sources.sh && \
    bash /tmp/configure_sources.sh ${MIRROR_URL} && \
    rm /tmp/configure_sources.sh

# 配置 wget 镜像源
RUN echo "[LOG] 配置 wget 镜像源..." && \
    echo "ftp://mirror.bit.edu.cn" > /etc/wgetrc && \
    echo "[LOG] 清理临时文件..." && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 复制 GitHub Hosts 更新脚本到用户目录
COPY update_hosts.sh /root/update_hosts.sh
RUN chmod +x /root/update_hosts.sh

# 首次执行脚本
RUN /root/update_hosts.sh

# 设置定时任务（每5小时执行一次）
RUN echo "0 */5 * * * /root/update_hosts.sh" > /etc/cron.d/update_hosts && \
    chmod 644 /etc/cron.d/update_hosts

# 清理临时文件
RUN echo "[LOG] 清理临时文件..." && \
    rm -rf /tmp/* /var/tmp/*    

# 配置时区
ARG TZ=Asia/Shanghai
ENV TZ=${TZ}
RUN apt-get update -y --allow-unauthenticated && \
    apt-get install -y --no-install-recommends tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安装构建阶段依赖（包含编译工具）
RUN echo "[LOG] 开始安装构建阶段依赖..." && \
    apt-get update -y --allow-unauthenticated && \
    echo "[LOG] 包列表更新完成，开始安装依赖包..." && \
    apt-get install -y --no-install-recommends \
    git \
    vim \
    sudo \
    python3 \
    python3-pip \
    curl \
    wget \
    ca-certificates \
    build-essential \
    cron && \
    # 给node用户添加sudo权限
    echo 'node ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo "[LOG] 依赖包安装完成，开始清理..." && \
    apt-get clean && \
    echo "[LOG] 清理完成"    

# 切换到 node 用户    
USER node    


# 安装 NodeJS 24 LTS
RUN echo "[LOG] 检查 NodeJS 是否已安装..." && \
    command -v node > /dev/null 2>&1 && echo "[LOG] NodeJS 已安装，跳过安装步骤" || ( \
        echo "[LOG] NodeJS 未安装，开始安装 NodeJS 24 LTS..." && \
        apt-get update -y --allow-unauthenticated && \
        apt-get install -y --no-install-recommends curl ca-certificates && \
        curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
        apt-get install -y nodejs && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* && \
        echo "[LOG] NodeJS 安装完成" \
    ) && \
    node --version && \
    npm --version    

# 设置环境变量
ENV npm_config_registry=https://registry.npmmirror.com/
ENV pnpm_config_registry=https://registry.npmmirror.com/
ENV PYTHONUNBUFFERED=1


# 复制 npm 配置文件（如果存在则追加，不存在则复制）
COPY .npmrc /tmp/.npmrc
RUN if [ -f "$HOME/.npmrc" ]; then \
        echo "[LOG] .npmrc 文件已存在，追加内容..." && \
        cat /tmp/.npmrc >> "$HOME/.npmrc"; \
    else \
        echo "[LOG] .npmrc 文件不存在，直接复制..." && \
        cp /tmp/.npmrc "$HOME/.npmrc"; \
    fi

# 复制 git 配置文件（如果存在则追加，不存在则复制）
COPY .gitconfig /tmp/.gitconfig
RUN if [ -f "$HOME/.gitconfig" ]; then \
        echo "[LOG] .gitconfig 文件已存在，追加内容..." && \
        cat /tmp/.gitconfig >> "$HOME/.gitconfig"; \
    else \
        echo "[LOG] .gitconfig 文件不存在，直接复制..." && \
        cp /tmp/.gitconfig "$HOME/.gitconfig"; \
    fi

# 配置 Python pip 国内镜像源
ARG PIP_MIRROR=tuna
RUN mkdir -p "$HOME/.config/pip" && \
    if [ "$PIP_MIRROR" = "tuna" ]; then \
        printf '[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\ntrusted-host = pypi.tuna.tsinghua.edu.cn\n' > "$HOME/.config/pip/pip.conf"; \
    elif [ "$PIP_MIRROR" = "aliyun" ]; then \
        printf '[global]\nindex-url = https://mirrors.aliyun.com/pypi/simple/\ntrusted-host = mirrors.aliyun.com\n' > "$HOME/.config/pip/pip.conf"; \
    elif [ "$PIP_MIRROR" = "douban" ]; then \
        printf '[global]\nindex-url = https://pypi.doubanio.com/simple/\ntrusted-host = pypi.doubanio.com\n' > "$HOME/.config/pip/pip.conf"; \
    fi

# 配置 Rust crates.io 国内镜像源
ARG RUST_CRATES_MIRROR=tuna
RUN mkdir -p "$HOME/.cargo" && \
    if [ "$RUST_CRATES_MIRROR" = "tuna" ]; then \
        printf '[source.crates-io]\nreplace-with = "tuna"\n[source.tuna]\nregistry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"\n' > "$HOME/.cargo/config.toml"; \
    elif [ "$RUST_CRATES_MIRROR" = "ustc" ]; then \
        printf '[source.crates-io]\nreplace-with = "ustc"\n[source.ustc]\nregistry = "https://mirrors.ustc.edu.cn/crates.io-index"\n' > "$HOME/.cargo/config.toml"; \
    elif [ "$RUST_CRATES_MIRROR" = "rsproxy" ]; then \
        printf '[source.crates-io]\nreplace-with = "rsproxy"\n[source.rsproxy]\nregistry = "https://rsproxy.cn/crates.io-index"\n' > "$HOME/.cargo/config.toml"; \
    fi

# 配置缓存相关环境变量
ENV npm_config_cache="$HOME/.npm"
ENV pip_cache_dir="$HOME/.cache/pip"

RUN mkdir -p "$npm_config_cache"
RUN mkdir -p "$pip_cache_dir"

# 直接使用 npm 全局安装 OpenClaw
RUN echo "[LOG] 检查 OpenClaw 是否已安装..." && \
    command -v openclaw > /dev/null 2>&1 && echo "[LOG] OpenClaw 已安装，跳过安装步骤..." || ( \
        echo "[LOG] OpenClaw 未安装，开始安装 OpenClaw..." && \
        npm install -g openclaw@latest && \
        echo "[LOG] OpenClaw 安装完成..." \
    )

# 安装 brew（使用国内镜像源）
RUN echo "[LOG] 检查 brew 是否已安装..." && \
    command -v brew > /dev/null 2>&1 && echo "[LOG] brew 已安装，跳过安装步骤..." || ( \
        echo "[LOG] brew 未安装，开始安装 brew..." && \
        # 安装必要的依赖
        sudo apt-get update -y --allow-unauthenticated && \
        sudo apt-get install -y --no-install-recommends build-essential curl git && \
        # 创建 brew 安装目录并设置权限
        echo "[LOG] 创建 brew 安装目录..." && \
        sudo mkdir -p /home/linuxbrew/.linuxbrew && \
        sudo chown -R node:node /home/linuxbrew && \
        # 直接以 node 用户身份安装 brew
        echo "[LOG] 从国内镜像源克隆 Homebrew 仓库..." && \
        git clone --depth 1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git /home/linuxbrew/.linuxbrew/Homebrew && \
        echo "[LOG] 从国内镜像源克隆 Homebrew Core 仓库..." && \
        git clone --depth 1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core && \
        echo "[LOG] 创建 bin 目录..." && \
        mkdir -p /home/linuxbrew/.linuxbrew/bin && \
        echo "[LOG] 创建 brew 符号链接..." && \
        ln -s /home/linuxbrew/.linuxbrew/Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew && \
        echo "[LOG] 配置 brew 环境变量..." && \
        echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >> "$HOME/.bashrc" && \
        echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> "$HOME/.bashrc" && \
        export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH" && \
        export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles && \
        echo "[LOG] 测试 brew 安装..." && \
        brew --version && \
        echo "[LOG] brew 安装完成..." \
    ) && \
    # 配置 brew 镜像源（无论是否新安装）
    echo "[LOG] 配置 brew 镜像源..." && \
    # 为 node 用户配置 brew 环境变量
    echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >> "$HOME/.bashrc" && \
    echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> "$HOME/.bashrc" && \
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH" && \
    export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles && \
    echo "[LOG] brew 镜像源配置完成..."

