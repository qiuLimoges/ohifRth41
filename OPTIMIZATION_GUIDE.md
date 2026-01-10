# OHIF 优化指南 - 基于 GitHub 仓库分析

## 问题诊断

根据 [OHIF GitHub 仓库](https://github.com/OHIF/Viewers/) 的分析：

### 当前状态
- **使用的镜像**: `ohif/viewer:latest` (2023-03-19)
- **问题**: 镜像较旧，可能不包含 `longitudinal` mode（PET-CT 融合所需）
- **GitHub 仓库结构**: 包含 `modes/longitudinal` 目录，但 Docker 镜像可能未包含

### OHIF 仓库结构
根据 GitHub 仓库，OHIF 包含以下关键组件：

```
modes/
├── longitudinal/        # ⭐ PET-CT 融合功能在这里
├── basic-dev-mode/
├── tmtv/
└── microscopy/

extensions/
├── cornerstone/        # 图像渲染
├── measurement-tracking/  # 纵向测量追踪
├── cornerstone-dicom-seg/
└── ...
```

## 解决方案

### 方案 1：从源代码构建（推荐）

这是获得完整功能的最可靠方法。我已经创建了构建脚本 `build-ohif-full.sh`。

**执行构建**：
```bash
cd /home/hao/ohif
./build-ohif-full.sh
```

构建脚本将：
1. ✅ 检查并安装 Node.js 18+（如需要）
2. ✅ 安装 Yarn
3. ✅ 克隆 OHIF GitHub 仓库
4. ✅ 安装所有依赖
5. ✅ 使用您的配置构建
6. ✅ 创建包含完整功能的 Docker 镜像

**构建完成后更新 docker-compose.yml**：
```yaml
ohif_viewer:
  image: ohif-viewer-full:latest  # 使用新构建的镜像
  # ... 其他配置保持不变
```

**重启服务**：
```bash
cd /home/hao/ohif
echo 'yue030113' | sudo -S docker-compose down
echo 'yue030113' | sudo -S docker-compose up -d
```

### 方案 2：尝试特定版本标签

检查是否有更新的镜像标签：
```bash
# 查看可用标签（需要访问 Docker Hub API）
curl -s "https://hub.docker.com/v2/repositories/ohif/viewer/tags?page_size=100" | grep -o '"name":"[^"]*"' | head -20
```

或者直接尝试特定版本：
```bash
cd /home/hao/ohif
echo 'yue030113' | sudo -S docker pull ohif/viewer:v3.11.0
# 或
echo 'yue030113' | sudo -S docker pull ohif/viewer:3.11.0
```

### 方案 3：使用官方构建脚本

OHIF 仓库中包含 `.docker` 目录，可能有官方构建脚本：

```bash
cd /tmp
git clone https://github.com/OHIF/Viewers.git
cd Viewers

# 检查是否有官方 Docker 构建方式
ls .docker/
cat .docker/README.md  # 如果有的话
```

## 优化配置文件

基于 GitHub 仓库的默认配置，我已经优化了您的 `ohif.js`。但根据 OHIF 的架构，**modes 和 extensions 需要在构建时包含**，不能仅通过配置文件启用。

### 关键发现

1. **modes 是构建时包含的**：
   - `modes/longitudinal` 需要在构建时包含
   - 不能仅通过配置文件添加

2. **extensions 也是构建时包含的**：
   - `extensions/cornerstone` 等需要在构建时包含
   - 配置文件只能配置已存在的功能

3. **Docker 镜像的限制**：
   - 预构建的 `ohif/viewer` 镜像可能只包含基础功能
   - 要获得完整功能，需要从源代码构建

## 推荐行动方案

### 立即执行（推荐）

**从源代码构建完整版本**：

```bash
cd /home/hao/ohif

# 运行构建脚本（需要 sudo 密码：yue030113）
./build-ohif-full.sh

# 构建完成后，更新 docker-compose.yml
# 将 image: ohif/viewer 改为 image: ohif-viewer-full:latest

# 重启服务
echo 'yue030113' | sudo -S docker-compose down
echo 'yue030113' | sudo -S docker-compose up -d
```

### 构建时间

- **首次构建**：可能需要 15-30 分钟（取决于网络和系统性能）
- **后续构建**：5-10 分钟（如果代码已下载）

### 验证构建

构建完成后，检查新镜像：
```bash
echo 'yue030113' | sudo -S docker images | grep ohif-viewer-full
```

## 配置说明

即使从源代码构建，您的配置文件 `ohif.js` 仍然需要正确配置。当前配置已经优化，但可能需要根据构建的版本进行调整。

### 重要提示

从源代码构建的版本将包含：
- ✅ Longitudinal Mode（纵向模式）- **PET-CT 融合功能**
- ✅ Cornerstone Extension（图像渲染）
- ✅ Measurement Tracking（测量追踪）
- ✅ 所有标准工具和功能

## 如果构建失败

如果构建过程中遇到问题：

1. **检查 Node.js 版本**：需要 18+
2. **检查 Yarn**：确保已安装
3. **检查网络**：确保可以访问 GitHub 和 npm
4. **检查磁盘空间**：构建需要足够空间（至少 2GB）

查看构建日志中的错误信息，我可以帮助解决。

---
**参考资源**：
- [OHIF GitHub 仓库](https://github.com/OHIF/Viewers/)
- [OHIF 文档](https://docs.ohif.org/)
- [构建脚本](./build-ohif-full.sh)

**状态**: ⚠️ 需要从源代码构建以获得完整功能

