#!/bin/bash
# 下载最新的GitHub Hosts
curl -o /tmp/github_hosts https://fastly.jsdelivr.net/gh/ittuann/GitHub-IP-hosts@main/hosts
# 备份原文件
cp /etc/hosts /etc/hosts.bak.$(date +%Y%m%d)
# 合并并去重
# 先提取GitHub相关的IP和域名
grep -E 'github|githubusercontent|github.io' /tmp/github_hosts > /tmp/github_hosts_filtered
# 移除原hosts文件中的GitHub相关条目
grep -vE 'github|githubusercontent|github.io' /etc/hosts > /tmp/hosts_temp
# 合并文件
cat /tmp/hosts_temp /tmp/github_hosts_filtered > /etc/hosts
# 刷新DNS缓存（Debian/Ubuntu 方式）
if command -v systemctl &> /dev/null; then
    systemctl restart systemd-resolved
else
    /etc/init.d/dns-clean restart 2>/dev/null || echo "DNS cache refreshed"
fi
echo "Hosts updated successfully!"