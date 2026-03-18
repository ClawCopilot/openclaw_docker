# 使用官方 Node.js 22 镜像作为基础
FROM node:22-slim

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=production
ENV npm_config_registry=https://registry.npmmirror.com/
ENV pnpm_config_registry=https://registry.npmmirror.com/
ENV PYTHONUNBUFFERED=1

# 替换 sources.list 文件，添加多个国内镜像源
COPY sources.list /etc/apt/sources.list

# 复制 npm 和 git 配置文件
COPY .npmrc /root/.npmrc
COPY .gitconfig /root/.gitconfig

# 配置 Python pip 国内镜像源
RUN mkdir -p /root/.config/pip && echo "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\nextra-index-url = https://pypi.aliyun.com/simple/\ntrusted-host = pypi.tuna.tsinghua.edu.cn pypi.aliyun.com" > /root/.config/pip/pip.conf

# 配置 wget 镜像源
RUN echo "ftp://mirror.bit.edu.cn" > /etc/wgetrc

# 配置网络和构建相关环境变量
ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV npm_config_registry=https://registry.npmmirror.com/
ENV npm_config_disturl=https://npmmirror.com/mirrors/node
ENV PYTHONUNBUFFERED=1
ENV NODE_ENV=production
ENV NPM_CONFIG_PRODUCTION=true

# 配置缓存相关环境变量
ENV npm_config_cache=/root/.npm
ENV pip_cache_dir=/root/.cache/pip

# 安装 apt-fast 以加速依赖安装
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    aria2 \
    gnupg2 \
    curl \
    && echo "deb http://ppa.launchpad.net/apt-fast/stable/ubuntu focal main" > /etc/apt/sources.list.d/apt-fast.list && \
    curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xA2166B8DE8BDC336 | apt-key add - && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends apt-fast && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 使用 apt-fast 安装构建阶段依赖（包含编译工具）
RUN apt-fast update -y && \
    apt-fast install -y --no-install-recommends \
    git \
    python3 \
    python3-pip \
    wget \
    curl \
    ca-certificates \
    build-essential \
    && apt-fast clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 配置 wget 镜像源
RUN echo "ftp://mirror.bit.edu.cn" > /etc/wgetrc

# 安装 pnpm
RUN npm install -g pnpm

# 配置 pnpm 国内镜像源
RUN pnpm config set registry https://registry.npmmirror.com/ && \
    pnpm config set disturl https://npmmirror.com/mirrors/node && \
    pnpm config set sass_binary_site https://npmmirror.com/mirrors/node-sass && \
    pnpm config set electron_mirror https://npmmirror.com/mirrors/electron/ && \
    pnpm config set puppeteer_download_host https://npmmirror.com/mirrors && \
    pnpm config set chromedriver_cdnurl https://npmmirror.com/mirrors/chromedriver && \
    pnpm config set geckodriver_cdnurl https://npmmirror.com/mirrors/geckodriver

# 创建 pnpm 符号链接
RUN ln -s /usr/local/lib/node_modules/pnpm/bin/pnpm.js /usr/local/bin/pnpm && \
    ln -s /usr/local/lib/node_modules/pnpm/bin/pnpx.js /usr/local/bin/pnpx

# 全局安装 OpenClaw
RUN pnpm add -g openclaw@latest
RUN pnpm approve-builds -g

# 暴露端口
EXPOSE 18798

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:18798/health || exit 1

# 启动命令
CMD ["openclaw", "start"]