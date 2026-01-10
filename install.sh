#!/bin/bash

# OHIF + Orthanc 自动安装脚本

set -e

echo "========================================="
echo "  OHIF + Orthanc 自动安装脚本"
echo "========================================="
echo ""

# 检查是否为 root 或可以使用 sudo
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  需要 sudo 权限来安装 Docker"
    echo "正在尝试使用 sudo..."
    if ! sudo -n true 2>/dev/null; then
        echo "请输入您的 sudo 密码以继续安装..."
    fi
fi

echo "📦 步骤 1/4: 更新系统包列表..."
if [ "$EUID" -eq 0 ]; then
    apt update
else
    sudo apt update
fi

echo "📦 步骤 2/4: 安装 Docker 和 Docker Compose..."
if [ "$EUID" -eq 0 ]; then
    apt install -y docker.io docker-compose
else
    sudo apt install -y docker.io docker-compose
fi

echo "🔧 步骤 3/4: 启动 Docker 服务..."
if [ "$EUID" -eq 0 ]; then
    systemctl start docker
    systemctl enable docker
else
    sudo systemctl start docker
    sudo systemctl enable docker
fi

echo "🌐 步骤 4/4: 创建 Docker 网络 'pacs'..."
if [ "$EUID" -eq 0 ]; then
    docker network create pacs 2>/dev/null || echo "网络 'pacs' 已存在，跳过创建"
else
    sudo docker network create pacs 2>/dev/null || echo "网络 'pacs' 已存在，跳过创建"
fi

echo ""
echo "✅ Docker 安装完成！"
echo ""
echo "🔍 检查 Docker 版本..."
if [ "$EUID" -eq 0 ]; then
    docker --version
    docker compose version
else
    sudo docker --version
    sudo docker compose version
fi

echo ""
echo "========================================="
echo "  开始启动 OHIF + Orthanc 服务..."
echo "========================================="
echo ""

# 检查用户是否在 docker 组中
if [ "$EUID" -ne 0 ]; then
    if groups | grep -q docker; then
        echo "✓ 当前用户已在 docker 组中，可以直接使用 docker 命令"
        docker compose up -d
    else
        echo "⚠️  当前用户不在 docker 组中，使用 sudo 启动服务..."
        echo "   要避免使用 sudo，请运行: sudo usermod -aG docker $USER && newgrp docker"
        sudo docker compose up -d
    fi
else
    docker compose up -d
fi

echo ""
echo "========================================="
echo "  ✅ 安装和启动完成！"
echo "========================================="
echo ""
echo "📱 访问地址："
echo "   - OHIF Viewer:  http://localhost:3000"
echo "   - Orthanc Web UI: http://localhost:8042"
echo ""
echo "📊 查看服务状态："
if groups | grep -q docker 2>/dev/null || [ "$EUID" -eq 0 ]; then
    echo "   docker compose ps"
else
    echo "   sudo docker compose ps"
fi
echo ""
echo "📝 查看日志："
if groups | grep -q docker 2>/dev/null || [ "$EUID" -eq 0 ]; then
    echo "   docker compose logs -f"
else
    echo "   sudo docker compose logs -f"
fi
echo ""

