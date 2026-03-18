# Create gateway directories
New-Item -ItemType Directory -Path serv -Force
New-Item -ItemType Directory -Path coder1 -Force
New-Item -ItemType Directory -Path coder2 -Force

# Build and start Docker containers
docker-compose up -d --build

# Show deployment info
Write-Host "OpenClaw multi-gateway deployment completed!"
Write-Host ""
Write-Host "Access addresses:"
Write-Host "Serv: http://localhost:42700"
Write-Host "Coder1: No external port mapping"
Write-Host "Coder2: No external port mapping"
Write-Host ""
Write-Host "Check container status: docker-compose ps"
Write-Host "Check container logs: docker-compose logs -f"
