#!/bin/bash

# 修复连接问题脚本

set -e

echo "========================================="
echo "  修复 OHIF + Orthanc 连接问题"
echo "========================================="
echo ""

# 检查Docker命令
if command -v docker-compose &>/dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version &>/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    DOCKER_COMPOSE_CMD="sudo docker-compose"
fi

echo "1. 停止现有容器..."
cd /home/hao/ohif
$DOCKER_COMPOSE_CMD down 2>/dev/null || true

echo ""
echo "2. 确保 Docker 网络存在..."
if docker network ls | grep -q pacs 2>/dev/null || sudo docker network ls | grep -q pacs 2>/dev/null; then
    echo "   ✓ 网络 'pacs' 已存在"
else
    echo "   创建网络 'pacs'..."
    docker network create pacs 2>/dev/null || sudo docker network create pacs
fi

echo ""
echo "3. 配置防火墙规则..."
if command -v ufw &>/dev/null; then
    echo "   检查 UFW 防火墙状态..."
    UFW_STATUS=$(sudo ufw status 2>/dev/null | head -1 || echo "Status: inactive")
    if echo "$UFW_STATUS" | grep -q "Status: active"; then
        echo "   防火墙已启用，开放端口..."
        sudo ufw allow 3000/tcp comment "OHIF Viewer" 2>/dev/null || true
        sudo ufw allow 8042/tcp comment "Orthanc Web UI" 2>/dev/null || true
        sudo ufw allow 4242/tcp comment "Orthanc DICOM" 2>/dev/null || true
        echo "   ✓ 端口已开放"
    else
        echo "   防火墙未启用，跳过"
    fi
fi

# 检查 iptables (如果有)
if command -v iptables &>/dev/null && sudo iptables -L -n &>/dev/null; then
    echo "   检查 iptables 规则..."
    # 这里不自动修改 iptables，因为比较复杂，让用户手动处理
fi

echo ""
echo "4. 启动服务..."
$DOCKER_COMPOSE_CMD up -d

echo ""
echo "5. 等待服务启动..."
sleep 5

echo ""
echo "6. 检查服务状态..."
$DOCKER_COMPOSE_CMD ps

echo ""
echo "7. 测试本地连接..."
echo "   测试 OHIF (localhost:3000):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null | grep -qE "200|301|302"; then
    echo "   ✓ OHIF 本地连接成功"
else
    echo "   ✗ OHIF 本地连接失败"
    echo "   查看日志: $DOCKER_COMPOSE_CMD logs ohif_viewer"
fi

echo "   测试 Orthanc (localhost:8042):"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8042 2>/dev/null | grep -qE "200|301|302"; then
    echo "   ✓ Orthanc 本地连接成功"
else
    echo "   ✗ Orthanc 本地连接失败"
    echo "   查看日志: $DOCKER_COMPOSE_CMD logs pacs"
fi

echo ""
echo "========================================="
echo "  修复完成！"
echo "========================================="
echo ""
echo "📱 访问地址："
echo "   - OHIF Viewer:  http://192.168.1.172:3000"
echo "   - Orthanc Web UI: http://192.168.1.172:8042"
echo ""
echo "⚠️  如果外部连接仍然失败，请检查："
echo "   1. 系统防火墙设置"
echo "   2. 路由器/网络防火墙设置"
echo "   3. 运行诊断脚本: ./diagnose.sh"
echo ""

