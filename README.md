# 条形码管理系统

一个功能完整的Flutter条形码管理系统，支持条形码生成、扫描、蓝牙打印和库存管理。

## 功能特性

### 1. 蓝牙设备管理
- 🔍 搜索附近的蓝牙设备
- 🔗 连接蓝牙打印机
- 💾 记住已连接的设备
- 📱 管理设备连接状态

### 2. 条形码生成
- 🏷️ 自动生成6位数字条形码（自动累加）
- 🖨️ 支持蓝牙打印条形码
- 📊 条形码预览和管理
- 🗂️ 条形码历史记录

### 3. 条形码扫描
- 📷 相机扫描条形码
- ✅ 验证条形码格式
- 🔍 查找条形码信息
- 📋 查看关联库存

### 4. 库存管理
- 📦 为每个条形码管理库存项目
- ➕ 添加、编辑、删除库存项目
- 📊 库存数量统计
- 🔄 实时库存更新

## 技术架构

### 项目结构
```
lib/
├── core/                 # 核心功能
├── features/            # 功能模块
│   ├── bluetooth/       # 蓝牙功能
│   ├── barcode/         # 条形码功能
│   ├── scanner/         # 扫描功能
│   └── inventory/       # 库存管理
├── models/              # 数据模型
├── services/            # 服务层
├── providers/           # 状态管理
├── widgets/             # 共享组件
└── utils/               # 工具类
```

### 核心技术栈
- **Flutter**: 跨平台UI框架
- **Provider**: 状态管理
- **SQLite**: 本地数据存储
- **flutter_blue_plus**: 蓝牙通信
- **mobile_scanner**: 条形码扫描
- **barcode_widget**: 条形码生成

## 安装和运行

### 环境要求
- Flutter SDK 3.7.0+
- Dart SDK 3.7.0+
- Android Studio / VS Code

### 安装步骤

1. 克隆项目
```bash
git clone <repository-url>
cd marker3
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行项目
```bash
flutter run
```

### 权限配置

#### Android 权限
在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
```

#### iOS 权限
在 `ios/Runner/Info.plist` 中添加：

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要蓝牙权限来连接打印机</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>需要蓝牙权限来连接打印机</string>
<key>NSCameraUsageDescription</key>
<string>需要相机权限来扫描条形码</string>
```

## 使用说明

### 1. 蓝牙设备管理
1. 点击底部导航栏的"蓝牙"标签
2. 点击"扫描设备"按钮
3. 选择要连接的蓝牙打印机
4. 设备会自动记住，下次可直接连接

### 2. 生成条形码
1. 点击底部导航栏的"条形码"标签
2. 点击右上角的"+"按钮生成新条形码
3. 点击"打印"按钮将条形码发送到蓝牙打印机

### 3. 扫描条形码
1. 点击底部导航栏的"扫描"标签
2. 将条形码放入扫描框内
3. 系统会自动识别并显示条形码详情

### 4. 库存管理
1. 扫描条形码后进入详情页面
2. 点击右下角的"+"按钮添加库存项目
3. 填写项目名称、描述和数量
4. 可以编辑或删除已有项目

## 数据库设计

### 条形码表 (barcodes)
- `id`: 主键
- `barcode_id`: 条形码ID (6位数字)
- `content`: 条形码内容
- `created_at`: 创建时间
- `updated_at`: 更新时间

### 库存项目表 (inventory_items)
- `id`: 主键
- `barcode_id`: 关联的条形码ID
- `name`: 项目名称
- `description`: 项目描述
- `quantity`: 数量
- `created_at`: 创建时间
- `updated_at`: 更新时间

### 蓝牙设备表 (bluetooth_devices)
- `id`: 设备ID
- `name`: 设备名称
- `address`: 设备地址
- `is_connected`: 连接状态
- `last_connected`: 最后连接时间
- `is_remembered`: 是否记住设备

## 蓝牙打印协议

当前实现使用ESC/POS打印命令，支持以下功能：
- 初始化打印机
- 设置字体大小和对齐方式
- 打印条形码
- 自动切纸

**注意**: 打印命令需要根据实际打印机协议进行调整。

## 扩展性设计

### 模块化架构
- 每个功能模块独立开发
- 服务层封装业务逻辑
- 数据模型统一管理
- 状态管理集中处理

### 可扩展功能
- 支持多种条形码格式
- 可添加更多打印协议
- 支持云端数据同步
- 可扩展更多设备类型

## 故障排除

### 常见问题

1. **蓝牙连接失败**
   - 检查设备是否开启蓝牙
   - 确认打印机在可发现状态
   - 检查权限设置

2. **扫描无法识别**
   - 确保条形码清晰可见
   - 检查相机权限
   - 调整扫描距离

3. **打印失败**
   - 检查蓝牙连接状态
   - 确认打印机协议设置
   - 检查打印命令格式

## 贡献指南

欢迎提交Issue和Pull Request来改进项目。

## 许可证

MIT License