# OpenClaw Docker Deployment

## Language Versions

- [English](./README.en.md)
- [中文](./README.zh.md)
- [日本語](./README.ja.md)

## Official Website

- [https://ggsheng.com](https://ggsheng.com)
- [https://ggsheng.org](https://ggsheng.org)

## Version

- Current version: v2026.3.30

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

## Quick Start

### Windows

```powershell
.\start.ps1
```

### Linux/Mac

```bash
chmod +x *.sh
./start.sh
```

## Configuration

Configure services through the `.env` file:

```env
# Base image configuration
BASE_IMAGE=ghcr.m.daocloud.io/openclaw/openclaw:latest

# OpenClaw version
OPENCLAW_VERSION=latest

# Service configuration
GATEWAY_SERVICES=serv,coder1,coder2,coder3

# Port configuration
GATEWAY_PORTS=serv:42700

# Additional volumes configuration
GATEWAY_VOLUMES=
```

## Scripts

| Script | Description |
|--------|-------------|
| `generate-compose.sh/ps1` | Generate docker-compose.yml based on .env |
| `fix_permissions.sh/ps1` | Create and fix service directory permissions |
| `start.sh/ps1` | Start all containers |
| `stop.sh/ps1` | Stop all or specific container |
| `restart.sh/ps1` | Restart all or specific container |

## Documentation

For detailed documentation, please refer to:

- [English Documentation](./README.en.md)
- [中文文档](./README.zh.md)
- [日本語ドキュメント](./README.ja.md)

## License

This project is licensed under the MIT License.
