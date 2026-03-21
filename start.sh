#!/bin/bash

# Change to the directory where this script is located
cd "$(dirname "$0")"
echo "Changed working directory to: $(pwd)"

# Create gateway directories
gateways=("serv" "coder1" "coder2" "coder3")
dirs=(".openclaw" "workspace" "apps")
for gateway in "${gateways[@]}"; do
    for dir in "${dirs[@]}"; do
        mkdir -p "$gateway/$dir"
        chown -R 1000:1000 "$gateway/$dir"
    done
done

# Create bettwen gateway share directoris
mkdir -p "share"
chown -R 1000:1000 "share"

# Build and start Docker containers
docker-compose up -d --build
# Show deployment info
echo "OpenClaw multi-gateway deployment completed!"
echo ""
echo "Access addresses:"
echo "Serv: http://localhost:${SERV_PORT:-42700}"
echo "Coder1: No external port mapping"
echo "Coder2: No external port mapping"
echo "Coder3: No external port mapping"
echo """Waiting 15 seconds for containers to start..."
sleep 15

echo "Check container status: docker-compose ps"
docker-compose ps

echo "Check container logs: docker-compose logs -f"
docker-compose logs -f