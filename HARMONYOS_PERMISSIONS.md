# 鸿蒙系统权限配置指南

## 问题描述

在鸿蒙系统（HarmonyOS）上使用蓝牙功能时，可能会遇到以下权限错误：

```
PlatformException(startScan, Permission android.permission.BLUETOOTH_SCAN required to scan devices, null, null)
```

这是因为鸿蒙系统对蓝牙权限的要求更加严格。

## 解决方案

### 1. 应用权限配置

我们已经在 `android/app/src/main/AndroidManifest.xml` 中添加了必要的权限：

```xml
<!-- 蓝牙权限 -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />

<!-- 位置权限（蓝牙扫描需要） -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- 网络状态权限 -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- 蓝牙功能声明 -->
<uses-feature android:name="android.hardware.bluetooth" android:required="true" />
<uses-feature android:name="android.hardware.bluetooth_le" android:required="true" />
```

### 2. 手动授予权限

#### 方法一：通过应用设置页面

1. 在应用中点击"去设置"按钮
2. 系统会自动跳转到应用权限设置页面
3. 手动开启以下权限：
   - **蓝牙扫描**
   - **蓝牙连接**
   - **位置信息**

#### 方法二：手动进入设置

1. 进入 **设置** > **应用和服务** > **应用管理**
2. 找到 **marker3** 应用
3. 点击 **权限**
4. 开启以下权限：
   - **蓝牙** - 允许扫描和连接
   - **位置信息** - 允许访问位置

### 3. 权限说明

#### 为什么需要位置权限？

鸿蒙系统要求蓝牙扫描必须具有位置权限，这是因为：
- 蓝牙扫描可以获取设备位置信息
- 防止恶意应用通过蓝牙扫描追踪用户位置
- 符合隐私保护要求

#### 权限分类

- **BLUETOOTH_SCAN**: 扫描附近的蓝牙设备
- **BLUETOOTH_CONNECT**: 连接到蓝牙设备
- **ACCESS_FINE_LOCATION**: 精确位置信息
- **ACCESS_COARSE_LOCATION**: 大致位置信息

### 4. 常见问题

#### 问题1：权限已授予但仍然报错

**解决方案**：
1. 重启应用
2. 检查是否有其他应用占用蓝牙
3. 确认蓝牙已开启

#### 问题2：位置权限被拒绝

**解决方案**：
1. 进入设置重新开启位置权限
2. 确保应用有"始终允许"或"仅在使用时允许"权限

#### 问题3：蓝牙扫描不到设备

**解决方案**：
1. 确认目标设备已开启蓝牙并可见
2. 检查设备是否支持BLE（蓝牙低功耗）
3. 尝试重启蓝牙

### 5. 调试信息

应用会在控制台输出详细的权限状态：

```
权限状态检查:
  - 蓝牙扫描: PermissionStatus.granted
  - 蓝牙连接: PermissionStatus.granted
  - 位置权限: PermissionStatus.granted
  - 蓝牙广播: PermissionStatus.granted
```

### 6. 技术细节

#### 权限检查流程

1. **应用启动时**: 自动检查权限状态
2. **扫描前**: 再次验证权限
3. **权限不足**: 显示详细说明对话框
4. **用户操作**: 提供"去设置"快捷方式

#### 错误处理

- 捕获所有权限相关异常
- 提供用户友好的错误信息
- 自动跳转到权限设置页面

### 7. 更新日志

#### v1.1.0
- 添加鸿蒙系统权限支持
- 创建专门的权限处理工具类
- 改进错误提示和用户引导

#### v1.0.0
- 基础蓝牙权限支持
- 简单的权限检查

### 8. 联系支持

如果仍然遇到权限问题，请：

1. 检查设备系统版本
2. 确认权限设置状态
3. 查看应用日志输出
4. 提供详细的错误信息

---

**注意**: 鸿蒙系统的权限管理可能会随系统更新而变化，建议保持系统为最新版本。
