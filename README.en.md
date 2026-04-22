# OpenClaw Docker Deployment

[![Language](https://img.shields.io/badge/Language-English-blue)](./README.en.md)
[![Language](https://img.shields.io/badge/Language-中文-red)](./README.zh.md)
[![Language](https://img.shields.io/badge/Language-日本語-green)](./README.ja.md)
[![Language](https://img.shields.io/badge/Language-Español-orange)](./README.es.md)
[![Language](https://img.shields.io/badge/Language-Français-purple)](./README.fr.md)
[![Language](https://img.shields.io/badge/Language-Deutsch-yellow)](./README.de.md)

## Official Website

- [https://ggsheng.com](https://ggsheng.com)
- [https://ggsheng.org](https://ggsheng.org)

## Version

- Current version: v2026.4.4
- Previous version: v2026.4.3

## Overview

This project provides a Docker-based deployment solution for OpenClaw with multiple independent gateways. It supports fast deployment, easy management, and optimized performance using domestic mirror sources.

## Features

- **Multi-gateway deployment**: Run multiple independent OpenClaw gateways in separate containers
- **Dynamic configuration**: Flexible service, port, and volume configuration via .env file
- **Domestic mirror sources**: Optimized for fast dependency downloads in China
- **Easy management**: Provided start, stop, restart, and permission fix scripts
- **Privileged mode**: Enhanced permissions for better performance
- **Health checks**: Automatic health monitoring for containers
- **Configurable base image**: Support custom base images via .env
- **OpenClaw version control**: Specify OpenClaw installation version
- **Multi-language support**: Rust, Go, Python with domestic mirrors
- **Docker Hub mirror acceleration**: Multiple mirror sources support
- **SSH configuration support**: Support .ssh directory mount for SSH configuration
- **Supervisor configuration**: Support supervisor/conf.d directory configuration
- **Container tools installation**: Optional installation of Docker, Podman, Docker Compose
- **Fault-tolerant installation**: Tool installation failure does not affect container creation
- **Rustup mirror acceleration**: Support domestic mirrors for Rust toolchain download
- **Ollama support**: Optional Ollama installation with domestic mirror acceleration
- **VLLM support**: Optional VLLM installation with domestic pip mirror
- **uv support**: Optional uv (Python package manager) installation with GitHub proxy acceleration
- **PATH optimization**: Automatic PATH deduplication and optimization
- **npm mirror optimization**: Complete .npmrc configuration with 50+ common tool mirrors
- **Security audit disable**: Support disabling npm audit for faster installation

## Prerequisites

- Docker 20.0+ 
- Docker Compose 1.29+ 
- Windows (PowerShell) or Linux/Mac (bash)

## Quick Start

### Windows

1. Clone this repository
2. Navigate to the project directory
3. Configure `.env` file (optional)
4. Run the start script:
   ```powershell
   .\start.ps1
   ```

### Linux/Mac

1. Clone this repository
2. Navigate to the project directory
3. Configure `.env` file (optional)
4. Make the scripts executable:
   ```bash
   chmod +x *.sh
   ```
5. Run the start script:
   ```bash
   ./start.sh
   ```

## Directory Structure

```
openclaw_docker/
├── .env                    # Environment variable configuration file
├── .npmrc                  # npm configuration with mirror
├── Dockerfile              # Docker build file
├── docker-compose.yml      # Docker Compose configuration (dynamically generated)
├── sources.list            # APT sources with domestic mirrors
├── configure_sources.sh    # APT sources configuration script
├── update_hosts.sh         # GitHub Hosts update script
├── entrypoint.sh           # Container entrypoint script
├── generate-compose.sh     # Generate docker-compose.yml (Linux/Mac)
├── generate-compose.ps1    # Generate docker-compose.yml (Windows)
├── fix_permissions.sh      # Fix directory permissions (Linux/Mac)
├── fix_permissions.ps1     # Fix directory permissions (Windows)
├── start.sh                # Start script (Linux/Mac)
├── start.ps1               # Start script (Windows)
├── stop.sh                 # Stop script (Linux/Mac)
├── stop.ps1                # Stop script (Windows)
├── restart.sh              # Restart script (Linux/Mac)
└── restart.ps1             # Restart script (Windows)
```

## Configuration

### Environment Variables (.env file)

Configure services through the `.env` file:

```env
# Base image configuration
BASE_IMAGE=ghcr.m.daocloud.io/openclaw/openclaw:latest

# OpenClaw version configuration
OPENCLAW_VERSION=latest

# Service configuration
GATEWAY_SERVICES=serv,coder1,coder2,coder3

# Port configuration
GATEWAY_PORTS=serv:42700

# Additional volumes configuration
GATEWAY_VOLUMES=
```

### Complete Environment Variables List

| Variable | Description | Default |
|----------|-------------|---------|
| `BASE_IMAGE` | Docker base image address | `ghcr.m.daocloud.io/openclaw/openclaw:latest` |
| `OPENCLAW_VERSION` | OpenClaw installation version | `latest` |
| `GATEWAY_SERVICES` | Service list, comma-separated | `serv,coder1,coder2,coder3` |
| `GATEWAY_PORTS` | Port mapping, format: `service:port` | Empty |
| `GATEWAY_VOLUMES` | Additional volume mapping, format: `service:host_path:container_path` | Empty |
| `CONTAINER_MEM_LIMIT` | Container memory limit | `8g` |
| `CONTAINER_RESTART_POLICY` | Container restart policy | `unless-stopped` |
| `CONTAINER_HOME` | Container user home directory | `/home/node` |
| `TZ` | Timezone setting | `Asia/Shanghai` |
| `npm_config_registry` | npm mirror source | `https://registry.npmmirror.com/` |
| `pnpm_config_registry` | pnpm mirror source | `https://registry.npmmirror.com/` |
| `PIP_MIRROR` | pip mirror source (tuna/aliyun/douban) | `tuna` |
| `RUST_VERSION` | Rust version | `stable` |
| `RUSTUP_MIRROR` | Rust rustup mirror (tuna/ustc) | `tuna` |
| `RUST_CRATES_MIRROR` | Rust crates.io mirror (tuna/ustc/rsproxy) | `tuna` |
| `GO_VERSION` | Go version | `1.25.8` |
| `GOPROXY_MIRRORS` | Go module proxy mirrors | `goproxy.cn,goproxy.io,direct` |
| `DOCKER_HUB_MIRRORS` | Docker Hub mirror acceleration | `daocloud,aliyun,tuna` |
| `INSTALL_DOCKER` | Whether to install Docker (true/false) | `false` |
| `INSTALL_PODMAN` | Whether to install Podman (true/false) | `true` |
| `INSTALL_DOCKER_COMPOSE` | Whether to install Docker Compose (true/false) | `false` |
| `DOCKER_COMPOSE_VERSION` | Docker Compose version | `latest` |
| `LOG_MAX_SIZE` | Maximum log file size | `10m` |
| `LOG_MAX_FILE` | Maximum number of log files | `3` |
| `HEALTHCHECK_INTERVAL` | Health check interval | `30s` |
| `HEALTHCHECK_TIMEOUT` | Health check timeout | `10s` |
| `HEALTHCHECK_START_PERIOD` | Health check start period | `5s` |
| `HEALTHCHECK_RETRIES` | Health check retries | `3` |
| `NETWORK_MODE` | Network mode | `bridge` |
| `OPENCLAW_NODE_ENV` | OpenClaw runtime environment | `production` |

### Dockerfile

- Supports custom base images via BASE_IMAGE argument
- Checks and creates node user if not exists
- Installs dependencies using apt for faster downloads
- Uses domestic mirror sources for apt, npm, pip, Rust, and Go
- Supports configurable OpenClaw version installation
- Includes GitHub Hosts update script with cron job
- Includes entrypoint script for automatic OpenClaw installation
- Supports optional installation of Docker, Podman, Docker Compose
- Fault-tolerant installation: tool installation failure does not affect container creation
- Supports Rustup domestic mirror acceleration
- Supports brew installed but PATH not configured scenario

## Script Usage

### Generate Configuration Script

- `generate-compose.sh` / `generate-compose.ps1`: Generate docker-compose.yml based on .env configuration
  ```bash
  # Generate configuration file
  ./generate-compose.sh
  ```

### Permission Fix Script

- `fix_permissions.sh` / `fix_permissions.ps1`: Create and fix service directory permissions
  ```bash
  # Fix all service directory permissions
  ./fix_permissions.sh
  ```

### Start Scripts

- `start.sh` / `start.ps1`: Start all containers
  ```bash
  # Start all containers
  ./start.sh
  ```

### Stop Scripts

- `stop.sh` / `stop.ps1`: Stop all containers or a specific container
  ```bash
  # Stop all containers
  ./stop.sh
  
  # Stop specific container
  ./stop.sh serv
  ```

### Restart Scripts

- `restart.sh` / `restart.ps1`: Restart all containers or a specific container
  ```bash
  # Restart all containers
  ./restart.sh
  
  # Restart specific container
  ./restart.sh serv
  ```

## Custom Service Configuration Examples

### Example 1: Custom Service List

```env
# Define three custom services
GATEWAY_SERVICES=sme1,sme2,serv
```

### Example 2: Configure Port Mapping

```env
GATEWAY_SERVICES=serv,coder1
GATEWAY_PORTS=serv:42700,coder1:42800
```

### Example 3: Add Additional Volumes

```env
GATEWAY_SERVICES=serv
GATEWAY_VOLUMES=serv:/data/volumes:/data,serv:/opt/config:/app/config
```

### Example 4: Specify OpenClaw Version

```env
# Install specific OpenClaw version
OPENCLAW_VERSION=2026.3.24
```

### Example 5: Use Official Base Image

```env
# Use official OpenClaw image
BASE_IMAGE=ghcr.io/openclaw/openclaw:latest
```

## Access Addresses

Based on `GATEWAY_PORTS` configuration, by default:

- Services with port mapping configured can be accessed through the corresponding ports
- Services without port mapping configured only support internal access

## Troubleshooting

### Slow apt downloads

The project uses apt with domestic mirror sources to accelerate downloads. If you still experience slow speeds, consider:

1. Checking your network connection
2. Using a VPN if necessary
3. Verifying the mirror sources in `sources.list`

### Container startup issues

Check container logs for errors:

```bash
docker-compose logs -f
```

### Permission issues

If you encounter permission issues, run the permission fix script:

```bash
./fix_permissions.sh
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 💖 Support Us

If this project helps you, consider buying us a coffee to support continued development and maintenance!

<div align="center">

### ☕ Buy Us a Coffee

Your support drives us forward!

<img src="./images/weixin_pay.jpg" alt="WeChat Pay" width="280" style="border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">

**Scan with WeChat to support open source** 🙏

</div>

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
