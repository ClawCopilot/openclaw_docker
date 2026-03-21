# OpenClaw Docker Deployment

[![Language](https://img.shields.io/badge/Language-English-blue)](./README.en.md)
[![Language](https://img.shields.io/badge/Language-中文-red)](./README.zh.md)
[![Language](https://img.shields.io/badge/Language-日本語-green)](./README.ja.md)

## Version

- Current version: v1.1.1

## Overview

This project provides a Docker-based deployment solution for OpenClaw with multiple independent gateways. It supports fast deployment, easy management, and optimized performance using domestic mirror sources.

## Features

- **Multi-gateway deployment**: Run multiple independent OpenClaw gateways in separate containers
- **Domestic mirror sources**: Optimized for fast dependency downloads in China
- **Easy management**: Provided start, stop, and restart scripts
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
3. Run the start script:
   ```powershell
   .\start.ps1
   ```

### Linux/Mac

1. Clone this repository
2. Navigate to the project directory
3. Make the script executable:
   ```bash
   chmod +x start.sh
   ```
4. Run the start script:
   ```bash
   ./start.sh
   ```

## Access Addresses

- **Serv**: http://localhost:42700
- **Coder1**: No external port mapping (internal access only)
- **Coder2**: No external port mapping (internal access only)
- **Coder3**: No external port mapping (internal access only)

## Directory Structure

```
openclaw_docker/
├── .gitconfig          # Git configuration with mirror
├── .npmrc             # npm configuration with mirror
├── Dockerfile         # Docker build file
├── docker-compose.yml  # Docker Compose configuration
├── sources.list        # APT sources with domestic mirrors
├── configure_sources.sh  # APT sources configuration script
├── update_hosts.sh     # GitHub Hosts update script
├── start.ps1          # Windows start script
├── start.sh           # Linux/Mac start script
├── stop.ps1           # Windows stop script
├── stop.sh            # Linux/Mac stop script
├── restart.ps1        # Windows restart script
└── restart.sh         # Linux/Mac restart script
```

## Configuration

### Dockerfile

- Uses Node.js 22 slim image as base
- Installs dependencies using apt for faster downloads
- Uses domestic mirror sources for apt, npm, pip, and git
- Globally installs OpenClaw using npm
- Includes GitHub Hosts update script (update_hosts.sh) with 5-hour cron job

### Docker Compose

- Defines four services: serv, coder1, coder2, coder3
- Serv is exposed on port 42700
- Each service has its own data volume
- All services run in privileged mode
- Uses environment variables for configuration, supports custom configuration via .env file

## Script Usage

### Start Scripts

- `start.ps1` / `start.sh`: Start all containers

### Stop Scripts

- `stop.ps1` / `stop.sh`: Stop all containers or specific container
  ```powershell
  # Stop all containers
  .\stop.ps1
  
  # Stop specific container
  .\stop.ps1 serv
  ```

### Restart Scripts

- `restart.ps1` / `restart.sh`: Restart all containers or specific container
  ```powershell
  # Restart all containers
  .\restart.ps1
  
  # Restart specific container
  .\restart.ps1 serv
  ```

## Environment Variables

Configure the following environment variables through .env file:

- `SERV_PORT`: External port for Serv service, default 42700
- `CONTAINER_MEM_LIMIT`: Container memory limit, default 2g
- `CONTAINER_RESTART_POLICY`: Container restart policy, default unless-stopped
- `TZ`: Timezone setting, default Asia/Shanghai
- `npm_config_registry`: npm mirror source, default https://registry.npmmirror.com/
- `pnpm_config_registry`: pnpm mirror source, default https://registry.npmmirror.com/
- `pip_config_index_url`: pip mirror source, default https://pypi.tuna.tsinghua.edu.cn/simple
- `git_config_url`: git mirror source, default https://github.com.cnpmjs.org
- `LOG_MAX_SIZE`: Maximum log file size, default 10m
- `LOG_MAX_FILE`: Maximum number of log files, default 3
- `HEALTHCHECK_INTERVAL`: Health check interval, default 30s
- `HEALTHCHECK_TIMEOUT`: Health check timeout, default 10s
- `HEALTHCHECK_START_PERIOD`: Health check start period, default 5s
- `HEALTHCHECK_RETRIES`: Health check retries, default 3
- `NETWORK_MODE`: Network mode, default bridge
- `OPENCLAW_NODE_ENV`: OpenClaw runtime environment, default production

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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
