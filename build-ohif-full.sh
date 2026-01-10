#!/bin/bash

# 从源代码构建包含完整功能的 OHIF Viewer
# 包括 PET-CT 融合功能

set -e

echo "========================================="
echo "  从源代码构建 OHIF Viewer（完整功能版）"
echo "========================================="
echo ""

# 检查依赖
echo "🔍 检查依赖..."
if ! command -v node &> /dev/null; then
    echo "❌ 需要安装 Node.js"
    exit 1
fi
echo "✅ Node.js: $(node --version)"

if ! command -v yarn &> /dev/null; then
    echo "📦 安装 Yarn..."
    echo 'yue030113' | sudo -S npm install -g yarn
fi
echo "✅ Yarn: $(yarn --version)"

if ! command -v git &> /dev/null; then
    echo "📦 安装 Git..."
    echo 'yue030113' | sudo -S apt install -y git
fi
echo "✅ Git: $(git --version)"

# 创建工作目录
WORK_DIR="/tmp/ohif-build"
echo ""
echo "📦 克隆 OHIF 仓库..."
if [ -d "$WORK_DIR" ]; then
    echo "   目录已存在，更新..."
    cd "$WORK_DIR"
    git pull
else
    echo "   从 GitHub 克隆..."
    git clone https://github.com/OHIF/Viewers.git "$WORK_DIR"
    cd "$WORK_DIR"
fi

echo ""
echo "📦 启用 Yarn Workspaces..."
yarn config set workspaces-experimental true

echo ""
echo "📦 安装依赖（这可能需要一些时间）..."
yarn install --frozen-lockfile

echo ""
echo "🔧 配置应用..."
# 复制用户的自定义配置
if [ -f "/home/hao/ohif/ohif.js" ]; then
    echo "   使用您的自定义配置..."
    cp /home/hao/ohif/ohif.js platform/app/public/config/app-config.js
else
    echo "   使用默认配置..."
fi

echo ""
echo "🏗️  构建 OHIF Viewer（这需要一些时间）..."
yarn build

echo ""
echo "🐳 创建 Docker 镜像..."

# 创建 Dockerfile
cat > Dockerfile.ohif-full << 'EOF'
FROM nginx:alpine

# Copy built files
COPY dist /usr/share/nginx/html

# Copy custom config if exists
COPY platform/app/public/config/app-config.js /usr/share/nginx/html/app-config.js

# Create nginx config for OHIF
RUN cat > /etc/nginx/conf.d/default.conf << 'NGINX_EOF'
server {
  listen 80;
  client_max_body_size 500M;
  
  root /usr/share/nginx/html;
  index index.html;
  
  # Fix MIME types for JavaScript modules
  location ~* \.mjs$ {
    default_type application/javascript;
    try_files $uri =404;
  }
  
  location / {
    try_files $uri $uri/ /index.html;
    types {
      application/javascript js mjs;
      text/css css;
      text/html html htm;
      application/json json;
    }
  }
  
  # Proxy for Orthanc (adjust if needed)
  location /orthanc/ {
    proxy_pass http://host.docker.internal:8042;
    proxy_set_header HOST $host;
    proxy_set_header X-Real-IP $remote_addr;
    rewrite /orthanc(.*) $1 break;
  }
}
NGINX_EOF

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

echo ""
echo "🐳 构建 Docker 镜像..."
docker build -f Dockerfile.ohif-full -t ohif-viewer-full:latest .

echo ""
echo "========================================="
echo "  ✅ 构建完成！"
echo "========================================="
echo ""
echo "📝 下一步："
echo "1. 更新 docker-compose.yml："
echo "   将 image: ohif/viewer 改为 image: ohif-viewer-full:latest"
echo ""
echo "2. 重启服务："
echo "   cd /home/hao/ohif"
echo "   echo 'yue030113' | sudo -S docker-compose up -d"
echo ""
echo "3. 访问测试："
echo "   http://192.168.1.172:3000"
echo ""
