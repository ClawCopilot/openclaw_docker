param(
    [string]$ContainerName = "all"
)

# 定义支持的容器名称
$ValidContainers = @("serv", "coder1", "coder2")

# 检查容器名称是否有效
if ($ContainerName -ne "all" -and $ValidContainers -notcontains $ContainerName) {
    Write-Host "Error: Invalid container name. Valid containers are: all, serv, coder1, coder2"
    exit 1
}

# 停止容器
if ($ContainerName -eq "all") {
    Write-Host "Stopping all OpenClaw containers..."
    docker-compose down
} else {
    Write-Host "Stopping container: $ContainerName..."
    docker-compose stop $ContainerName
}

# 显示状态
Write-Host ""
Write-Host "Container status:"
docker-compose ps

Write-Host ""
Write-Host "Done."
