# OpenClaw Docker Deployment

[![Language](https://img.shields.io/badge/Language-English-blue)](./README.en.md)
[![Language](https://img.shields.io/badge/Language-中文-red)](./README.zh.md)
[![Language](https://img.shields.io/badge/Language-日本語-green)](./README.ja.md)

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

## Directory Structure

```
openclaw_docker/
├── .gitconfig          # Git configuration with mirror
├── .npmrc             # npm configuration with mirror
├── Dockerfile         # Docker build file
├── docker-compose.yml  # Docker Compose configuration
├── sources.list        # APT sources with domestic mirrors
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
- Installs dependencies using apt-fast for faster downloads
- Uses domestic mirror sources for apt, npm, pip, and git
- Globally installs OpenClaw using pnpm

### Docker Compose

- Defines three services: serv, coder1, coder2
- Serv is exposed on port 42700
- Each service has its own data volume
- All services run in privileged mode

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

- `NODE_ENV`: production
- `npm_config_registry`: https://registry.npmmirror.com/
- `pnpm_config_registry`: https://registry.npmmirror.com/
- `PYTHONUNBUFFERED`: 1

## Troubleshooting

### Slow apt downloads

The project uses apt-fast with domestic mirror sources to accelerate downloads. If you still experience slow speeds, consider:

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
