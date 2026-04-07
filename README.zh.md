# OpenClaw Docker 部署

[![Language](https://img.shields.io/badge/Language-English-blue)](./README.en.md)
[![Language](https://img.shields.io/badge/Language-中文-red)](./README.zh.md)
[![Language](https://img.shields.io/badge/Language-日本語-green)](./README.ja.md)

## 官方网站

- [https://ggsheng.com](https://ggsheng.com)
- [https://ggsheng.org](https://ggsheng.org)

## 版本

- 当前版本：v2026.4.4
- 上一版本：v2026.4.3

## 项目概述

本项目提供了一个基于 Docker 的 OpenClaw 多网关独立部署解决方案。它支持快速部署、易于管理，并使用国内镜像源优化性能。

## 功能特性

- **多网关部署**：在独立容器中运行多个 OpenClaw 网关
- **动态配置**：通过 .env 文件灵活配置服务、端口和卷
- **国内镜像源**：针对中国环境优化，加速依赖下载
- **易于管理**：提供启动、停止、重启和权限修复脚本
- **特权模式**：增强权限以获得更好的性能
- **健康检查**：自动监控容器健康状态
- **可配置基础镜像**：通过 .env 支持自定义基础镜像
- **OpenClaw 版本控制**：指定 OpenClaw 安装版本
- **多语言支持**：Rust、Go、Python 国内镜像加速
- **Docker Hub 镜像加速**：支持多镜像源配置
- **SSH 配置支持**：支持 .ssh 目录挂载配置 SSH
- **Supervisor 配置**：支持 supervisor/conf.d 目录配置
- **容器工具安装**：可选安装 Docker、Podman、Docker Compose
- **容错安装机制**：工具安装失败不影响容器创建
- **Rustup 镜像加速**：支持国内镜像加速 Rust 工具链下载
- **Ollama 支持**：可选安装 Ollama，支持国内镜像加速
- **VLLM 支持**：可选安装 VLLM，支持国内 pip 镜像
- **uv 支持**：可选安装 uv (Python 包管理器)，支持 GitHub 代理加速
- **PATH 优化**：自动整理 PATH 环境变量，去除重复路径
- **npm 镜像优化**：完整的 .npmrc 配置，支持 50+ 常用工具镜像
- **安全审核禁用**：支持禁用 npm audit 加速安装

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
├── .npmrc                  # 带镜像的 npm 配置
├── Dockerfile              # Docker 构建文件
├── docker-compose.yml      # Docker Compose 配置（动态生成）
├── sources.list            # 带国内镜像的 APT 源
├── configure_sources.sh    # APT 源配置脚本
├── update_hosts.sh         # GitHub Hosts 更新脚本
├── entrypoint.sh           # 容器入口脚本
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
# 基础镜像配置
BASE_IMAGE=ghcr.m.daocloud.io/openclaw/openclaw:latest

# OpenClaw 版本配置
OPENCLAW_VERSION=latest

# 服务配置
GATEWAY_SERVICES=serv,coder1,coder2,coder3

# 端口配置
GATEWAY_PORTS=serv:42700

# 额外 volumes 配置
GATEWAY_VOLUMES=
```

### 完整环境变量列表

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `BASE_IMAGE` | Docker 基础镜像地址 | `ghcr.m.daocloud.io/openclaw/openclaw:latest` |
| `OPENCLAW_VERSION` | OpenClaw 安装版本 | `latest` |
| `GATEWAY_SERVICES` | 服务列表，逗号分隔 | `serv,coder1,coder2,coder3` |
| `GATEWAY_PORTS` | 端口映射，格式：`服务名:端口` | 空 |
| `GATEWAY_VOLUMES` | 额外卷映射，格式：`服务名:主机路径:容器路径` | 空 |
| `CONTAINER_MEM_LIMIT` | 容器内存限制 | `8g` |
| `CONTAINER_RESTART_POLICY` | 容器重启策略 | `unless-stopped` |
| `CONTAINER_HOME` | 容器内用户主目录 | `/home/node` |
| `TZ` | 时区设置 | `Asia/Shanghai` |
| `npm_config_registry` | npm 镜像源 | `https://registry.npmmirror.com/` |
| `pnpm_config_registry` | pnpm 镜像源 | `https://registry.npmmirror.com/` |
| `PIP_MIRROR` | pip 镜像源 (tuna/aliyun/douban) | `tuna` |
| `RUST_VERSION` | Rust 版本 | `stable` |
| `RUSTUP_MIRROR` | Rust rustup 镜像 (tuna/ustc) | `tuna` |
| `RUST_CRATES_MIRROR` | Rust crates.io 镜像 (tuna/ustc/rsproxy) | `tuna` |
| `GO_VERSION` | Go 版本 | `1.25.8` |
| `GOPROXY_MIRRORS` | Go 模块代理镜像 | `goproxy.cn,goproxy.io,direct` |
| `DOCKER_HUB_MIRRORS` | Docker Hub 镜像加速 | `daocloud,aliyun,tuna` |
| `INSTALL_DOCKER` | 是否安装 Docker (true/false) | `false` |
| `INSTALL_PODMAN` | 是否安装 Podman (true/false) | `true` |
| `INSTALL_DOCKER_COMPOSE` | 是否安装 Docker Compose (true/false) | `false` |
| `DOCKER_COMPOSE_VERSION` | Docker Compose 版本 | `latest` |
| `LOG_MAX_SIZE` | 日志文件最大大小 | `10m` |
| `LOG_MAX_FILE` | 日志文件最大数量 | `3` |
| `HEALTHCHECK_INTERVAL` | 健康检查间隔 | `30s` |
| `HEALTHCHECK_TIMEOUT` | 健康检查超时 | `10s` |
| `HEALTHCHECK_START_PERIOD` | 健康检查启动期 | `5s` |
| `HEALTHCHECK_RETRIES` | 健康检查重试次数 | `3` |
| `NETWORK_MODE` | 网络模式 | `bridge` |
| `OPENCLAW_NODE_ENV` | OpenClaw 运行环境 | `production` |

### Dockerfile

- 支持通过 BASE_IMAGE 参数自定义基础镜像
- 检测并创建 node 用户（如不存在）
- 使用 apt 安装依赖以加快下载速度
- 使用国内镜像源加速 apt、npm、pip、Rust 和 Go
- 支持配置 OpenClaw 安装版本
- 包含 GitHub Hosts 更新脚本和定时任务
- 包含入口脚本自动安装 OpenClaw
- 支持可选安装 Docker、Podman、Docker Compose
- 容错安装机制：工具安装失败不影响容器创建
- 支持 Rustup 国内镜像加速
- 支持 brew 已安装但未配置 PATH 的情况

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

### 示例 4：指定 OpenClaw 版本

```env
# 安装指定版本的 OpenClaw
OPENCLAW_VERSION=2026.3.24
```

### 示例 5：使用官方基础镜像

```env
# 使用官方 OpenClaw 镜像
BASE_IMAGE=ghcr.io/openclaw/openclaw:latest
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

---

## 💖 支持我们

如果这个项目对您有帮助，欢迎打赏支持我们继续开发和维护！

<div align="center">

### ☕ 请作者喝杯咖啡

您的每一份支持都是我们前进的动力！

<img src="./images/weixin_pay.jpg" alt="微信打赏" width="280" style="border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">

**微信扫一扫，支持开源项目** 🙏

</div>

---

## 许可证

本项目采用 MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。
