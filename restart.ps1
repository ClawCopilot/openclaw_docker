param(
    [string]$ContainerName = "all"
)

# 定义支持的容器名称
$ValidContainers = @("serv", "coder1", "coder2", "coder3")

# 检查容器名称是否有效
if ($ContainerName -ne "all" -and $ValidContainers -notcontains $ContainerName) {
    Write-Host "Error: Invalid container name. Valid containers are: all, serv, coder1, coder2, coder3"
    exit 1
}

# 重启容器
if ($ContainerName -eq "all") {
    Write-Host "Restarting all OpenClaw containers..."
    docker-compose restart
} else {
    Write-Host "Restarting container: $ContainerName..."
    docker-compose restart $ContainerName
}

# 显示状态
Write-Host ""
Write-Host "Container status:"
docker-compose ps

Write-Host ""
Write-Host "Done."
