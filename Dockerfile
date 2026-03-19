# 基础镜像：支持动态切换，可改为 debian:bullseye 或 debian:bookworm 或 node:22-slim
# 测试时建议分别构建两次以验证兼容性
ARG BASE_IMAGE=node:22-slim
FROM ${BASE_IMAGE}

# 定义环境变量，方便后续修改镜像地址
# 这里使用阿里云镜像，如需更换可在此处修改
ARG MIRROR_URL="mirrors.aliyun.com"
ARG DEBIAN_VERSION_CODENAME=""

# ---------------------------------------------------------
# 步骤 1: 智能判断版本并替换源 (核心逻辑)
# ---------------------------------------------------------
# 使用外部脚本配置源，提高可读性和可维护性
# ---------------------------------------------------------
COPY configure_sources.sh /tmp/configure_sources.sh
RUN chmod +x /tmp/configure_sources.sh && \
    /tmp/configure_sources.sh ${MIRROR_URL} && \
    rm /tmp/configure_sources.sh



# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=production
ENV npm_config_registry=https://registry.npmmirror.com/
ENV pnpm_config_registry=https://registry.npmmirror.com/
ENV PYTHONUNBUFFERED=1




# 复制 npm 和 git 配置文件
COPY .npmrc /root/.npmrc
COPY .gitconfig /root/.gitconfig

# 配置 Python pip 国内镜像源
RUN mkdir -p /root/.config/pip && echo "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\nextra-index-url = https://pypi.aliyun.com/simple/\ntrusted-host = pypi.tuna.tsinghua.edu.cn pypi.aliyun.com" > /root/.config/pip/pip.conf

# 配置 wget 镜像源
RUN echo "ftp://mirror.bit.edu.cn" > /etc/wgetrc

# 配置缓存相关环境变量
ENV npm_config_cache=/root/.npm
ENV pip_cache_dir=/root/.cache/pip

# 安装构建阶段依赖（包含编译工具）
RUN apt-get update -y --allow-unauthenticated && \
    apt-get install -y --no-install-recommends --fix-missing --fix-broken \
    git \
    vim \
    sudo \
    python3 \
    python3-pip \
    curl \
    wget \
    ca-certificates \
    build-essential \
    cron \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 单独安装 wget
RUN apt-get update -y --allow-unauthenticated && \
    apt-get install -y --no-install-recommends wget || echo "wget 安装失败，继续执行" && \
    apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 复制 GitHub Hosts 更新脚本到用户目录
COPY update_hosts.sh /root/update_hosts.sh
RUN chmod +x /root/update_hosts.sh

# 首次执行脚本
RUN /root/update_hosts.sh

# 设置定时任务（每5小时执行一次）
RUN echo "0 */5 * * * /root/update_hosts.sh" > /etc/cron.d/update_hosts && \
    chmod 644 /etc/cron.d/update_hosts && \
    crontab /etc/cron.d/update_hosts

# 配置 wget 镜像源
RUN echo "ftp://mirror.bit.edu.cn" > /etc/wgetrc

# 安装 brew（使用国内镜像源）
RUN echo -e "Y\n2\n5" | /bin/bash -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)" && \
    # 配置 brew 环境变量
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /root/.bashrc && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    # 配置 brew 国内镜像源
    brew tap --custom-remote --force-auto-update homebrew/core https://mirrors.ustc.edu.cn/homebrew-core.git && \
    brew tap --custom-remote --force-auto-update homebrew/cask https://mirrors.ustc.edu.cn/homebrew-cask.git && \
    brew tap --custom-remote --force-auto-update homebrew/cask-versions https://mirrors.ustc.edu.cn/homebrew-cask-versions.git && \
    # 设置 brew 镜像源环境变量
    echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> /root/.bashrc && \
    export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles

# 直接使用 npm 全局安装 OpenClaw
RUN npm install -g openclaw@latest

# 暴露端口
EXPOSE 18798

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:18798/health || exit 1

# 启动命令（同时启动 cron 服务和 OpenClaw 网关，允许未配置）
CMD service cron start && openclaw gateway --allow-unconfigured