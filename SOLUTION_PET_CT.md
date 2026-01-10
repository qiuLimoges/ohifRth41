# PET-CT 配准功能解决方案

## 问题确认

您的 Docker 镜像版本较旧（2年前），可能缺少 PET-CT 配准/融合功能。官网 demo 使用的是更新的版本，包含更多高级功能。

## 解决方案选项

### 方案 1：更新配置并测试（快速尝试）

我已经更新了配置文件，添加了以下选项：

```javascript
enableImageFusion: true,
enableImageRegistration: true,
enableSeriesSynchronization: true,
enableViewportLinking: true,
```

**请先测试**：
1. 清除浏览器缓存（Ctrl+F5）
2. 访问 http://192.168.1.172:3000
3. 上传 PET 和 CT 图像
4. 查看是否有融合/配准选项

**如果仍然没有功能**，说明镜像确实缺少此功能，需要以下方案。

### 方案 2：使用最新的 OHIF 镜像（推荐）

尝试拉取最新的 OHIF 镜像：

```bash
cd /home/hao/ohif

# 停止当前服务
echo 'yue030113' | sudo -S docker-compose down

# 拉取最新镜像
echo 'yue030113' | sudo -S docker pull ohif/viewer:latest

# 或者尝试特定版本
echo 'yue030113' | sudo -S docker pull ohif/viewer:v3.11.0

# 更新 docker-compose.yml（如果需要）
# 然后启动服务
echo 'yue030113' | sudo -S docker-compose up -d
```

### 方案 3：从源代码构建自定义镜像（最可靠）

如果预构建镜像缺少功能，可以从源代码构建：

#### 步骤 1：准备环境

```bash
# 安装 Node.js（如果还没有）
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
echo 'yue030113' | sudo -S apt-get install -y nodejs

# 安装构建工具
echo 'yue030113' | sudo -S apt-get install -y build-essential
```

#### 步骤 2：克隆并构建 OHIF

```bash
# 创建工作目录
mkdir -p ~/ohif-build
cd ~/ohif-build

# 克隆 OHIF 仓库
git clone https://github.com/OHIF/Viewers.git
cd Viewers

# 安装依赖
npm install

# 配置（使用您的配置）
cp /home/hao/ohif/ohif.js platform/app/public/config/app-config.js

# 构建
npm run build
```

#### 步骤 3：创建自定义 Docker 镜像

```bash
# 在 Viewers 目录下创建 Dockerfile
cat > Dockerfile.custom << 'EOF'
FROM nginx:alpine

# Copy built files
COPY dist /usr/share/nginx/html

# Copy your custom config
COPY platform/app/public/config/app-config.js /usr/share/nginx/html/app-config.js

# Copy your nginx config
COPY /home/hao/ohif/nginx_ohif.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# 构建镜像
docker build -f Dockerfile.custom -t ohif-viewer-custom:latest .
```

#### 步骤 4：更新 docker-compose.yml

```yaml
ohif_viewer:
  container_name: ohif
  image: ohif-viewer-custom:latest  # 使用自定义镜像
  ports:
    - "0.0.0.0:3000:80"
  # ... 其他配置
```

### 方案 4：使用 OHIF 官方部署脚本

OHIF 官方可能提供包含所有功能的部署脚本：

```bash
# 检查是否有官方部署脚本
git clone https://github.com/OHIF/Viewers.git
cd Viewers

# 查看部署文档
cat README.md

# 或查看部署脚本
ls scripts/ | grep -i deploy
```

## 检查当前镜像版本

您的当前镜像：
- **镜像**: ohif/viewer:latest
- **创建时间**: 2年前
- **镜像 ID**: 878fa048a034

**建议**: 这个版本可能太旧，缺少 PET-CT 配准功能。

## 推荐的立即行动

### 立即尝试（5分钟）

1. **测试更新后的配置**：
   ```bash
   # 服务已重启，现在清除浏览器缓存并测试
   # 访问 http://192.168.1.172:3000
   ```

2. **如果仍然没有功能，尝试更新镜像**：
   ```bash
   cd /home/hao/ohif
   echo 'yue030113' | sudo -S docker pull ohif/viewer:latest
   echo 'yue030113' | sudo -S docker-compose up -d
   ```

### 如果上述都不行（需要构建）

如果您需要完整的 PET-CT 配准功能，我建议从源代码构建。我可以帮您：

1. 准备构建环境
2. 克隆 OHIF 源码
3. 配置并构建
4. 创建包含完整功能的 Docker 镜像

## 您想选择哪个方案？

1. **先测试当前配置**（最快，但可能功能有限）
2. **尝试更新镜像**（中等难度，可能解决问题）
3. **从源代码构建**（最可靠，但需要更多时间）

请告诉我您想尝试哪个方案，我可以帮您执行。

---
**当前状态**: ⚠️ 配置已更新，但可能需要更新的镜像或从源代码构建
**建议**: 先测试当前配置，如果没有功能，建议从源代码构建

