# OpenClaw Docker 部署

[![Language](https://img.shields.io/badge/Language-English-blue)](./README.en.md)
[![Language](https://img.shields.io/badge/Language-中文-red)](./README.zh.md)
[![Language](https://img.shields.io/badge/Language-日本語-green)](./README.ja.md)

## 版本

- 当前版本：v2026.3.24

## 项目概述

本项目提供了一个基于 Docker 的 OpenClaw 多网关独立部署解决方案。它支持快速部署、易于管理，并使用国内镜像源优化性能。

## 功能特性

- **多网关部署**：在独立容器中运行多个 OpenClaw 网关
- **动态配置**：通过 .env 文件灵活配置服务、端口和卷
- **国内镜像源**：针对中国环境优化，加速依赖下载
- **易于管理**：提供启动、停止、重启和权限修复脚本
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
3. 配置 `.env` 文件（可选）
4. 运行启动脚本：
   ```powershell
   .\start.ps1
   ```

### Linux/Mac

1. 克隆本仓库
2. 导航到项目目录
3. 配置 `.env` 文件（可选）
4. 使脚本可执行：
   ```bash
   chmod +x *.sh
   ```
5. 运行启动脚本：
   ```bash
   ./start.sh
   ```

## 目录结构

```
openclaw_docker/
├── .env                    # 环境变量配置文件
├── .gitconfig              # 带镜像的 Git 配置
├── .npmrc                  # 带镜像的 npm 配置
├── Dockerfile              # Docker 构建文件
├── docker-compose.yml      # Docker Compose 配置（动态生成）
├── sources.list            # 带国内镜像的 APT 源
├── configure_sources.sh    # APT 源配置脚本
├── update_hosts.sh         # GitHub Hosts 更新脚本
├── generate-compose.sh     # 生成 docker-compose.yml（Linux/Mac）
├── generate-compose.ps1    # 生成 docker-compose.yml（Windows）
├── fix_permissions.sh      # 修复目录权限（Linux/Mac）
├── fix_permissions.ps1     # 修复目录权限（Windows）
├── start.sh                # 启动脚本（Linux/Mac）
├── start.ps1               # 启动脚本（Windows）
├── stop.sh                 # 停止脚本（Linux/Mac）
├── stop.ps1                # 停止脚本（Windows）
├── restart.sh              # 重启脚本（Linux/Mac）
└── restart.ps1             # 重启脚本（Windows）
```

## 配置说明

### 环境变量配置（.env 文件）

通过 `.env` 文件配置服务：

```env
# 服务配置
# 格式: GATEWAY_SERVICES=service1,service2,service3
GATEWAY_SERVICES=serv,coder1,coder2,coder3

# 端口配置
# 格式: GATEWAY_PORTS=service1:port1,service2:port2
GATEWAY_PORTS=serv:42700

# 额外 volumes 配置
# 格式: GATEWAY_VOLUMES=service1:/host/path1:/container/path1,service2:/host/path2:/container/path2
GATEWAY_VOLUMES=
```

### 完整环境变量列表

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `GATEWAY_SERVICES` | 服务列表，逗号分隔 | `serv,coder1,coder2,coder3` |
| `GATEWAY_PORTS` | 端口映射，格式：`服务名:端口` | 空 |
| `GATEWAY_VOLUMES` | 额外卷映射，格式：`服务名:主机路径:容器路径` | 空 |
| `CONTAINER_MEM_LIMIT` | 容器内存限制 | `2g` |
| `CONTAINER_RESTART_POLICY` | 容器重启策略 | `unless-stopped` |
| `TZ` | 时区设置 | `Asia/Shanghai` |
| `npm_config_registry` | npm 镜像源 | `https://registry.npmmirror.com/` |
| `pnpm_config_registry` | pnpm 镜像源 | `https://registry.npmmirror.com/` |
| `pip_config_index_url` | pip 镜像源 | `https://pypi.tuna.tsinghua.edu.cn/simple` |
| `git_config_url` | git 镜像源 | `https://github.com.cnpmjs.org` |
| `LOG_MAX_SIZE` | 日志文件最大大小 | `10m` |
| `LOG_MAX_FILE` | 日志文件最大数量 | `3` |
| `HEALTHCHECK_INTERVAL` | 健康检查间隔 | `30s` |
| `HEALTHCHECK_TIMEOUT` | 健康检查超时 | `10s` |
| `HEALTHCHECK_START_PERIOD` | 健康检查启动期 | `5s` |
| `HEALTHCHECK_RETRIES` | 健康检查重试次数 | `3` |
| `NETWORK_MODE` | 网络模式 | `bridge` |
| `OPENCLAW_NODE_ENV` | OpenClaw 运行环境 | `production` |

### Dockerfile

- 使用 Node.js 22 slim 镜像作为基础
- 使用 apt 安装依赖以加快下载速度
- 使用国内镜像源加速 apt、npm、pip 和 git
- 使用 npm 全局安装 OpenClaw
- 包含 GitHub Hosts 更新脚本（update_hosts.sh），每5小时执行一次

## 脚本使用

### 生成配置脚本

- `generate-compose.sh` / `generate-compose.ps1`：根据 .env 配置生成 docker-compose.yml
  ```bash
  # 生成配置文件
  ./generate-compose.sh
  ```

### 权限修复脚本

- `fix_permissions.sh` / `fix_permissions.ps1`：创建并修复服务目录权限
  ```bash
  # 修复所有服务目录权限
  ./fix_permissions.sh
  ```

### 启动脚本

- `start.sh` / `start.ps1`：启动所有容器
  ```bash
  # 启动所有容器
  ./start.sh
  ```

### 停止脚本

- `stop.sh` / `stop.ps1`：停止所有容器或指定容器
  ```bash
  # 停止所有容器
  ./stop.sh
  
  # 停止指定容器
  ./stop.sh serv
  ```

### 重启脚本

- `restart.sh` / `restart.ps1`：重启所有容器或指定容器
  ```bash
  # 重启所有容器
  ./restart.sh
  
  # 重启指定容器
  ./restart.sh serv
  ```

## 自定义服务配置示例

### 示例 1：自定义服务列表

```env
# 定义三个自定义服务
GATEWAY_SERVICES=sme1,sme2,serv
```

### 示例 2：配置端口映射

```env
GATEWAY_SERVICES=serv,coder1
GATEWAY_PORTS=serv:42700,coder1:42800
```

### 示例 3：添加额外卷

```env
GATEWAY_SERVICES=serv
GATEWAY_VOLUMES=serv:/data/volumes:/data,serv:/opt/config:/app/config
```

## 访问地址

根据 `GATEWAY_PORTS` 配置，默认情况下：

- 配置了端口映射的服务可通过对应端口访问
- 未配置端口映射的服务仅支持内部访问

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

### 权限问题

如果遇到权限问题，运行权限修复脚本：

```bash
./fix_permissions.sh
```

## 贡献

欢迎贡献！请随时提交 Pull Request。

## 许可证

本项目采用 MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。
