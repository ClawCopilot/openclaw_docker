#!/bin/bash

# Create gateway directories
mkdir -p serv coder1 coder2

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
echo "Check container status: docker-compose ps"
echo "Check container logs: docker-compose logs -f"
