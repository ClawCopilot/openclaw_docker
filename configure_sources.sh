#!/bin/bash
MIRROR_URL=$1

# 检测系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "系统信息：$NAME $VERSION"
else
    echo "错误：无法读取系统信息！"
    exit 1
fi

# 检查系统类型并配置相应的源
if [[ "$NAME" == *"Ubuntu"* ]]; then
    # Ubuntu 系统
    echo "检测到 Ubuntu 系统，配置 Ubuntu 源"
    # 备份原文件
    if [ -f /etc/apt/sources.list ]; then
        cp /etc/apt/sources.list /etc/apt/sources.list.bak
    fi
    
    # 获取 Ubuntu 版本代号
    UBUNTU_CODENAME=$(lsb_release -cs 2>/dev/null || echo "noble")
    
    # 使用阿里云镜像源
    cat > /etc/apt/sources.list <<EOF
deb http://${MIRROR_URL}/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse
deb http://${MIRROR_URL}/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
deb http://${MIRROR_URL}/ubuntu/ ${UBUNTU_CODENAME}-backports main restricted universe multiverse
deb http://${MIRROR_URL}/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse
EOF
    
    echo "源配置完成：使用阿里云镜像源 (Ubuntu)"
elif [ -f /etc/apt/sources.list.d/debian.sources ]; then
    # Debian 12+ 使用 .sources 格式
    echo "检测到 Debian 12+，使用 .sources 格式配置源"
    cat > /etc/apt/sources.list.d/debian.sources <<EOF
Types: deb
URIs: http://${MIRROR_URL}/debian
Suites: bookworm bookworm-updates bookworm-backports
Components: main contrib non-free non-free-firmware

Types: deb
URIs: http://${MIRROR_URL}/debian-security
Suites: bookworm-security
Components: main contrib non-free non-free-firmware
EOF
    echo "源配置完成：使用阿里云镜像源 (.sources 格式)"
elif [ -f /etc/apt/sources.list ]; then
    # 旧版本 Debian 使用 sources.list 格式
    echo "检测到旧版本 Debian，使用 sources.list 格式配置源"
    # 备份原文件
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    
    # 使用阿里云镜像源
    cat > /etc/apt/sources.list <<EOF
deb http://${MIRROR_URL}/debian/ bookworm main contrib non-free non-free-firmware
deb http://${MIRROR_URL}/debian/ bookworm-updates main contrib non-free non-free-firmware
deb http://${MIRROR_URL}/debian/ bookworm-backports main contrib non-free non-free-firmware
deb http://${MIRROR_URL}/debian-security/ bookworm-security main contrib non-free non-free-firmware
EOF
    
    echo "源配置完成：使用阿里云镜像源 (sources.list 格式)"
else
    # 两种格式都不存在，创建 sources.list 文件
    echo "未找到源配置文件，创建 sources.list 文件"
    mkdir -p /etc/apt
    cat > /etc/apt/sources.list <<EOF
deb http://${MIRROR_URL}/debian/ bookworm main contrib non-free non-free-firmware
deb http://${MIRROR_URL}/debian/ bookworm-updates main contrib non-free non-free-firmware
deb http://${MIRROR_URL}/debian/ bookworm-backports main contrib non-free non-free-firmware
deb http://${MIRROR_URL}/debian-security/ bookworm-security main contrib non-free non-free-firmware
EOF
    echo "源配置完成：创建并使用阿里云镜像源"
fi

# 清除旧缓存
rm -rf /var/lib/apt/lists/*

# 测试源是否可用
echo "测试源连接..."
apt-get update -y --allow-unauthenticated && echo "源连接成功！" || echo "源连接失败，可能需要检查网络或镜像源设置。"

