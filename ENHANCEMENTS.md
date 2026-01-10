# OHIF 功能增强说明

## 已添加的配置

### 1. Cornerstone 工具配置

已启用以下图像渲染工具：
- **测量工具**：Length（长度）、Bidirectional（双向）、Angle（角度）
- **ROI 工具**：CircleRoi（圆形ROI）、EllipseRoi（椭圆ROI）、RectangleRoi（矩形ROI）、FreehandRoi（手绘ROI）
- **标注工具**：ArrowAnnotate（箭头标注）、TextMarker（文本标记）、Probe（探针）
- **导航工具**：Zoom（缩放）、Pan（平移）、Rotate（旋转）、Flip（翻转）、StackScroll（堆叠滚动）
- **其他工具**：Wwwc（窗宽窗位）、Magnify（放大镜）、Eraser（擦除）

### 2. 支持的模态类型

已配置支持以下 DICOM 模态：
- **CT** (Computed Tomography) - 计算机断层扫描
- **MR** (Magnetic Resonance) - 磁共振成像
- **PT/PET** (Positron Emission Tomography) - 正电子发射断层扫描
- **NM** (Nuclear Medicine) - 核医学
- **US** (Ultrasound) - 超声
- **CR** (Computed Radiography) - 计算机X线摄影
- **DX** (Digital Radiography) - 数字X线摄影
- **MG** (Mammography) - 乳腺X线摄影
- **XA** (X-Ray Angiography) - X线血管造影
- **RF** (Radiofluoroscopy) - 放射透视

### 3. 窗口/层级预设

为不同模态配置了预设的窗口/层级值：

#### CT 预设
- SoftTissue（软组织）：Window 400, Level 50
- Bone（骨骼）：Window 1800, Level 400
- Lung（肺部）：Window 1500, Level -600
- Brain（脑部）：Window 80, Level 40
- Abdomen（腹部）：Window 400, Level 50
- Liver（肝脏）：Window 150, Level 90
- Mediastinum（纵隔）：Window 350, Level 50
- Angio（血管造影）：Window 600, Level 300

#### PET 预设
- Standard（标准）：Window 5, Level 2.5
- Lung（肺部）：Window 6, Level 3
- Liver（肝脏）：Window 7, Level 3.5
- Brain（脑部）：Window 8, Level 4
- SUV（标准摄取值）：Window 10, Level 5

#### MRI 预设
- Brain（脑部）：Window 2000, Level 500
- Spine（脊柱）：Window 800, Level 400
- T1：Window 400, Level 200
- T2：Window 1000, Level 500
- FLAIR：Window 1200, Level 600

### 4. 查看器功能

- ✅ 启用研究列表功能（包括 DICOM 上传）
- ✅ 启用时间点浏览器（用于纵向研究）
- ✅ 启用挂片协议（Hanging Protocols）
- ✅ 配置默认视口设置

### 5. 研究浏览器配置

- 显示患者信息
- 显示系列描述
- 显示模态类型
- 显示研究日期

## 使用方法

### 访问服务

- **OHIF Viewer**: http://192.168.1.172:3000
- **Orthanc Web UI**: http://192.168.1.172:8042

### 查看 PET 图像

1. 上传 PET DICOM 文件到 Orthanc
2. 在 OHIF Viewer 中选择研究
3. 打开图像后，可以使用工具栏中的测量和标注工具
4. 调整窗口/层级：使用快捷键 1-9 切换预设，或使用鼠标滚轮调整

### 使用测量工具

1. 点击工具栏中的测量工具（如 Length、Bidirectional）
2. 在图像上点击并拖动进行测量
3. 测量结果会显示在图像上

### 窗口/层级快捷键

- `1-9`：切换窗口/层级预设（取决于当前配置）
- 鼠标滚轮：调整窗口/层级值

## 注意事项

⚠️ **重要提示**：

1. **Docker 镜像限制**：
   - 当前使用的是预构建的 `ohif/viewer` Docker 镜像
   - 某些高级功能可能需要从源代码构建的自定义镜像才能使用
   - 如果某些配置选项不生效，可能需要使用完整的 OHIF 源代码版本

2. **扩展和模式**：
   - 要安装额外的扩展和模式，通常需要使用 OHIF CLI 工具和源代码版本
   - Docker 镜像中包含的功能是预构建的，无法动态添加新的扩展

3. **功能验证**：
   - 请清除浏览器缓存后测试新功能
   - 如果某些功能不可用，检查浏览器控制台是否有错误信息

## 如需更多功能

如果您需要更多高级功能（如特定的工作流程模式、自定义扩展等），可以考虑：

1. **使用完整的 OHIF 源代码**：
   ```bash
   git clone https://github.com/OHIF/Viewers.git
   cd Viewers
   npm install
   npm run dev
   ```

2. **安装 OHIF CLI 工具**：
   ```bash
   npm install -g @ohif/cli
   ohif-cli modes list
   ohif-cli extensions list
   ```

3. **构建自定义 Docker 镜像**：
   - 使用源代码构建包含所需扩展的自定义镜像

## 配置文件

所有配置都在 `/home/hao/ohif/ohif.js` 文件中。修改后需要重启服务：

```bash
cd /home/hao/ohif
sudo docker-compose restart ohif_viewer
```

---
**更新时间**: 2026-01-10
**状态**: ✅ 已配置基础功能增强

