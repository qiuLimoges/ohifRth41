#!/bin/bash

# 诊断脚本 - 检查服务状态和连接问题

echo "========================================="
echo "  OHIF + Orthanc 诊断脚本"
echo "========================================="
echo ""

# 检查Docker服务
echo "1. 检查 Docker 服务状态..."
if systemctl is-active --quiet docker 2>/dev/null || sudo systemctl is-active --quiet docker 2>/dev/null; then
    echo "   ✓ Docker 服务正在运行"
else
    echo "   ✗ Docker 服务未运行"
    echo "   请运行: sudo systemctl start docker"
    exit 1
fi

# 检查容器状态
echo ""
echo "2. 检查容器状态..."
if docker ps &>/dev/null || sudo docker ps &>/dev/null; then
    if command -v docker-compose &>/dev/null; then
        DOCKER_COMPOSE_CMD="docker-compose"
    elif docker compose version &>/dev/null 2>&1; then
        DOCKER_COMPOSE_CMD="docker compose"
    elif sudo docker compose version &>/dev/null 2>&1; then
        DOCKER_COMPOSE_CMD="sudo docker compose"
    else
        DOCKER_COMPOSE_CMD="sudo docker-compose"
    fi
    
    echo "   使用命令: $DOCKER_COMPOSE_CMD"
    $DOCKER_COMPOSE_CMD ps
    
    # 检查容器是否运行
    ORTHANC_RUNNING=$(docker ps --filter name=orthanc --format "{{.Names}}" 2>/dev/null || sudo docker ps --filter name=orthanc --format "{{.Names}}" 2>/dev/null)
    OHIF_RUNNING=$(docker ps --filter name=ohif --format "{{.Names}}" 2>/dev/null || sudo docker ps --filter name=ohif --format "{{.Names}}" 2>/dev/null)
    
    if [ -z "$ORTHANC_RUNNING" ]; then
        echo "   ⚠️  Orthanc 容器未运行"
    else
        echo "   ✓ Orthanc 容器正在运行: $ORTHANC_RUNNING"
    fi
    
    if [ -z "$OHIF_RUNNING" ]; then
        echo "   ⚠️  OHIF 容器未运行"
    else
        echo "   ✓ OHIF 容器正在运行: $OHIF_RUNNING"
    fi
else
    echo "   ⚠️  无法访问 Docker (可能需要 sudo)"
    echo "   运行: sudo $0"
    exit 1
fi

# 检查端口监听
echo ""
echo "3. 检查端口监听状态..."
if command -v ss &>/dev/null; then
    SS_CMD="ss"
elif command -v sudo &>/dev/null && sudo ss &>/dev/null 2>&1; then
    SS_CMD="sudo ss"
else
    SS_CMD=""
fi

if [ -n "$SS_CMD" ]; then
    echo "   检查端口 3000 (OHIF):"
    $SS_CMD -tlnp | grep ':3000' || echo "   ⚠️  端口 3000 未监听"
    
    echo "   检查端口 8042 (Orthanc):"
    $SS_CMD -tlnp | grep ':8042' || echo "   ⚠️  端口 8042 未监听"
    
    echo "   检查端口 4242 (DICOM):"
    $SS_CMD -tlnp | grep ':4242' || echo "   ⚠️  端口 4242 未监听"
fi

# 检查防火墙
echo ""
echo "4. 检查防火墙状态..."
if command -v ufw &>/dev/null; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null | head -1)
    echo "   $UFW_STATUS"
    if echo "$UFW_STATUS" | grep -q "Status: active"; then
        echo "   ⚠️  防火墙已启用，可能需要开放端口:"
        echo "      sudo ufw allow 3000/tcp"
        echo "      sudo ufw allow 8042/tcp"
        echo "      sudo ufw allow 4242/tcp"
    fi
fi

# 测试本地连接
echo ""
echo "5. 测试本地连接..."
echo "   测试 OHIF (localhost:3000):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null | grep -q "200\|301\|302"; then
    echo "   ✓ OHIF 本地连接正常"
else
    echo "   ✗ OHIF 本地连接失败"
fi

echo "   测试 Orthanc (localhost:8042):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8042 2>/dev/null | grep -q "200\|301\|302"; then
    echo "   ✓ Orthanc 本地连接正常"
else
    echo "   ✗ Orthanc 本地连接失败"
fi

# 测试外部IP连接
echo ""
echo "6. 测试外部IP连接 (192.168.1.172)..."
echo "   测试 OHIF (192.168.1.172:3000):"
if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 http://192.168.1.172:3000 2>/dev/null | grep -q "200\|301\|302"; then
    echo "   ✓ OHIF 外部连接正常"
else
    echo "   ✗ OHIF 外部连接失败 (可能是防火墙问题)"
fi

echo "   测试 Orthanc (192.168.1.172:8042):"
if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 http://192.168.1.172:8042 2>/dev/null | grep -q "200\|301\|302"; then
    echo "   ✓ Orthanc 外部连接正常"
else
    echo "   ✗ Orthanc 外部连接失败 (可能是防火墙问题)"
fi

# 查看容器日志
echo ""
echo "7. 查看最近的容器日志..."
if [ -n "$DOCKER_COMPOSE_CMD" ]; then
    echo "   Orthanc 日志 (最后10行):"
    $DOCKER_COMPOSE_CMD logs --tail=10 pacs 2>/dev/null || echo "   无法获取日志"
    
    echo ""
    echo "   OHIF 日志 (最后10行):"
    $DOCKER_COMPOSE_CMD logs --tail=10 ohif_viewer 2>/dev/null || echo "   无法获取日志"
fi

echo ""
echo "========================================="
echo "  诊断完成"
echo "========================================="

