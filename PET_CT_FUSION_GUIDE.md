# PET-CT 配准/融合功能配置指南

## 问题说明

您发现当前的 OHIF Viewer 缺少 PET-CT 图像配准（registration/fusion）功能，而官网 demo 中包含此功能。

## 原因分析

PET-CT 配准功能通常需要：

1. **Longitudinal Mode（纵向模式）** - OHIF 的高级模式，支持：
   - 多时间点研究
   - 图像融合和配准
   - PET-CT 对齐显示

2. **特定扩展** - 可能需要额外的扩展模块

3. **较新的版本** - 某些高级功能可能只在较新版本中可用

## 当前配置的 Docker 镜像限制

您当前使用的是预构建的 Docker 镜像 `ohif/viewer`，这是一个基础版本，可能：
- ✅ 包含基本的图像查看功能
- ✅ 支持 CT、PET、MRI 等模态
- ❌ 可能缺少高级模式（如 Longitudinal Mode）
- ❌ 可能缺少图像融合功能

## 解决方案

### 方案 1：检查并更新 Docker 镜像版本

尝试使用 OHIF 的最新镜像或包含更多功能的镜像：

```bash
# 停止当前服务
cd /home/hao/ohif
sudo docker-compose down

# 更新 docker-compose.yml 使用最新镜像
# 编辑 docker-compose.yml，确保使用最新版本
# ohif_viewer:
#   image: ohif/viewer:latest  # 或特定版本号
```

### 方案 2：从源代码构建包含完整功能的镜像

如果需要完整功能（包括 PET-CT 配准），建议从源代码构建：

```bash
# 克隆 OHIF 仓库
git clone https://github.com/OHIF/Viewers.git
cd Viewers

# 安装依赖
yarn install

# 查看可用的模式和扩展
ls platform/viewer/src/

# 构建包含所有功能的生产版本
yarn build

# 或使用 Docker 构建
docker build -t ohif-viewer-full .
```

### 方案 3：配置当前镜像以启用可用功能

我已经更新了配置文件，添加了以下配置（已在 ohif.js 中）：

```javascript
// 启用图像融合和配准
enableImageFusion: true,
enableImageRegistration: true,

// 启用系列同步（PET-CT 查看的重要功能）
enableSeriesSynchronization: true,

// 启用视口链接（用于 PET-CT 融合查看）
enableViewportLinking: true,

// 启用时间点浏览器（纵向研究）
enableTimepoints: true,
```

**重启服务后测试**：
```bash
sudo docker-compose restart ohif_viewer
```

然后清除浏览器缓存并刷新页面。

### 方案 4：手动查看 PET-CT（临时方案）

如果融合功能不可用，可以：

1. **并排显示**：
   - 打开 PET 研究
   - 打开 CT 研究
   - 使用多视口布局并排显示

2. **使用同步工具**：
   - 启用视口同步（如果可用）
   - 手动调整窗口/层级以匹配

3. **通过 Orthanc 查看**：
   - 访问 http://192.168.1.172:8042
   - Orthanc 的 Web UI 可能有图像融合选项

## 验证功能

重启服务后，请测试以下功能：

1. **上传 PET-CT 研究**：
   - 确保 PET 和 CT 图像都上传到 Orthanc
   - 它们应该属于同一个患者或研究

2. **查看图像**：
   - 打开研究
   - 查看是否有"Fusion"、"Registration"或"Align"选项
   - 检查工具栏是否有相关工具

3. **查看视口**：
   - 尝试多视口布局
   - 查看是否可以同时显示 PET 和 CT
   - 检查是否有融合/叠加选项

## 推荐方案

如果您需要完整的 PET-CT 配准功能，我建议：

**选项 A：使用 OHIF 官方部署**（如果可行）
- 访问 OHIF 官方演示站点
- 研究其配置方式

**选项 B：从源代码构建自定义镜像**（推荐用于生产环境）
```bash
# 这将提供完整的控制权和所有功能
git clone https://github.com/OHIF/Viewers.git
cd Viewers
# 按照 OHIF 官方文档构建和配置
```

**选项 C：查找包含 Longitudinal Mode 的 Docker 镜像**
- 在 Docker Hub 搜索 `ohif-viewer-longitudinal` 或类似镜像
- 或使用社区维护的包含更多功能的镜像

## 检查当前功能

请重启服务后测试，并告诉我：
1. 工具栏中是否有新的选项？
2. 查看 PET 图像时是否有融合选项？
3. 是否可以同时显示 PET 和 CT？

如果仍然缺少功能，我们可能需要考虑从源代码构建或使用不同的部署方式。

---
**更新时间**: 2026-01-10
**状态**: ⚠️ 配置已更新，但可能需要从源代码构建以获得完整功能

