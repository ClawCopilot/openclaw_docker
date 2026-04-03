# 基础镜像：使用 Ubuntu 24 LTS
# 可通过 --build-arg BASE_IMAGE=xxx 指定其他镜像
ARG BASE_IMAGE=ghcr.m.daocloud.io/openclaw/openclaw:latest
FROM ${BASE_IMAGE}

# 定义用户主目录
ARG CONTAINER_HOME=/home/node
ENV HOME=${CONTAINER_HOME}

# 切换到 root 用户执行需要权限的操作
USER root

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

# 检查并创建 node 用户（如果基础镜像未包含）
RUN echo "[LOG] 检查 node 用户是否存在..." && \
    id node > /dev/null 2>&1 && echo "[LOG] node 用户已存在" || ( \
        echo "[LOG] node 用户不存在，开始创建..." && \
        useradd -m -s /bin/bash node && \
        echo "[LOG] node 用户创建完成" \
    )

# 复制 GitHub Hosts 更新脚本到用户目录
COPY update_hosts.sh /home/node/update_hosts.sh
USER root
RUN chmod +x /home/node/update_hosts.sh && chown node:node /home/node/update_hosts.sh

# 首次执行脚本
RUN /home/node/update_hosts.sh

# 设置定时任务（每3小时执行一次）
USER root
RUN echo "0 */3 * * * node /home/node/update_hosts.sh" > /etc/cron.d/update_hosts && \
    chmod 644 /etc/cron.d/update_hosts

