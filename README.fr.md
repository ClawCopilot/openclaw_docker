# Déploiement OpenClaw avec Docker

[![Language](https://img.shields.io/badge/Language-English-blue)](./README.en.md)
[![Language](https://img.shields.io/badge/Language-中文-red)](./README.zh.md)
[![Language](https://img.shields.io/badge/Language-日本語-green)](./README.ja.md)
[![Language](https://img.shields.io/badge/Language-Español-orange)](./README.es.md)
[![Language](https://img.shields.io/badge/Language-Français-purple)](./README.fr.md)
[![Language](https://img.shields.io/badge/Language-Deutsch-yellow)](./README.de.md)

## Site Web Officiel

- [https://ggsheng.com](https://ggsheng.com)
- [https://ggsheng.org](https://ggsheng.org)

## Version

- Version actuelle : v2026.4.4
- Version précédente : v2026.4.3

## Vue d'ensemble

Ce projet fournit une solution de déploiement basée sur Docker pour OpenClaw avec plusieurs passerelles indépendantes. Il prend en charge le déploiement rapide, la gestion facile et les performances optimisées en utilisant des sources miroir domestiques.

## Fonctionnalités

- **Déploiement multi-passerelle** : Exécutez plusieurs passerelles OpenClaw indépendantes dans des conteneurs séparés
- **Configuration dynamique** : Configuration flexible des services, ports et volumes via le fichier .env
- **Sources miroir domestiques** : Optimisé pour les téléchargements rapides de dépendances en Chine
- **Gestion facile** : Scripts fournis pour démarrer, arrêter, redémarrer et corriger les permissions
- **Mode privilégié** : Permissions améliorées pour de meilleures performances
- **Vérifications de santé** : Surveillance automatique de la santé des conteneurs
- **Image base configurable** : Prise en charge des images base personnalisées via .env
- **Contrôle de version OpenClaw** : Spécifiez la version d'installation d'OpenClaw
- **Support multilingue** : Rust, Go, Python avec miroirs domestiques
- **Accélération miroir Docker Hub** : Prise en charge de plusieurs sources miroir
- **Support de configuration SSH** : Prise en charge du montage du répertoire .ssh pour la configuration SSH
- **Configuration Supervisor** : Prise en charge de la configuration du répertoire supervisor/conf.d
- **Installation d'outils de conteneur** : Installation optionnelle de Docker, Podman, Docker Compose
- **Installation tolérante aux pannes** : L'échec de l'installation d'outils n'affecte pas la création du conteneur
- **Accélération miroir Rustup** : Prise en charge des miroirs domestiques pour le téléchargement de la chaîne d'outils Rust
- **Support Ollama** : Installation optionnelle d'Ollama avec accélération de miroir domestique
- **Support VLLM** : Installation optionnelle de VLLM avec miroir pip domestique
- **Support uv** : Installation optionnelle de uv (gestionnaire de paquets Python) avec accélération de proxy GitHub
- **Optimisation PATH** : Déduplication et optimisation automatique de PATH
- **Optimisation miroir npm** : Configuration complète de .npmrc avec 50+ miroirs d'outils courants
- **Désactivation de l'audit de sécurité** : Prise en charge de la désactivation de npm audit pour une installation plus rapide

## Prérequis

- Docker 20.0+
- Docker Compose 1.29+
- Windows (PowerShell) ou Linux/Mac (bash)

## Démarrage Rapide

### Windows

1. Clonez ce dépôt
2. Naviguez vers le répertoire du projet
3. Configurez le fichier `.env` (optionnel)
4. Exécutez le script de démarrage :
   ```powershell
   .\start.ps1
   ```

### Linux/Mac

1. Clonez ce dépôt
2. Naviguez vers le répertoire du projet
3. Configurez le fichier `.env` (optionnel)
4. Rendez les scripts exécutables :
   ```bash
   chmod +x *.sh
   ```
5. Exécutez le script de démarrage :
   ```bash
   ./start.sh
   ```

## Structure des Répertoires

```
openclaw_docker/
├── .env                    # Fichier de configuration des variables d'environnement
├── .npmrc                  # Configuration npm avec miroir
├── Dockerfile              # Fichier de construction Docker
├── docker-compose.yml      # Configuration Docker Compose (générée dynamiquement)
├── sources.list            # Sources APT avec miroirs domestiques
├── configure_sources.sh    # Script de configuration des sources APT
├── update_hosts.sh         # Script de mise à jour des hôtes GitHub
├── entrypoint.sh           # Script d'entrée du conteneur
├── generate-compose.sh     # Générer docker-compose.yml (Linux/Mac)
├── generate-compose.ps1    # Générer docker-compose.yml (Windows)
├── fix_permissions.sh      # Corriger les permissions des répertoires (Linux/Mac)
├── fix_permissions.ps1     # Corriger les permissions des répertoires (Windows)
├── start.sh                # Script de démarrage (Linux/Mac)
├── start.ps1               # Script de démarrage (Windows)
├── stop.sh                 # Script d'arrêt (Linux/Mac)
├── stop.ps1                # Script d'arrêt (Windows)
├── restart.sh              # Script de redémarrage (Linux/Mac)
└── restart.ps1             # Script de redémarrage (Windows)
```

## Configuration

### Variables d'Environnement (fichier .env)

Configurez les services via le fichier `.env` :

```env
# Configuration de l'image base
BASE_IMAGE=ghcr.m.daocloud.io/openclaw/openclaw:latest

# Configuration de la version OpenClaw
OPENCLAW_VERSION=latest

# Configuration des services
GATEWAY_SERVICES=serv,coder1,coder2,coder3

# Configuration des ports
GATEWAY_PORTS=serv:42700

# Configuration des volumes supplémentaires
GATEWAY_VOLUMES=
```

### Liste Complète des Variables d'Environnement

| Variable | Description | Valeur par Défaut |
|----------|-------------|-------------------|
| `BASE_IMAGE` | Adresse de l'image base Docker | `ghcr.m.daocloud.io/openclaw/openclaw:latest` |
| `OPENCLAW_VERSION` | Version d'installation d'OpenClaw | `latest` |
| `GATEWAY_SERVICES` | Liste des services, séparés par des virgules | `serv,coder1,coder2,coder3` |
| `GATEWAY_PORTS` | Mappage de ports, format : `service:port` | Vide |
| `GATEWAY_VOLUMES` | Mappage de volumes supplémentaires, format : `service:chemin_hôte:chemin_conteneur` | Vide |
| `CONTAINER_MEM_LIMIT` | Limite de mémoire du conteneur | `8g` |
| `CONTAINER_RESTART_POLICY` | Politique de redémarrage du conteneur | `unless-stopped` |
| `CONTAINER_HOME` | Répertoire home de l'utilisateur du conteneur | `/home/node` |
| `TZ` | Configuration du fuseau horaire | `Asia/Shanghai` |
| `npm_config_registry` | Source miroir npm | `https://registry.npmmirror.com/` |
| `pnpm_config_registry` | Source miroir pnpm | `https://registry.npmmirror.com/` |
| `PIP_MIRROR` | Source miroir pip (tuna/aliyun/douban) | `tuna` |
| `RUST_VERSION` | Version de Rust | `stable` |
| `RUSTUP_MIRROR` | Miroir rustup de Rust (tuna/ustc) | `tuna` |
| `RUST_CRATES_MIRROR` | Miroir crates.io de Rust (tuna/ustc/rsproxy) | `tuna` |
| `GO_VERSION` | Version de Go | `1.25.8` |
| `GOPROXY_MIRRORS` | Miroirs de proxy de modules Go | `goproxy.cn,goproxy.io,direct` |
| `DOCKER_HUB_MIRRORS` | Accélération de miroir Docker Hub | `daocloud,aliyun,tuna` |
| `INSTALL_DOCKER` | Si installer Docker (true/false) | `false` |
| `INSTALL_PODMAN` | Si installer Podman (true/false) | `true` |
| `INSTALL_DOCKER_COMPOSE` | Si installer Docker Compose (true/false) | `false` |
| `DOCKER_COMPOSE_VERSION` | Version de Docker Compose | `latest` |
| `LOG_MAX_SIZE` | Taille maximale du fichier de journal | `10m` |
| `LOG_MAX_FILE` | Nombre maximal de fichiers de journal | `3` |
| `HEALTHCHECK_INTERVAL` | Intervalle de vérification de santé | `30s` |
| `HEALTHCHECK_TIMEOUT` | Délai d'attente de vérification de santé | `10s` |
| `HEALTHCHECK_START_PERIOD` | Période de démarrage de vérification de santé | `5s` |
| `HEALTHCHECK_RETRIES` | Tentatives de vérification de santé | `3` |
| `NETWORK_MODE` | Mode réseau | `bridge` |
| `OPENCLAW_NODE_ENV` | Environnement d'exécution d'OpenClaw | `production` |

## Utilisation des Scripts

### Script de Génération de Configuration

- `generate-compose.sh` / `generate-compose.ps1` : Génère docker-compose.yml basé sur la configuration .env
  ```bash
  # Générer le fichier de configuration
  ./generate-compose.sh
  ```

### Script de Correction des Permissions

- `fix_permissions.sh` / `fix_permissions.ps1` : Crée et corrige les permissions des répertoires de services
  ```bash
  # Corriger les permissions des répertoires de tous les services
  ./fix_permissions.sh
  ```

### Scripts de Démarrage

- `start.sh` / `start.ps1` : Démarre tous les conteneurs
  ```bash
  # Démarrer tous les conteneurs
  ./start.sh
  ```

### Scripts d'Arrêt

- `stop.sh` / `stop.ps1` : Arrête tous les conteneurs ou un conteneur spécifique
  ```bash
  # Arrêter tous les conteneurs
  ./stop.sh
  
  # Arrêter un conteneur spécifique
  ./stop.sh serv
  ```

### Scripts de Redémarrage

- `restart.sh` / `restart.ps1` : Redémarre tous les conteneurs ou un conteneur spécifique
  ```bash
  # Redémarrer tous les conteneurs
  ./restart.sh
  
  # Redémarrer un conteneur spécifique
  ./restart.sh serv
  ```

## Exemples de Configuration de Services Personnalisés

### Exemple 1 : Liste de Services Personnalisés

```env
# Définir trois services personnalisés
GATEWAY_SERVICES=sme1,sme2,serv
```

### Exemple 2 : Configurer le Mappage de Ports

```env
GATEWAY_SERVICES=serv,coder1
GATEWAY_PORTS=serv:42700,coder1:42800
```

### Exemple 3 : Ajouter des Volumes Supplémentaires

```env
GATEWAY_SERVICES=serv
GATEWAY_VOLUMES=serv:/data/volumes:/data,serv:/opt/config:/app/config
```

### Exemple 4 : Spécifier la Version d'OpenClaw

```env
# Installer une version spécifique d'OpenClaw
OPENCLAW_VERSION=2026.3.24
```

### Exemple 5 : Utiliser l'Image Base Officielle

```env
# Utiliser l'image officielle d'OpenClaw
BASE_IMAGE=ghcr.io/openclaw/openclaw:latest
```

## Adresses d'Accès

Basé sur la configuration de `GATEWAY_PORTS`, par défaut :

- Les services avec mappage de ports configuré peuvent être accédés via les ports correspondants
- Les services sans mappage de ports configuré ne prennent en charge que l'accès interne

## Dépannage

### Téléchargements lents d'apt

Le projet utilise apt avec des sources miroir domestiques pour accélérer les téléchargements. Si vous rencontrez toujours des lenteurs, envisagez de :

1. Vérifier votre connexion réseau
2. Utiliser un VPN si nécessaire
3. Vérifier les sources miroir dans `sources.list`

### Problèmes de démarrage des conteneurs

Vérifiez les journaux du conteneur pour les erreurs :

```bash
docker-compose logs -f
```

### Problèmes de permissions

Si vous rencontrez des problèmes de permissions, exécutez le script de correction des permissions :

```bash
./fix_permissions.sh
```

## Contributions

Les contributions sont les bienvenues ! N'hésitez pas à soumettre une Pull Request.

---

## 💖 Soutenez-nous

Si ce projet vous aide, envisagez de nous offrir un café pour soutenir le développement et la maintenance continus !

<div align="center">

### ☕ Offrez-nous un Café

Votre soutien nous fait avancer !

<img src="./images/weixin_pay.jpg" alt="WeChat Pay" width="280" style="border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">

**Scannez avec WeChat pour soutenir l'open source** 🙏

</div>

---

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
