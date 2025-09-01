# 条形码打印功能说明

## 概述

本项目已集成专业的条形码打印功能，支持多种条形码格式和高质量的位图打印。

## 功能特性

### 1. 支持的条形码格式
- **Code128**: 通用工业标准，支持数字、字母和特殊字符
- **Code93**: 高密度条形码，适合空间受限场景
- **EAN13**: 国际商品编码标准
- **UPC**: 美国商品编码标准
- **QR码**: 二维条码，支持大量数据

### 2. 打印方式
- **位图打印**: 使用专业的位图转换算法，确保打印质量
- **ESC/POS**: 支持标准ESC/POS打印命令（备选方案）

## 技术实现

### 核心组件

#### BarcodeGenerator 工具类
```dart
// 生成Code128条形码
String svg = BarcodeGenerator.generateCode128Svg("123456", width: 300, height: 100);

// 生成QR码
String qrSvg = BarcodeGenerator.generateQrSvg("https://example.com", width: 300, height: 300);
```

#### 位图转换流程
1. **SVG生成**: 使用 `barcode` 包生成标准SVG格式
2. **位图转换**: 将SVG转换为黑白位图数据
3. **打印机格式**: 转换为打印机可识别的位图格式
4. **数据传输**: 通过蓝牙发送到打印机

### 打印协议

#### 位图打印协议
```
前缀: [0xA5, 0xA5, 0xA5, 0xA5, 0x03]
位图数据: [每行8位压缩数据]
后缀: [0xA6, 0xA6, 0xA6, 0xA6, 0x01]
```

#### 数据格式
- 每行数据按8位压缩
- 黑色像素用1表示，白色像素用0表示
- 支持300x100像素分辨率

## 使用方法

### 基本打印
```dart
final barcodeService = BarcodeService();
final barcode = BarcodeModel(
  barcodeId: "000001",
  content: "000001",
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// 打印条形码
bool success = await barcodeService.printBarcode(barcode);
```

### 自定义条形码
```dart
// 生成不同格式的条形码
String code128Svg = BarcodeGenerator.generateCode128Svg("ABC123");
String ean13Svg = BarcodeGenerator.generateEan13Svg("1234567890123");
String qrSvg = BarcodeGenerator.generateQrSvg("Hello World");
```

## 配置说明

### 打印机设置
- **分辨率**: 300x100像素（可调整）
- **协议**: 支持自定义前缀/后缀命令
- **延迟**: 100微秒的数据传输间隔

### 蓝牙配置
- 自动发现打印服务
- 支持多种蓝牙特征值
- 自动重连和错误处理

## 扩展功能

### 1. 添加新的条形码格式
```dart
// 在 BarcodeGenerator 中添加新方法
static String generateCustomSvg(String data, {double width = 300, double height = 100}) {
  final bc = Barcode.custom(); // 自定义条形码类型
  return bc.toSvg(data, width: width, height: height);
}
```

### 2. 自定义打印协议
```dart
// 在 BarcodeService 中修改协议参数
List<int> customPrefix = [0xAA, 0xBB, 0xCC, 0xDD, 0x04];
List<int> customSuffix = [0xEE, 0xFF, 0x00, 0x11, 0x02];
```

### 3. 支持更多打印机
- 添加新的打印机协议支持
- 实现打印机状态检测
- 支持打印队列管理

## 性能优化

### 1. 位图缓存
- 缓存生成的位图数据
- 避免重复计算

### 2. 批量打印
- 支持多个条形码连续打印
- 优化数据传输效率

### 3. 错误处理
- 自动重试机制
- 详细的错误日志
- 用户友好的错误提示

## 注意事项

1. **蓝牙权限**: 确保应用有蓝牙连接权限
2. **打印机兼容性**: 验证打印机支持的协议
3. **数据格式**: 确保条形码数据符合格式要求
4. **网络延迟**: 蓝牙传输可能有延迟，建议添加进度提示

## 故障排除

### 常见问题
1. **连接失败**: 检查蓝牙权限和设备可见性
2. **打印质量差**: 调整位图分辨率和对比度
3. **数据丢失**: 检查数据传输间隔和缓冲区大小

### 调试信息
- 启用详细日志记录
- 监控蓝牙连接状态
- 验证数据完整性

## 更新日志

### v1.1.0
- 集成专业条形码生成库
- 实现位图打印功能
- 支持多种条形码格式
- 优化蓝牙传输协议

### v1.0.0
- 基础ESC/POS打印支持
- 简单的文本打印功能
- 基本蓝牙连接管理