# 清理临时文件
RUN echo "[LOG] 清理临时文件..." && \
    rm -rf /tmp/* /var/tmp/*    

RUN apt-get update -y --allow-unauthenticated && \
    apt-get install -y --no-install-recommends tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 将node用户添加root用户组, sudo 不需要密码
RUN echo 'node ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers    

# 安装构建阶段依赖（包含编译工具）
RUN echo "[LOG] 开始安装构建阶段依赖..." && \
    apt-get update -y --allow-unauthenticated && \
    echo "[LOG] 包列表更新完成，开始安装依赖包..." && \
    apt-get install -y --no-install-recommends \
    git \
    vim \
    sudo \
    supervisor \
    python3 \
    python3-pip \
    curl \
    wget \
    ca-certificates \
    build-essential \
    cron && \
    echo "[LOG] 依赖包安装完成，开始清理..." && \    
    apt-get clean && \
    echo "[LOG] 清理完成"    

# 配置supervisor
RUN mkdir -p /var/log/supervisor && \
    mkdir -p /etc/supervisor/conf.d && \
    mkdir -p /home/node/.supervisor && \
    chown -R node:node /var/log/supervisor && \
    chown -R node:node /home/node/.supervisor && \
    echo "[supervisord]" > /etc/supervisor/supervisord.conf && \
    echo "nodaemon=false" >> /etc/supervisor/supervisord.conf && \
    echo "logfile=/var/log/supervisor/supervisord.log" >> /etc/supervisor/supervisord.conf && \
    echo "pidfile=/home/node/.supervisor/supervisord.pid" >> /etc/supervisor/supervisord.conf && \
    echo "childlogdir=/var/log/supervisor" >> /etc/supervisor/supervisord.conf && \
    echo "" >> /etc/supervisor/supervisord.conf && \
    echo "[unix_http_server]" >> /etc/supervisor/supervisord.conf && \
    echo "file=/home/node/.supervisor/supervisor.sock" >> /etc/supervisor/supervisord.conf && \
    echo "" >> /etc/supervisor/supervisord.conf && \
    echo "[supervisorctl]" >> /etc/supervisor/supervisord.conf && \
    echo "serverurl=unix:///home/node/.supervisor/supervisor.sock" >> /etc/supervisor/supervisord.conf && \
    echo "" >> /etc/supervisor/supervisord.conf && \
    echo "[rpcinterface:supervisor]" >> /etc/supervisor/supervisord.conf && \
    echo "supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface" >> /etc/supervisor/supervisord.conf && \
    echo "" >> /etc/supervisor/supervisord.conf && \
    echo "[include]" >> /etc/supervisor/supervisord.conf && \
    echo "files = /etc/supervisor/conf.d/*.conf" >> /etc/supervisor/supervisord.conf && \
    echo "[LOG] Supervisor 配置完成" 

# 切换到 node 用户    
USER node    

# 配置时区
ARG TZ=Asia/Shanghai
ENV TZ=${TZ}

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

# 安装 Rust（安装失败不影响容器创建）
ARG RUST_VERSION=stable
ARG RUSTUP_MIRROR=tuna
RUN echo "[LOG] 检查 Rust 是否已安装..." && \
    if command -v rustc > /dev/null 2>&1; then \
        echo "[LOG] Rust 已安装，跳过安装步骤..."; \
    else \
        echo "[LOG] Rust 未安装，开始安装 Rust $RUST_VERSION..." && \
        ( \
            set -e && \
            if [ "$RUSTUP_MIRROR" = "tuna" ]; then \
                export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup" && \
                export RUSTUP_UPDATE_ROOT="https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"; \
            elif [ "$RUSTUP_MIRROR" = "ustc" ]; then \
                export RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rustup" && \
                export RUSTUP_UPDATE_ROOT="https://mirrors.ustc.edu.cn/rustup/rustup"; \
            fi && \
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain $RUST_VERSION && \
            echo "[LOG] Rust 安装完成..." \
        ) || echo "[WARN] Rust 安装失败，跳过继续构建..."; \
    fi
ENV PATH="$HOME/.cargo/bin:${PATH}"

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

# 安装 Go（安装失败不影响容器创建）
ARG GO_VERSION=1.25.8
ARG GOPROXY_MIRRORS=goproxy.cn,goproxy.io,direct
USER root
RUN echo "[LOG] 检查 Go 是否已安装..." && \
    if command -v go > /dev/null 2>&1; then \
        echo "[LOG] Go 已安装，跳过安装步骤..."; \
    else \
        echo "[LOG] Go 未安装，开始安装 Go $GO_VERSION..." && \
        ( \
            set -e && \
            GO_DOWNLOAD_URL="https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" && \
            curl -fsSL --connect-timeout 10 "$GO_DOWNLOAD_URL" -o /tmp/go.tar.gz || \
            curl -fsSL "https://mirrors.ustc.edu.cn/golang/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz || \
            curl -fsSL "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz && \
            tar -C /usr/local -xzf /tmp/go.tar.gz && \
            rm -f /tmp/go.tar.gz && \
            echo "[LOG] Go 安装完成..." \
        ) || echo "[WARN] Go 安装失败，跳过继续构建..."; \
    fi
USER node
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="$HOME/go"
ENV PATH="$GOPATH/bin:${PATH}"
RUN mkdir -p "$GOPATH" && \
    GOPROXY_LIST="" && \
    for mirror in $(echo "$GOPROXY_MIRRORS" | tr ',' ' '); do \
        if [ "$mirror" = "goproxy.cn" ]; then \
            GOPROXY_LIST="${GOPROXY_LIST}https://goproxy.cn,"; \
        elif [ "$mirror" = "goproxy.io" ]; then \
            GOPROXY_LIST="${GOPROXY_LIST}https://goproxy.io,"; \
        elif [ "$mirror" = "aliyun" ]; then \
            GOPROXY_LIST="${GOPROXY_LIST}https://mirrors.aliyun.com/goproxy/,"; \
        elif [ "$mirror" = "direct" ]; then \
            GOPROXY_LIST="${GOPROXY_LIST}direct,"; \
        else \
            GOPROXY_LIST="${GOPROXY_LIST}${mirror},"; \
        fi; \
    done && \
    GOPROXY_LIST=$(echo "$GOPROXY_LIST" | sed 's/,$//') && \
    go env -w GOPROXY="$GOPROXY_LIST" && \
    go env -w GOSUMDB=sum.golang.org && \
    echo "[LOG] GOPROXY 配置完成: $(go env GOPROXY)"

# 配置 Docker Hub 镜像加速
ARG DOCKER_HUB_MIRRORS=daocloud,aliyun,tuna
USER root
RUN echo "[LOG] 配置 Docker Hub 镜像加速..." && \
    mkdir -p /etc/docker && \
    MIRROR_JSON="[" && \
    for mirror in $(echo "$DOCKER_HUB_MIRRORS" | tr ',' ' '); do \
        if [ "$mirror" = "daocloud" ]; then \
            URL="https://docker.m.daocloud.io"; \
        elif [ "$mirror" = "aliyun" ]; then \
            URL="https://registry.cn-hangzhou.aliyuncs.com"; \
        elif [ "$mirror" = "tuna" ]; then \
            URL="https://docker.mirrors.tuna.tsinghua.edu.cn"; \
        elif [ "$mirror" = "ustc" ]; then \
            URL="https://docker.mirrors.ustc.edu.cn"; \
        else \
            URL="$mirror"; \
        fi; \
        if [ "$MIRROR_JSON" = "[" ]; then \
            MIRROR_JSON="${MIRROR_JSON}\"$URL\""; \
        else \
            MIRROR_JSON="${MIRROR_JSON}, \"$URL\""; \
        fi; \
    done && \
    MIRROR_JSON="${MIRROR_JSON}]" && \
    printf '{\n  "registry-mirrors": %s\n}\n' "$MIRROR_JSON" > /etc/docker/daemon.json && \
    echo "[LOG] Docker Hub 镜像加速配置完成: $MIRROR_JSON"
USER node

# 尝试安装 OpenClaw（如果基础镜像未包含）
ARG OPENCLAW_VERSION=latest
RUN echo "[LOG] 检查 OpenClaw 是否已安装..." && \
    command -v openclaw > /dev/null 2>&1 && echo "[LOG] OpenClaw 已安装，跳过安装步骤..." || ( \
        echo "[LOG] OpenClaw 未安装，开始安装 OpenClaw@$OPENCLAW_VERSION..." && \
        npm install -g "openclaw@$OPENCLAW_VERSION" && \
        echo "[LOG] OpenClaw 安装完成..." \
    )

# 复制 entrypoint 脚本
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
USER root
RUN chmod +x /usr/local/bin/entrypoint.sh
USER node

# 安装 brew（使用国内镜像源，安装失败不影响容器创建）
RUN echo "[LOG] 检查 brew 是否已安装..." && \
    BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew" && \
    if command -v brew > /dev/null 2>&1; then \
        echo "[LOG] brew 已在 PATH 中，跳过安装步骤..."; \
    elif [ -f "$BREW_BIN" ]; then \
        echo "[LOG] brew 已安装但未配置 PATH，正在配置..." && \
        echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >> "$HOME/.bashrc" && \
        echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> "$HOME/.bashrc" && \
        echo "[LOG] brew PATH 配置完成..."; \
    else \
        echo "[LOG] brew 未安装，开始安装 brew..." && \
        ( \
            set -e && \
            sudo apt-get update -y --allow-unauthenticated && \
            sudo apt-get install -y --no-install-recommends build-essential curl git && \
            echo "[LOG] 创建 brew 安装目录..." && \
            sudo rm -fr /home/linuxbrew/.linuxbrew && \
            sudo mkdir -p /home/linuxbrew/.linuxbrew && \
            sudo chown -R node:node /home/linuxbrew && \
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
        ) || echo "[WARN] brew 安装失败，跳过继续构建..."; \
    fi

# 设置 brew 环境变量
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
ENV HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"

# 容器工具安装配置
ARG INSTALL_DOCKER=false
ARG INSTALL_PODMAN=true
ARG INSTALL_DOCKER_COMPOSE=false
ARG DOCKER_COMPOSE_VERSION=latest

# 安装 Docker（可选，安装失败不影响容器创建）
USER root
RUN if [ "$INSTALL_DOCKER" = "true" ]; then \
        echo "[LOG] 开始安装 Docker..." && \
        ( \
            set -e && \
            apt-get update -y --allow-unauthenticated && \
            apt-get install -y --no-install-recommends \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg \
                lsb-release && \
            curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
            apt-get update -y --allow-unauthenticated && \
            apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io && \
            mkdir -p /etc/docker && \
            usermod -aG docker node && \
            echo "[LOG] Docker 安装完成，node 用户已添加到 docker 组" \
        ) || echo "[WARN] Docker 安装失败，跳过继续构建..."; \
    else \
        echo "[LOG] 跳过 Docker 安装"; \
    fi

# 安装 Podman（可选，安装失败不影响容器创建）
RUN if [ "$INSTALL_PODMAN" = "true" ]; then \
        echo "[LOG] 开始安装 Podman..." && \
        ( \
            set -e && \
            apt-get update -y --allow-unauthenticated && \
            apt-get install -y --no-install-recommends \
                podman \
                slirp4netns \
                fuse-overlayfs \
                uidmap && \
            echo "node:100000:65536" >> /etc/subuid && \
            echo "node:100000:65536" >> /etc/subgid && \
            mkdir -p /etc/containers && \
            MIRROR_URL=$(echo "$DOCKER_HUB_MIRRORS" | cut -d',' -f1) && \
            case "$MIRROR_URL" in \
                daocloud) MIRROR_URL="docker.m.daocloud.io" ;; \
                aliyun) MIRROR_URL="registry.cn-hangzhou.aliyuncs.com" ;; \
                tuna) MIRROR_URL="docker.mirrors.tuna.tsinghua.edu.cn" ;; \
                ustc) MIRROR_URL="docker.mirrors.ustc.edu.cn" ;; \
            esac && \
            echo '[registries.search]' > /etc/containers/registries.conf && \
            echo "registries = ['docker.io', '$MIRROR_URL']" >> /etc/containers/registries.conf && \
            echo "[LOG] Podman 安装完成，已配置 rootless 模式支持" \
        ) || echo "[WARN] Podman 安装失败，跳过继续构建..."; \
    else \
        echo "[LOG] 跳过 Podman 安装"; \
    fi

# 安装 Docker Compose（可选，安装失败不影响容器创建）
RUN if [ "$INSTALL_DOCKER_COMPOSE" = "true" ]; then \
        echo "[LOG] 开始安装 Docker Compose..." && \
        ( \
            set -e && \
            COMPOSE_VERSION="${DOCKER_COMPOSE_VERSION}" && \
            if [ "$COMPOSE_VERSION" = "latest" ]; then \
                COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'); \
            fi && \
            curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
            chmod +x /usr/local/bin/docker-compose && \
            if [ ! -f /usr/local/bin/docker-compose ] || [ ! -s /usr/local/bin/docker-compose ]; then \
                echo "[LOG] GitHub 下载失败，尝试使用国内镜像..." && \
                curl -L "https://mirrors.aliyun.com/docker-toolbox/linux/docker-compose/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
                chmod +x /usr/local/bin/docker-compose; \
            fi && \
            docker-compose --version && \
            echo "[LOG] Docker Compose 安装完成" \
        ) || echo "[WARN] Docker Compose 安装失败，跳过继续构建..."; \
    else \
        echo "[LOG] 跳过 Docker Compose 安装"; \
    fi

# Ollama 和 VLLM 安装配置
ARG INSTALL_OLLAMA=false
ARG OLLAMA_MIRROR=modelscope
ARG INSTALL_VLLM=false
ARG VLLM_MIRROR=tuna

# 安装 Ollama（可选，安装失败不影响容器创建）
RUN if [ "$INSTALL_OLLAMA" = "true" ]; then \
        echo "[LOG] 开始安装 Ollama..." && \
        ( \
            set -e && \
            if [ "$OLLAMA_MIRROR" = "modelscope" ]; then \
                echo "[LOG] 使用魔搭社区镜像下载 Ollama..." && \
                curl -fsSL "https://modelscope.cn/models/ollama/ollama/resolve/main/ollama-linux-amd64" -o /usr/local/bin/ollama || \
                curl -fsSL "https://ollama.com/install.sh" | sh; \
            else \
                curl -fsSL "https://ollama.com/install.sh" | sh; \
            fi && \
            chmod +x /usr/local/bin/ollama 2>/dev/null || true && \
            ollama --version && \
            echo "[LOG] Ollama 安装完成" \
        ) || echo "[WARN] Ollama 安装失败，跳过继续构建..."; \
    else \
        echo "[LOG] 跳过 Ollama 安装"; \
    fi

# 安装 VLLM（可选，安装失败不影响容器创建）
RUN if [ "$INSTALL_VLLM" = "true" ]; then \
        echo "[LOG] 开始安装 VLLM..." && \
        ( \
            set -e && \
            PIP_INDEX_URL="" && \
            if [ "$VLLM_MIRROR" = "tuna" ]; then \
                PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"; \
            elif [ "$VLLM_MIRROR" = "aliyun" ]; then \
                PIP_INDEX_URL="https://mirrors.aliyun.com/pypi/simple/"; \
            elif [ "$VLLM_MIRROR" = "douban" ]; then \
                PIP_INDEX_URL="https://pypi.doubanio.com/simple/"; \
            fi && \
            if [ -n "$PIP_INDEX_URL" ]; then \
                pip3 install vllm -i "$PIP_INDEX_URL" --trusted-host $(echo "$PIP_INDEX_URL" | sed 's|https://\([^/]*\).*|\1|'); \
            else \
                pip3 install vllm; \
            fi && \
            python3 -c "import vllm; print(f'VLLM version: {vllm.__version__}')" && \
            echo "[LOG] VLLM 安装完成" \
        ) || echo "[WARN] VLLM 安装失败，跳过继续构建..."; \
    else \
        echo "[LOG] 跳过 VLLM 安装"; \
    fi

USER node

# 设置 entrypoint（在容器启动时检测并启动 OpenClaw）
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
