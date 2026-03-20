#!/bin/bash

# Create gateway directories
mkdir -p serv/.openclaw coder1/.openclaw coder2/.openclaw
mkdir -p serv/workspace coder1/workspace coder2/workspace

# Build and start Docker containers
docker-compose up -d --build

# Show deployment info
echo "OpenClaw multi-gateway deployment completed!"
echo ""
echo "Access addresses:"
echo "Serv: http://localhost:42700"
echo "Coder1: No external port mapping"
echo "Coder2: No external port mapping"
echo ""
echo "Waiting 15 seconds for containers to start..."
sleep 15

echo "Check container status: docker-compose ps"
docker-compose ps

echo "Check container logs: docker-compose logs -f"
docker-compose logs -f