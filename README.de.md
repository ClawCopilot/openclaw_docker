# OpenClaw Docker-Bereitstellung

[![Language](https://img.shields.io/badge/Language-English-blue)](./README.en.md)
[![Language](https://img.shields.io/badge/Language-中文-red)](./README.zh.md)
[![Language](https://img.shields.io/badge/Language-日本語-green)](./README.ja.md)
[![Language](https://img.shields.io/badge/Language-Español-orange)](./README.es.md)
[![Language](https://img.shields.io/badge/Language-Français-purple)](./README.fr.md)
[![Language](https://img.shields.io/badge/Language-Deutsch-yellow)](./README.de.md)

## Offizielle Website

- [https://ggsheng.com](https://ggsheng.com)
- [https://ggsheng.org](https://ggsheng.org)

## Version

- Aktuelle Version: v2026.4.4
- Vorherige Version: v2026.4.3

## Übersicht

Dieses Projekt bietet eine Docker-basierte Bereitstellungslösung für OpenClaw mit mehreren unabhängigen Gateways. Es unterstützt schnelle Bereitstellung, einfache Verwaltung und optimierte Leistung unter Verwendung inländischer Spiegelquellen.

## Funktionen

- **Multi-Gateway-Bereitstellung**: Führen Sie mehrere unabhängige OpenClaw-Gateways in separaten Containern aus
- **Dynamische Konfiguration**: Flexible Konfiguration von Diensten, Ports und Volumes über .env-Datei
- **Inländische Spiegelquellen**: Optimiert für schnelle Abhängigkeitsdownloads in China
- **Einfache Verwaltung**: Bereitgestellte Skripte zum Starten, Stoppen, Neustarten und Korrigieren von Berechtigungen
- **Privilegierter Modus**: Erweiterte Berechtigungen für bessere Leistung
- **Gesundheitsprüfungen**: Automatische Überwachung der Container-Gesundheit
- **Konfigurierbares Basis-Image**: Unterstützung für benutzerdefinierte Basis-Images über .env
- **OpenClaw-Versionskontrolle**: Geben Sie die OpenClaw-Installationsversion an
- **Mehrsprachige Unterstützung**: Rust, Go, Python mit inländischen Spiegeln
- **Docker Hub-Spiegelbeschleunigung**: Unterstützung für mehrere Spiegelquellen
- **SSH-Konfigurationsunterstützung**: Unterstützung für .ssh-Verzeichnis-Mount für SSH-Konfiguration
- **Supervisor-Konfiguration**: Unterstützung für supervisor/conf.d-Verzeichniskonfiguration
- **Container-Tools-Installation**: Optionale Installation von Docker, Podman, Docker Compose
- **Fehlertolerante Installation**: Tool-Installationsfehler beeinträchtigen die Container-Erstellung nicht
- **Rustup-Spiegelbeschleunigung**: Unterstützung für inländische Spiegel für Rust-Toolchain-Download
- **Ollama-Unterstützung**: Optionale Ollama-Installation mit inländischer Spiegelbeschleunigung
- **VLLM-Unterstützung**: Optionale VLLM-Installation mit inländischem pip-Spiegel
- **uv-Unterstützung**: Optionale uv-Installation (Python-Paketmanager) mit GitHub-Proxy-Beschleunigung
- **PATH-Optimierung**: Automatische PATH-Deduplizierung und -Optimierung
- **npm-Spiegeloptimierung**: Vollständige .npmrc-Konfiguration mit 50+ gängigen Tool-Spiegeln
- **Sicherheitsaudit deaktivieren**: Unterstützung zum Deaktivieren von npm audit für schnellere Installation

## Voraussetzungen

- Docker 20.0+
- Docker Compose 1.29+
- Windows (PowerShell) oder Linux/Mac (bash)

## Schnellstart

### Windows

1. Klonen Sie dieses Repository
2. Navigieren Sie zum Projektverzeichnis
3. Konfigurieren Sie die `.env`-Datei (optional)
4. Führen Sie das Startskript aus:
   ```powershell
   .\start.ps1
   ```

### Linux/Mac

1. Klonen Sie dieses Repository
2. Navigieren Sie zum Projektverzeichnis
3. Konfigurieren Sie die `.env`-Datei (optional)
4. Machen Sie die Skripte ausführbar:
   ```bash
   chmod +x *.sh
   ```
5. Führen Sie das Startskript aus:
   ```bash
   ./start.sh
   ```

## Verzeichnisstruktur

```
openclaw_docker/
├── .env                    # Umgebungsvariablen-Konfigurationsdatei
├── .npmrc                  # npm-Konfiguration mit Spiegel
├── Dockerfile              # Docker-Build-Datei
├── docker-compose.yml      # Docker Compose-Konfiguration (dynamisch generiert)
├── sources.list            # APT-Quellen mit inländischen Spiegeln
├── configure_sources.sh    # APT-Quellen-Konfigurationsskript
├── update_hosts.sh         # GitHub Hosts-Aktualisierungsskript
├── entrypoint.sh           # Container-Entrypoint-Skript
├── generate-compose.sh     # Generiere docker-compose.yml (Linux/Mac)
├── generate-compose.ps1    # Generiere docker-compose.yml (Windows)
├── fix_permissions.sh      # Verzeichnisberechtigungen korrigieren (Linux/Mac)
├── fix_permissions.ps1     # Verzeichnisberechtigungen korrigieren (Windows)
├── start.sh                # Startskript (Linux/Mac)
├── start.ps1               # Startskript (Windows)
├── stop.sh                 # Stopskript (Linux/Mac)
├── stop.ps1                # Stopskript (Windows)
├── restart.sh              # Neustartskript (Linux/Mac)
└── restart.ps1             # Neustartskript (Windows)
```

## Konfiguration

### Umgebungsvariablen (.env-Datei)

Konfigurieren Sie Dienste über die `.env`-Datei:

```env
# Basis-Image-Konfiguration
BASE_IMAGE=ghcr.m.daocloud.io/openclaw/openclaw:latest

# OpenClaw-Versionskonfiguration
OPENCLAW_VERSION=latest

# Dienstkonfiguration
GATEWAY_SERVICES=serv,coder1,coder2,coder3

# Portkonfiguration
GATEWAY_PORTS=serv:42700

# Zusätzliche Volume-Konfiguration
GATEWAY_VOLUMES=
```

### Vollständige Liste der Umgebungsvariablen

| Variable | Beschreibung | Standardwert |
|----------|--------------|--------------|
| `BASE_IMAGE` | Docker Basis-Image-Adresse | `ghcr.m.daocloud.io/openclaw/openclaw:latest` |
| `OPENCLAW_VERSION` | OpenClaw-Installationsversion | `latest` |
| `GATEWAY_SERVICES` | Dienstliste, kommagetrennt | `serv,coder1,coder2,coder3` |
| `GATEWAY_PORTS` | Port-Zuordnung, Format: `dienst:port` | Leer |
| `GATEWAY_VOLUMES` | Zusätzliche Volume-Zuordnung, Format: `dienst:host_pfad:container_pfad` | Leer |
| `CONTAINER_MEM_LIMIT` | Container-Speicherlimit | `8g` |
| `CONTAINER_RESTART_POLICY` | Container-Neustartrichtlinie | `unless-stopped` |
| `CONTAINER_HOME` | Container-Benutzer-Home-Verzeichnis | `/home/node` |
| `TZ` | Zeitzoneneinstellung | `Asia/Shanghai` |
| `npm_config_registry` | npm-Spiegelquelle | `https://registry.npmmirror.com/` |
| `pnpm_config_registry` | pnpm-Spiegelquelle | `https://registry.npmmirror.com/` |
| `PIP_MIRROR` | pip-Spiegelquelle (tuna/aliyun/douban) | `tuna` |
| `RUST_VERSION` | Rust-Version | `stable` |
| `RUSTUP_MIRROR` | Rust rustup-Spiegel (tuna/ustc) | `tuna` |
| `RUST_CRATES_MIRROR` | Rust crates.io-Spiegel (tuna/ustc/rsproxy) | `tuna` |
| `GO_VERSION` | Go-Version | `1.25.8` |
| `GOPROXY_MIRRORS` | Go-Modul-Proxy-Spiegel | `goproxy.cn,goproxy.io,direct` |
| `DOCKER_HUB_MIRRORS` | Docker Hub-Spiegelbeschleunigung | `daocloud,aliyun,tuna` |
| `INSTALL_DOCKER` | Ob Docker installiert werden soll (true/false) | `false` |
| `INSTALL_PODMAN` | Ob Podman installiert werden soll (true/false) | `true` |
| `INSTALL_DOCKER_COMPOSE` | Ob Docker Compose installiert werden soll (true/false) | `false` |
| `DOCKER_COMPOSE_VERSION` | Docker Compose-Version | `latest` |
| `LOG_MAX_SIZE` | Maximale Protokolldateigröße | `10m` |
| `LOG_MAX_FILE` | Maximale Anzahl von Protokolldateien | `3` |
| `HEALTHCHECK_INTERVAL` | Gesundheitsprüfungsintervall | `30s` |
| `HEALTHCHECK_TIMEOUT` | Gesundheitsprüfungs-Timeout | `10s` |
| `HEALTHCHECK_START_PERIOD` | Gesundheitsprüfungs-Startzeitraum | `5s` |
| `HEALTHCHECK_RETRIES` | Gesundheitsprüfungs-Wiederholungen | `3` |
| `NETWORK_MODE` | Netzwerkmodus | `bridge` |
| `OPENCLAW_NODE_ENV` | OpenClaw-Laufzeitumgebung | `production` |

## Skriptverwendung

### Konfigurationsgenerierungsskript

- `generate-compose.sh` / `generate-compose.ps1`: Generiert docker-compose.yml basierend auf .env-Konfiguration
  ```bash
  # Konfigurationsdatei generieren
  ./generate-compose.sh
  ```

### Berechtigungskorrekturskript

- `fix_permissions.sh` / `fix_permissions.ps1`: Erstellt und korrigiert Dienstverzeichnisberechtigungen
  ```bash
  # Berechtigungen für alle Dienstverzeichnisse korrigieren
  ./fix_permissions.sh
  ```

### Startskripte

- `start.sh` / `start.ps1`: Startet alle Container
  ```bash
  # Alle Container starten
  ./start.sh
  ```

### Stopskripte

- `stop.sh` / `stop.ps1`: Stoppt alle Container oder einen bestimmten Container
  ```bash
  # Alle Container stoppen
  ./stop.sh
  
  # Bestimmten Container stoppen
  ./stop.sh serv
  ```

### Neustartskripte

- `restart.sh` / `restart.ps1`: Startet alle Container oder einen bestimmten Container neu
  ```bash
  # Alle Container neu starten
  ./restart.sh
  
  # Bestimmten Container neu starten
  ./restart.sh serv
  ```

## Beispiele für Benutzerdefinierte Dienstkonfiguration

### Beispiel 1: Benutzerdefinierte Dienstliste

```env
# Drei benutzerdefinierte Dienste definieren
GATEWAY_SERVICES=sme1,sme2,serv
```

### Beispiel 2: Port-Zuordnung konfigurieren

```env
GATEWAY_SERVICES=serv,coder1
GATEWAY_PORTS=serv:42700,coder1:42800
```

### Beispiel 3: Zusätzliche Volumes hinzufügen

```env
GATEWAY_SERVICES=serv
GATEWAY_VOLUMES=serv:/data/volumes:/data,serv:/opt/config:/app/config
```

### Beispiel 4: OpenClaw-Version angeben

```env
# Bestimmte OpenClaw-Version installieren
OPENCLAW_VERSION=2026.3.24
```

### Beispiel 5: Offizielles Basis-Image verwenden

```env
# Offizielles OpenClaw-Image verwenden
BASE_IMAGE=ghcr.io/openclaw/openclaw:latest
```

## Zugriffsadressen

Basierend auf der `GATEWAY_PORTS`-Konfiguration, standardmäßig:

- Dienste mit konfigurierter Port-Zuordnung können über die entsprechenden Ports aufgerufen werden
- Dienste ohne konfigurierte Port-Zuordnung unterstützen nur internen Zugriff

## Fehlerbehebung

### Langsame apt-Downloads

Das Projekt verwendet apt mit inländischen Spiegelquellen, um Downloads zu beschleunigen. Wenn Sie weiterhin Langsamkeit erleben, erwägen Sie:

1. Überprüfung Ihrer Netzwerkverbindung
2. Verwendung eines VPNs falls erforderlich
3. Überprüfung der Spiegelquellen in `sources.list`

### Container-Startprobleme

Überprüfen Sie die Container-Protokolle auf Fehler:

```bash
docker-compose logs -f
```

### Berechtigungsprobleme

Wenn Sie auf Berechtigungsprobleme stoßen, führen Sie das Berechtigungskorrekturskript aus:

```bash
./fix_permissions.sh
```

## Beiträge

Beiträge sind willkommen! Bitte zögern Sie nicht, einen Pull Request einzureichen.

---

## 💖 Unterstützen Sie uns

Wenn dieses Projekt Ihnen hilft, erwägen Sie, uns einen Kaffee zu spendieren, um die kontinuierliche Entwicklung und Wartung zu unterstützen!

<div align="center">

### ☕ Spendieren Sie uns einen Kaffee

Ihre Unterstützung treibt uns voran!

<img src="./images/weixin_pay.jpg" alt="WeChat Pay" width="280" style="border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">

**Scannen Sie mit WeChat, um Open Source zu unterstützen** 🙏

</div>

---

## Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert. Siehe die [LICENSE](LICENSE)-Datei für Details.
