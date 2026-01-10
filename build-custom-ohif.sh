#!/bin/bash

# 构建包含完整功能的 OHIF Viewer 脚本

set -e

echo "========================================="
echo "  构建包含 PET-CT 配准功能的 OHIF Viewer"
echo "========================================="
echo ""

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "⚠️  需要安装 Node.js"
    echo "安装 Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    echo 'yue030113' | sudo -S apt-get install -y nodejs
fi

echo "✅ Node.js 版本: $(node --version)"
echo "✅ npm 版本: $(npm --version)"

# 创建工作目录
WORK_DIR="/tmp/ohif-build"
echo ""
echo "📦 克隆 OHIF 仓库..."
if [ -d "$WORK_DIR" ]; then
    echo "   目录已存在，更新..."
    cd "$WORK_DIR"
    git pull
else
    git clone https://github.com/OHIF/Viewers.git "$WORK_DIR"
    cd "$WORK_DIR"
fi

echo ""
echo "📦 安装依赖..."
npm install

echo ""
echo "🔧 配置构建..."
# 这里可以添加自定义配置

echo ""
echo "🏗️  构建 OHIF Viewer..."
npm run build

echo ""
echo "🐳 构建 Docker 镜像..."
cat > Dockerfile.custom << 'EOF'
FROM nginx:alpine

# Copy built files
COPY dist /usr/share/nginx/html

# Copy custom config
COPY /home/hao/ohif/ohif.js /usr/share/nginx/html/app-config.js
COPY /home/hao/ohif/nginx_ohif.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF

docker build -f Dockerfile.custom -t ohif-viewer-custom:latest .

echo ""
echo "========================================="
echo "  ✅ 构建完成！"
echo "========================================="
echo ""
echo "现在可以更新 docker-compose.yml 使用新镜像："
echo "  image: ohif-viewer-custom:latest"
echo ""

