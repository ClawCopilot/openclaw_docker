# OpenClaw Docker 部署

[![Language](https://img.shields.io/badge/Language-English-blue)](./README.en.md)
[![Language](https://img.shields.io/badge/Language-中文-red)](./README.zh.md)
[![Language](https://img.shields.io/badge/Language-日本語-green)](./README.ja.md)

## 版本

- 当前版本：v2026.3.21

## 项目概述

本项目提供了一个基于 Docker 的 OpenClaw 多网关独立部署解决方案。它支持快速部署、易于管理，并使用国内镜像源优化性能。

## 功能特性

- **多网关部署**：在独立容器中运行多个 OpenClaw 网关
- **国内镜像源**：针对中国环境优化，加速依赖下载
- **易于管理**：提供启动、停止和重启脚本
- **特权模式**：增强权限以获得更好的性能
- **健康检查**：自动监控容器健康状态

## 环境要求

- Docker 20.0+ 
- Docker Compose 1.29+ 
- Windows (PowerShell) 或 Linux/Mac (bash)

## 快速开始

### Windows

1. 克隆本仓库
2. 导航到项目目录
3. 运行启动脚本：
   ```powershell
   .\start.ps1
   ```

### Linux/Mac

1. 克隆本仓库
2. 导航到项目目录
3. 使脚本可执行：
   ```bash
   chmod +x start.sh
   ```
4. 运行启动脚本：
   ```bash
   ./start.sh
   ```

## 访问地址

- **Serv**：http://localhost:42700
- **Coder1**：无外部端口映射（仅内部访问）
- **Coder2**：无外部端口映射（仅内部访问）
- **Coder3**：无外部端口映射（仅内部访问）

## 目录结构

```
openclaw_docker/
├── .gitconfig          # 带镜像的 Git 配置
├── .npmrc             # 带镜像的 npm 配置
├── Dockerfile         # Docker 构建文件
├── docker-compose.yml  # Docker Compose 配置
├── sources.list        # 带国内镜像的 APT 源
├── configure_sources.sh  # APT 源配置脚本
├── update_hosts.sh     # GitHub Hosts 更新脚本
├── start.ps1          # Windows 启动脚本
├── start.sh           # Linux/Mac 启动脚本
├── stop.ps1           # Windows 停止脚本
├── stop.sh            # Linux/Mac 停止脚本
├── restart.ps1        # Windows 重启脚本
└── restart.sh         # Linux/Mac 重启脚本
```

## 配置说明

### Dockerfile

- 使用 Node.js 22 slim 镜像作为基础
- 使用 apt 安装依赖以加快下载速度
- 使用国内镜像源加速 apt、npm、pip 和 git
- 使用 npm 全局安装 OpenClaw
- 包含 GitHub Hosts 更新脚本（update_hosts.sh），每5小时执行一次

### Docker Compose

- 定义四个服务：serv、coder1、coder2、coder3
- Serv 暴露在端口 42700
- 每个服务有自己的数据卷
- 所有服务以特权模式运行
- 使用环境变量配置，支持通过 .env 文件自定义配置

## 脚本使用

### 启动脚本

- `start.ps1` / `start.sh`：启动所有容器

### 停止脚本

- `stop.ps1` / `stop.sh`：停止所有容器或指定容器
  ```powershell
  # 停止所有容器
  .\stop.ps1
  
  # 停止指定容器
  .\stop.ps1 serv
  ```

### 重启脚本

- `restart.ps1` / `restart.sh`：重启所有容器或指定容器
  ```powershell
  # 重启所有容器
  .\restart.ps1
  
  # 重启指定容器
  .\restart.ps1 serv
  ```

## 环境变量

通过 .env 文件配置以下环境变量：

- `SERV_PORT`：Serv 服务的对外端口，默认 42700
- `CONTAINER_MEM_LIMIT`：容器内存限制，默认 2g
- `CONTAINER_RESTART_POLICY`：容器重启策略，默认 unless-stopped
- `TZ`：时区设置，默认 Asia/Shanghai
- `npm_config_registry`：npm 镜像源，默认 https://registry.npmmirror.com/
- `pnpm_config_registry`：pnpm 镜像源，默认 https://registry.npmmirror.com/
- `pip_config_index_url`：pip 镜像源，默认 https://pypi.tuna.tsinghua.edu.cn/simple
- `git_config_url`：git 镜像源，默认 https://github.com.cnpmjs.org
- `LOG_MAX_SIZE`：日志文件最大大小，默认 10m
- `LOG_MAX_FILE`：日志文件最大数量，默认 3
- `HEALTHCHECK_INTERVAL`：健康检查间隔，默认 30s
- `HEALTHCHECK_TIMEOUT`：健康检查超时，默认 10s
- `HEALTHCHECK_START_PERIOD`：健康检查启动期，默认 5s
- `HEALTHCHECK_RETRIES`：健康检查重试次数，默认 3
- `NETWORK_MODE`：网络模式，默认 bridge
- `OPENCLAW_NODE_ENV`：OpenClaw 运行环境，默认 production

## 故障排除

### apt 下载速度慢

项目使用 apt 和国内镜像源来加速下载。如果仍然遇到速度慢的问题，请考虑：

1. 检查网络连接
2. 必要时使用 VPN
3. 验证 `sources.list` 中的镜像源

### 容器启动问题

检查容器日志以获取错误信息：

```bash
docker-compose logs -f
```

## 贡献

欢迎贡献！请随时提交 Pull Request。

## 许可证

本项目采用 MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。
