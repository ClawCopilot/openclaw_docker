#!/bin/bash
MIRROR_URL=$1

if [ -f /etc/apt/sources.list.d/debian.sources ]; then
    # Debian 12+ (Bookworm)
    echo "检测到 Debian 12+，正在配置 .sources 格式..."
    cat > /etc/apt/sources.list.d/debian.sources <<'EOF'
Types: deb deb-src
URIs: https://${MIRROR_URL}/debian/
Suites: bookworm bookworm-updates bookworm-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
    # 替换变量
    sed -i "s|\${MIRROR_URL}|$MIRROR_URL|g" /etc/apt/sources.list.d/debian.sources
    echo "Debian 12 源配置完成。"
elif [ -f /etc/apt/sources.list ]; then
    # Debian 11- (Bullseye)
    CODENAME=$(cat /etc/os-release | grep "^VERSION_CODENAME=" | cut -d= -f2)
    echo "检测到 Debian 11 或更早 (版本代号: $CODENAME)，正在配置 sources.list 格式..."
    cat > /etc/apt/sources.list <<'EOF'
deb https://${MIRROR_URL}/debian/ ${CODENAME} main contrib non-free
deb-src https://${MIRROR_URL}/debian/ ${CODENAME} main contrib non-free
deb https://${MIRROR_URL}/debian-security/ ${CODENAME}-security main contrib non-free
deb-src https://${MIRROR_URL}/debian-security/ ${CODENAME}-security main contrib non-free
deb https://${MIRROR_URL}/debian/ ${CODENAME}-updates main contrib non-free
deb-src https://${MIRROR_URL}/debian/ ${CODENAME}-updates main contrib non-free
deb https://${MIRROR_URL}/debian/ ${CODENAME}-backports main contrib non-free
deb-src https://${MIRROR_URL}/debian/ ${CODENAME}-backports main contrib non-free
EOF
    # 替换变量
    sed -i "s|\${MIRROR_URL}|$MIRROR_URL|g" /etc/apt/sources.list
    sed -i "s|\${CODENAME}|$CODENAME|g" /etc/apt/sources.list
    echo "Debian 11 源配置完成。"
else
    echo "错误：未找到标准的源配置文件！"
    exit 1
fi

# 清除旧缓存
rm -rf /var/lib/apt/lists/*
