# OHIF Viewer 从源代码构建指南

## 问题说明

根据 [OHIF GitHub 仓库](https://github.com/OHIF/Viewers/)，预构建的 Docker 镜像 `ohif/viewer` 可能只包含基础功能，缺少 PET-CT 融合所需的高级模式（如 `longitudinal` 模式）。

## 解决方案：从源代码构建

从源代码构建可以包含所有模式和扩展，包括：
- ✅ **longitudinal 模式** - 支持 PET-CT 融合、多时间点研究
- ✅ **所有扩展** - cornerstone、measurement-tracking 等
- ✅ **最新功能** - v3.11+ 的数据叠加功能

## 构建步骤

### 方法 1：使用构建脚本（推荐）

我已经为您创建了构建脚本：

```bash
cd /home/hao/ohif
./build-ohif-full.sh
```

这个脚本会：
1. 安装必要的依赖（Node.js、Yarn、Git）
2. 克隆 OHIF 仓库
3. 安装依赖并构建
4. 创建包含所有功能的 Docker 镜像

### 方法 2：手动构建

#### 步骤 1：准备环境

```bash
# 安装 Node.js 18+（已完成）
node --version

# 安装 Yarn
echo 'yue030113' | sudo -S npm install -g yarn
yarn --version

# 安装 Git（如果需要）
echo 'yue030113' | sudo -S apt install -y git
```

#### 步骤 2：克隆 OHIF 仓库

```bash
cd /tmp
git clone https://github.com/OHIF/Viewers.git ohif-viewers
cd ohif-viewers
```

#### 步骤 3：配置构建

OHIF 使用 `pluginImports.js` 来自动导入模式和扩展。默认情况下，构建会包含所有可用的模式和扩展：

- **模式**: `basic`, `longitudinal`, `tmtv`, `microscopy` 等
- **扩展**: `cornerstone`, `measurement-tracking`, `default` 等

如果您想自定义，需要修改构建配置。

#### 步骤 4：安装依赖

```bash
# 启用 Yarn Workspaces
yarn config set workspaces-experimental true

# 安装依赖（这需要一些时间）
yarn install --frozen-lockfile
```

#### 步骤 5：配置应用

复制您的自定义配置：

```bash
# 使用您的配置
cp /home/hao/ohif/ohif-config-full.js platform/app/public/config/app-config.js

# 或者使用默认配置
# 默认配置会在构建时自动包含所有模式和扩展
```

#### 步骤 6：构建应用

```bash
# 构建生产版本（包含所有模式和扩展）
yarn build
```

#### 步骤 7：创建 Docker 镜像

```bash
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
  
  # Proxy for Orthanc
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

# 构建镜像
docker build -f Dockerfile.ohif-full -t ohif-viewer-full:latest .
```

#### 步骤 8：更新 docker-compose.yml

```yaml
ohif_viewer:
  container_name: ohif
  image: ohif-viewer-full:latest  # 使用新构建的镜像
  ports:
    - "0.0.0.0:3000:80"
  volumes:
    - ./nginx_ohif.conf:/etc/nginx/conf.d/default.conf:ro
    - ./ohif-config-full.js:/usr/share/nginx/html/app-config.js:ro
  restart: always
  networks:
    - pacs
```

#### 步骤 9：启动服务

```bash
cd /home/hao/ohif
echo 'yue030113' | sudo -S docker-compose up -d
```

## 验证功能

构建完成后，访问 http://192.168.1.172:3000，您应该看到：

1. ✅ **更多模式选项** - 包括 "Longitudinal" 模式
2. ✅ **PET-CT 融合功能** - 在纵向模式下可用
3. ✅ **更多工具** - 图像配准、融合显示等

## 注意事项

1. **构建时间**：首次构建可能需要 10-20 分钟
2. **磁盘空间**：需要约 2-3 GB 磁盘空间
3. **网络**：需要稳定的网络连接下载依赖

## 如果构建失败

如果遇到问题：

1. **检查 Node.js 版本**：需要 Node.js 18+
   ```bash
   node --version
   ```

2. **检查 Yarn 版本**：需要 Yarn 1.20+
   ```bash
   yarn --version
   ```

3. **清除缓存重新构建**：
   ```bash
   rm -rf node_modules yarn.lock
   yarn install --frozen-lockfile
   ```

4. **查看构建日志**：
   ```bash
   yarn build 2>&1 | tee build.log
   ```

## 参考资源

- [OHIF GitHub 仓库](https://github.com/OHIF/Viewers/)
- [OHIF 官方文档](https://docs.ohif.org/)
- [构建文档](https://docs.ohif.org/platform/build/)

---
**状态**: ✅ 构建脚本已准备，可以开始构建

