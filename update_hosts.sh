#!/bin/bash
# 下载最新的GitHub Hosts
curl -o /tmp/github_hosts https://fastly.jsdelivr.net/gh/ittuann/GitHub-IP-hosts@main/hosts
# 备份原文件
sudo cp /etc/hosts /etc/hosts.bak.$(date +%Y%m%d)
# 合并并去重
sudo cat /tmp/github_hosts | sudo tee -a /etc/hosts >/dev/null
# 刷新DNS缓存
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
echo "Hosts updated successfully!"