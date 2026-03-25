# OpenClaw Docker Deployment

[![Language](https://img.shields.io/badge/Language-English-blue)](./README.en.md)
[![Language](https://img.shields.io/badge/Language-中文-red)](./README.zh.md)
[![Language](https://img.shields.io/badge/Language-日本語-green)](./README.ja.md)

## Version

- Current version: v2026.3.25

## Overview

This project provides a Docker-based deployment solution for OpenClaw with multiple independent gateways. It supports fast deployment, easy management, and optimized performance using domestic mirror sources.

## Features

- **Multi-gateway deployment**: Run multiple independent OpenClaw gateways in separate containers
- **Dynamic configuration**: Flexible service, port, and volume configuration via .env file
- **Domestic mirror sources**: Optimized for fast dependency downloads in China
- **Easy management**: Provided start, stop, restart, and permission fix scripts
- **Privileged mode**: Enhanced permissions for better performance
- **Health checks**: Automatic health monitoring for containers

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
├── .gitconfig              # Git configuration with mirror
├── .npmrc                  # npm configuration with mirror
├── Dockerfile              # Docker build file
├── docker-compose.yml      # Docker Compose configuration (dynamically generated)
├── sources.list            # APT sources with domestic mirrors
├── configure_sources.sh    # APT sources configuration script
├── update_hosts.sh         # GitHub Hosts update script
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
# Service configuration
# Format: GATEWAY_SERVICES=service1,service2,service3
GATEWAY_SERVICES=serv,coder1,coder2,coder3

# Port configuration
# Format: GATEWAY_PORTS=service1:port1,service2:port2
GATEWAY_PORTS=serv:42700

# Additional volumes configuration
# Format: GATEWAY_VOLUMES=service1:/host/path1:/container/path1,service2:/host/path2:/container/path2
GATEWAY_VOLUMES=
```

### Complete Environment Variables List

| Variable | Description | Default |
|----------|-------------|---------|
| `GATEWAY_SERVICES` | Service list, comma-separated | `serv,coder1,coder2,coder3` |
| `GATEWAY_PORTS` | Port mapping, format: `service:port` | Empty |
| `GATEWAY_VOLUMES` | Additional volume mapping, format: `service:host_path:container_path` | Empty |
| `CONTAINER_MEM_LIMIT` | Container memory limit | `2g` |
| `CONTAINER_RESTART_POLICY` | Container restart policy | `unless-stopped` |
| `TZ` | Timezone setting | `Asia/Shanghai` |
| `npm_config_registry` | npm mirror source | `https://registry.npmmirror.com/` |
| `pnpm_config_registry` | pnpm mirror source | `https://registry.npmmirror.com/` |
| `pip_config_index_url` | pip mirror source | `https://pypi.tuna.tsinghua.edu.cn/simple` |
| `git_config_url` | git mirror source | `https://github.com.cnpmjs.org` |
| `LOG_MAX_SIZE` | Maximum log file size | `10m` |
| `LOG_MAX_FILE` | Maximum number of log files | `3` |
| `HEALTHCHECK_INTERVAL` | Health check interval | `30s` |
| `HEALTHCHECK_TIMEOUT` | Health check timeout | `10s` |
| `HEALTHCHECK_START_PERIOD` | Health check start period | `5s` |
| `HEALTHCHECK_RETRIES` | Health check retries | `3` |
| `NETWORK_MODE` | Network mode | `bridge` |
| `OPENCLAW_NODE_ENV` | OpenClaw runtime environment | `production` |

### Dockerfile

- Uses Node.js 22 slim image as base
- Installs dependencies using apt for faster downloads
- Uses domestic mirror sources for apt, npm, pip, and git
- Globally installs OpenClaw using npm
- Includes GitHub Hosts update script (update_hosts.sh) with 5-hour cron job

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

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
