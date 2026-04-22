# Despliegue de OpenClaw con Docker

[![Language](https://img.shields.io/badge/Language-English-blue)](./README.en.md)
[![Language](https://img.shields.io/badge/Language-中文-red)](./README.zh.md)
[![Language](https://img.shields.io/badge/Language-日本語-green)](./README.ja.md)
[![Language](https://img.shields.io/badge/Language-Español-orange)](./README.es.md)
[![Language](https://img.shields.io/badge/Language-Français-purple)](./README.fr.md)
[![Language](https://img.shields.io/badge/Language-Deutsch-yellow)](./README.de.md)

## Sitio Web Oficial

- [https://ggsheng.com](https://ggsheng.com)
- [https://ggsheng.org](https://ggsheng.org)

## Versión

- Versión actual: v2026.4.4
- Versión anterior: v2026.4.3

## Descripción General

Este proyecto proporciona una solución de despliegue basada en Docker para OpenClaw con múltiples gateways independientes. Soporta despliegue rápido, gestión sencilla y rendimiento optimizado utilizando fuentes de espejo domésticas.

## Características

- **Despliegue multi-gateway**: Ejecuta múltiples gateways OpenClaw independientes en contenedores separados
- **Configuración dinámica**: Configuración flexible de servicios, puertos y volúmenes mediante archivo .env
- **Fuentes de espejo domésticas**: Optimizado para descargas rápidas de dependencias en China
- **Gestión sencilla**: Scripts proporcionados para iniciar, detener, reiniciar y corregir permisos
- **Modo privilegiado**: Permisos mejorados para mejor rendimiento
- **Verificaciones de salud**: Monitoreo automático de la salud de los contenedores
- **Imagen base configurable**: Soporte para imágenes base personalizadas vía .env
- **Control de versión OpenClaw**: Especifica la versión de instalación de OpenClaw
- **Soporte multiidioma**: Rust, Go, Python con espejos domésticos
- **Aceleración de espejo Docker Hub**: Soporte para múltiples fuentes de espejo
- **Soporte de configuración SSH**: Soporte para montaje de directorio .ssh para configuración SSH
- **Configuración de Supervisor**: Soporte para configuración de directorio supervisor/conf.d
- **Instalación de herramientas de contenedor**: Instalación opcional de Docker, Podman, Docker Compose
- **Instalación tolerante a fallos**: La falla en instalación de herramientas no afecta la creación del contenedor
- **Aceleración de espejo Rustup**: Soporte para espejos domésticos en descarga de toolchain Rust
- **Soporte Ollama**: Instalación opcional de Ollama con aceleración de espejo doméstico
- **Soporte VLLM**: Instalación opcional de VLLM con espejo pip doméstico
- **Soporte uv**: Instalación opcional de uv (gestor de paquetes Python) con aceleración de proxy GitHub
- **Optimización de PATH**: Deduplicación y optimización automática de PATH
- **Optimización de espejo npm**: Configuración completa de .npmrc con 50+ espejos de herramientas comunes
- **Deshabilitar auditoría de seguridad**: Soporte para deshabilitar npm audit para instalación más rápida

## Requisitos Previos

- Docker 20.0+
- Docker Compose 1.29+
- Windows (PowerShell) o Linux/Mac (bash)

## Inicio Rápido

### Windows

1. Clona este repositorio
2. Navega al directorio del proyecto
3. Configura el archivo `.env` (opcional)
4. Ejecuta el script de inicio:
   ```powershell
   .\start.ps1
   ```

### Linux/Mac

1. Clona este repositorio
2. Navega al directorio del proyecto
3. Configura el archivo `.env` (opcional)
4. Haz los scripts ejecutables:
   ```bash
   chmod +x *.sh
   ```
5. Ejecuta el script de inicio:
   ```bash
   ./start.sh
   ```

## Estructura de Directorios

```
openclaw_docker/
├── .env                    # Archivo de configuración de variables de entorno
├── .npmrc                  # Configuración npm con espejo
├── Dockerfile              # Archivo de construcción Docker
├── docker-compose.yml      # Configuración de Docker Compose (generado dinámicamente)
├── sources.list            # Fuentes APT con espejos domésticos
├── configure_sources.sh    # Script de configuración de fuentes APT
├── update_hosts.sh         # Script de actualización de Hosts de GitHub
├── entrypoint.sh           # Script de entrada del contenedor
├── generate-compose.sh     # Generar docker-compose.yml (Linux/Mac)
├── generate-compose.ps1    # Generar docker-compose.yml (Windows)
├── fix_permissions.sh      # Corregir permisos de directorios (Linux/Mac)
├── fix_permissions.ps1     # Corregir permisos de directorios (Windows)
├── start.sh                # Script de inicio (Linux/Mac)
├── start.ps1               # Script de inicio (Windows)
├── stop.sh                 # Script de detención (Linux/Mac)
├── stop.ps1                # Script de detención (Windows)
├── restart.sh              # Script de reinicio (Linux/Mac)
└── restart.ps1             # Script de reinicio (Windows)
```

## Configuración

### Variables de Entorno (archivo .env)

Configura servicios mediante el archivo `.env`:

```env
# Configuración de imagen base
BASE_IMAGE=ghcr.m.daocloud.io/openclaw/openclaw:latest

# Configuración de versión OpenClaw
OPENCLAW_VERSION=latest

# Configuración de servicios
GATEWAY_SERVICES=serv,coder1,coder2,coder3

# Configuración de puertos
GATEWAY_PORTS=serv:42700

# Configuración de volúmenes adicionales
GATEWAY_VOLUMES=
```

### Lista Completa de Variables de Entorno

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `BASE_IMAGE` | Dirección de imagen base Docker | `ghcr.m.daocloud.io/openclaw/openclaw:latest` |
| `OPENCLAW_VERSION` | Versión de instalación de OpenClaw | `latest` |
| `GATEWAY_SERVICES` | Lista de servicios, separados por comas | `serv,coder1,coder2,coder3` |
| `GATEWAY_PORTS` | Mapeo de puertos, formato: `servicio:puerto` | Vacío |
| `GATEWAY_VOLUMES` | Mapeo de volúmenes adicionales, formato: `servicio:ruta_host:ruta_contenedor` | Vacío |
| `CONTAINER_MEM_LIMIT` | Límite de memoria del contenedor | `8g` |
| `CONTAINER_RESTART_POLICY` | Política de reinicio del contenedor | `unless-stopped` |
| `CONTAINER_HOME` | Directorio home del usuario del contenedor | `/home/node` |
| `TZ` | Configuración de zona horaria | `Asia/Shanghai` |
| `npm_config_registry` | Fuente de espejo npm | `https://registry.npmmirror.com/` |
| `pnpm_config_registry` | Fuente de espejo pnpm | `https://registry.npmmirror.com/` |
| `PIP_MIRROR` | Fuente de espejo pip (tuna/aliyun/douban) | `tuna` |
| `RUST_VERSION` | Versión de Rust | `stable` |
| `RUSTUP_MIRROR` | Espejo de rustup de Rust (tuna/ustc) | `tuna` |
| `RUST_CRATES_MIRROR` | Espejo de crates.io de Rust (tuna/ustc/rsproxy) | `tuna` |
| `GO_VERSION` | Versión de Go | `1.25.8` |
| `GOPROXY_MIRRORS` | Espejos de proxy de módulos Go | `goproxy.cn,goproxy.io,direct` |
| `DOCKER_HUB_MIRRORS` | Aceleración de espejo Docker Hub | `daocloud,aliyun,tuna` |
| `INSTALL_DOCKER` | Si instalar Docker (true/false) | `false` |
| `INSTALL_PODMAN` | Si instalar Podman (true/false) | `true` |
| `INSTALL_DOCKER_COMPOSE` | Si instalar Docker Compose (true/false) | `false` |
| `DOCKER_COMPOSE_VERSION` | Versión de Docker Compose | `latest` |
| `LOG_MAX_SIZE` | Tamaño máximo de archivo de registro | `10m` |
| `LOG_MAX_FILE` | Número máximo de archivos de registro | `3` |
| `HEALTHCHECK_INTERVAL` | Intervalo de verificación de salud | `30s` |
| `HEALTHCHECK_TIMEOUT` | Tiempo de espera de verificación de salud | `10s` |
| `HEALTHCHECK_START_PERIOD` | Período de inicio de verificación de salud | `5s` |
| `HEALTHCHECK_RETRIES` | Reintentos de verificación de salud | `3` |
| `NETWORK_MODE` | Modo de red | `bridge` |
| `OPENCLAW_NODE_ENV` | Entorno de ejecución de OpenClaw | `production` |

## Uso de Scripts

### Script de Generación de Configuración

- `generate-compose.sh` / `generate-compose.ps1`: Genera docker-compose.yml basado en configuración .env
  ```bash
  # Generar archivo de configuración
  ./generate-compose.sh
  ```

### Script de Corrección de Permisos

- `fix_permissions.sh` / `fix_permissions.ps1`: Crea y corrige permisos de directorios de servicios
  ```bash
  # Corregir permisos de directorios de todos los servicios
  ./fix_permissions.sh
  ```

### Scripts de Inicio

- `start.sh` / `start.ps1`: Inicia todos los contenedores
  ```bash
  # Iniciar todos los contenedores
  ./start.sh
  ```

### Scripts de Detención

- `stop.sh` / `stop.ps1`: Detiene todos los contenedores o un contenedor específico
  ```bash
  # Detener todos los contenedores
  ./stop.sh
  
  # Detener contenedor específico
  ./stop.sh serv
  ```

### Scripts de Reinicio

- `restart.sh` / `restart.ps1`: Reinicia todos los contenedores o un contenedor específico
  ```bash
  # Reiniciar todos los contenedores
  ./restart.sh
  
  # Reiniciar contenedor específico
  ./restart.sh serv
  ```

## Ejemplos de Configuración de Servicios Personalizados

### Ejemplo 1: Lista de Servicios Personalizados

```env
# Definir tres servicios personalizados
GATEWAY_SERVICES=sme1,sme2,serv
```

### Ejemplo 2: Configurar Mapeo de Puertos

```env
GATEWAY_SERVICES=serv,coder1
GATEWAY_PORTS=serv:42700,coder1:42800
```

### Ejemplo 3: Agregar Volúmenes Adicionales

```env
GATEWAY_SERVICES=serv
GATEWAY_VOLUMES=serv:/data/volumes:/data,serv:/opt/config:/app/config
```

### Ejemplo 4: Especificar Versión de OpenClaw

```env
# Instalar versión específica de OpenClaw
OPENCLAW_VERSION=2026.3.24
```

### Ejemplo 5: Usar Imagen Base Oficial

```env
# Usar imagen oficial de OpenClaw
BASE_IMAGE=ghcr.io/openclaw/openclaw:latest
```

## Direcciones de Acceso

Basado en la configuración de `GATEWAY_PORTS`, por defecto:

- Los servicios con mapeo de puertos configurado pueden ser accedidos a través de los puertos correspondientes
- Los servicios sin mapeo de puertos configurado solo soportan acceso interno

## Solución de Problemas

### Descargas lentas de apt

El proyecto usa apt con fuentes de espejo domésticas para acelerar descargas. Si aún experimentas lentitud, considera:

1. Verificar tu conexión de red
2. Usar una VPN si es necesario
3. Verificar las fuentes de espejo en `sources.list`

### Problemas de inicio de contenedores

Verifica los registros del contenedor para errores:

```bash
docker-compose logs -f
```

### Problemas de permisos

Si encuentras problemas de permisos, ejecuta el script de corrección de permisos:

```bash
./fix_permissions.sh
```

## Contribuciones

¡Las contribuciones son bienvenidas! Por favor, siéntete libre de enviar un Pull Request.

---

## 💖 Apóyanos

Si este proyecto te ayuda, ¡considera invitarnos a un café para apoyar el desarrollo y mantenimiento continuo!

<div align="center">

### ☕ Invítanos a un Café

¡Tu apoyo nos impulsa a seguir adelante!

<img src="./images/weixin_pay.jpg" alt="WeChat Pay" width="280" style="border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">

**Escanea con WeChat para apoyar el código abierto** 🙏

</div>

---

## Licencia

Este proyecto está licenciado bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.
