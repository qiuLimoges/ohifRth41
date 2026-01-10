# OHIF + Orthanc 医疗影像系统

这是一个基于 Docker Compose 的医疗影像系统，使用 Orthanc 作为 DICOM 存储服务器，OHIF Viewer 作为图像浏览器。

## 功能特点

- ✅ **Orthanc DICOM 服务器** - 轻量级、开源的 DICOM 服务器
- ✅ **OHIF Viewer** - 现代化的 Web 医疗影像查看器
- ✅ **无用户认证** - 基础版本已禁用用户认证（仅用于开发/测试环境）
- ✅ **DICOM 上传** - 支持通过 OHIF 界面直接上传 DICOM 文件

## 前提条件

1. **安装 Docker 和 Docker Compose**

   Ubuntu/Debian:
   ```bash
   sudo apt update
   sudo apt install docker.io docker-compose
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

   或者使用官方安装脚本：
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   ```

2. **将当前用户添加到 docker 组**（可选，避免使用 sudo）:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

## 安装步骤

1. **创建 Docker 网络**:
   ```bash
   docker network create pacs
   ```

2. **启动服务**:
   ```bash
   docker-compose up -d
   ```

3. **查看服务状态**:
   ```bash
   docker-compose ps
   ```

4. **查看日志**:
   ```bash
   # 查看所有服务日志
   docker-compose logs -f
   
   # 查看 Orthanc 日志
   docker-compose logs -f pacs
   
   # 查看 OHIF 日志
   docker-compose logs -f ohif_viewer
   ```

## 访问服务

### 本地访问

- **OHIF Viewer**: http://localhost:3000
  - 医疗影像查看器主界面
  
- **Orthanc Web UI**: http://localhost:8042
  - Orthanc 服务器的 Web 管理界面
  - 当前版本**无需用户名和密码**（已禁用认证）

### 外部访问

如果服务器IP是 `192.168.1.172`，可以从其他设备访问：

- **OHIF Viewer**: http://192.168.1.172:3000
- **Orthanc Web UI**: http://192.168.1.172:8042

### DICOM 端口

- **Orthanc DICOM 端口**: `4242`
  - 用于接收来自其他 PACS 系统或影像设备的 DICOM 传输
  - AE Title: `ORTHANC`
  - IP: 服务器 IP 地址（如：192.168.1.172）

## 配置说明

### Orthanc 配置 (`orthanc.json`)

主要配置项：
- `AuthenticationEnabled: false` - 已禁用用户认证
- `DicomAet: "ORTHANC"` - DICOM AE Title
- `DicomPort: 4242` - DICOM 接收端口
- `HttpPort: 8042` - HTTP Web UI 端口

### OHIF 配置 (`ohif.js`)

- OHIF Viewer 通过 `/orthanc/dicom-web` 和 `/orthanc/wado` 访问 Orthanc
- 支持 DICOM 文件上传功能

### Nginx 配置 (`nginx_ohif.conf`)

- 配置了反向代理，将 `/orthanc/` 路径代理到 Orthanc 服务器
- 支持最大 500MB 的文件上传

## 使用说明

### 上传 DICOM 文件

1. **通过 OHIF 界面**:
   - 访问 http://localhost:3000
   - 使用界面上传功能导入 DICOM 文件或文件夹

2. **通过 Orthanc Web UI**:
   - 访问 http://localhost:8042
   - 使用 "Upload" 功能上传 DICOM 文件

3. **从其他 PACS 系统接收**:
   - 配置影像设备的 DICOM 传输设置:
     - AE Title: `ORTHANC`
     - IP: 服务器 IP 地址
     - Port: `4242`

### 查看影像

1. 访问 http://localhost:3000
2. 在左侧患者列表中选择患者
3. 双击研究（Study）以查看影像

## 数据存储

- Orthanc 的数据库和 DICOM 文件存储在 `./orthanc_db/` 目录中
- 数据在容器重启后会保留

## 停止和清理

**停止服务**:
```bash
docker-compose down
```

**停止并删除数据**（注意：这会删除所有存储的 DICOM 数据）:
```bash
docker-compose down -v
rm -rf orthanc_db
```

## 故障排除

### 网站拒绝连接（外部无法访问）

如果服务已启动但无法从外部访问，请按以下步骤排查：

1. **运行诊断脚本**：
   ```bash
   ./diagnose.sh
   ```

2. **运行修复脚本**：
   ```bash
   ./fix-connection.sh
   ```

3. **检查防火墙**：
   ```bash
   # 查看 UFW 防火墙状态
   sudo ufw status
   
   # 如果防火墙已启用，开放端口
   sudo ufw allow 3000/tcp
   sudo ufw allow 8042/tcp
   sudo ufw allow 4242/tcp
   ```

4. **检查端口监听**：
   ```bash
   # 检查端口是否监听在所有接口上（0.0.0.0）
   sudo ss -tlnp | grep -E ':(3000|8042|4242)'
   ```
   
   应该看到类似 `0.0.0.0:3000` 的绑定，而不是 `127.0.0.1:3000`

5. **重启服务**：
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### 端口被占用

如果 3000 或 8042 端口已被占用，可以修改 `docker-compose.yml` 中的端口映射。

### 网络错误

确保 `pacs` 网络已创建：
```bash
docker network ls | grep pacs
```

如果不存在，创建它：
```bash
docker network create pacs
```

### 权限问题

如果遇到权限错误，确保：
1. Docker 服务正在运行: `sudo systemctl status docker`
2. 当前用户在 docker 组中，或者使用 `sudo` 运行命令

### 容器无法启动

查看容器日志：
```bash
# 查看所有服务日志
docker-compose logs

# 查看 Orthanc 日志
docker-compose logs pacs

# 查看 OHIF 日志
docker-compose logs ohif_viewer
```

## 安全注意事项

⚠️ **重要**: 当前配置已禁用用户认证，仅适用于：
- 开发环境
- 测试环境
- 隔离的内部网络环境

**不建议在生产环境或公共网络中直接使用此配置！**

如需启用认证，请修改 `orthanc.json`：
```json
"AuthenticationEnabled": true,
"RegisteredUsers": {
  "用户名": "密码"
}
```

## 参考资源

- [Orthanc 官方文档](https://book.orthanc-server.com/)
- [OHIF Viewer 官方文档](https://docs.ohif.org/)
- [原始项目](https://github.com/hyper4saken/ohif-orthanc)

