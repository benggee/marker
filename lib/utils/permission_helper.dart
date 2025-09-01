import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'logger.dart';

/// 权限处理工具类
/// 专门处理鸿蒙系统和其他Android系统的权限问题
class PermissionHelper {
  /// 检查蓝牙相关权限
  static Future<bool> checkBluetoothPermissions() async {
    try {
      // 鸿蒙系统需要的权限列表
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
        Permission.locationWhenInUse,
      ].request();

      // 检查关键权限
      bool hasBluetoothScan = statuses[Permission.bluetoothScan]?.isGranted ?? false;
      bool hasBluetoothConnect = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
      bool hasLocation = statuses[Permission.location]?.isGranted ?? false;

      Logger.d('权限状态检查:');
      Logger.logPermissionStatus('蓝牙扫描', statuses[Permission.bluetoothScan].toString());
      Logger.logPermissionStatus('蓝牙连接', statuses[Permission.bluetoothConnect].toString());
      Logger.logPermissionStatus('位置权限', statuses[Permission.location].toString());
      Logger.logPermissionStatus('蓝牙广播', statuses[Permission.bluetoothAdvertise].toString());

      return hasBluetoothScan && hasBluetoothConnect && hasLocation;
    } catch (e) {
      Logger.e('权限检查异常', e);
      return false;
    }
  }

  /// 获取权限说明文本
  static String getPermissionDescription() {
    return '''鸿蒙系统需要以下权限才能使用蓝牙功能：

• 蓝牙扫描权限 - 用于发现附近的蓝牙设备
• 蓝牙连接权限 - 用于连接蓝牙设备
• 位置信息权限 - 蓝牙扫描需要位置权限（系统要求）

请在设置中手动授予这些权限。''';
  }

  /// 显示权限说明对话框
  static Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('需要蓝牙权限'),
          content: Text(getPermissionDescription()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('去设置'),
            ),
          ],
        );
      },
    );
  }

  /// 检查特定权限状态
  static Future<Map<Permission, PermissionStatus>> getPermissionStatuses() async {
    return {
      Permission.bluetooth: await Permission.bluetooth.status,
      Permission.bluetoothScan: await Permission.bluetoothScan.status,
      Permission.bluetoothConnect: await Permission.bluetoothConnect.status,
      Permission.bluetoothAdvertise: await Permission.bluetoothAdvertise.status,
      Permission.location: await Permission.location.status,
      Permission.locationWhenInUse: await Permission.locationWhenInUse.status,
    };
  }

  /// 检查是否为鸿蒙系统
  static bool isHarmonyOS() {
    // 简单的鸿蒙系统检测
    // 鸿蒙系统通常会在设备信息中包含特定标识
    return false; // 暂时返回false，实际项目中可以通过设备信息判断
  }

  /// 获取系统特定的权限建议
  static String getSystemSpecificAdvice() {
    if (isHarmonyOS()) {
      return '''鸿蒙系统权限设置建议：
1. 进入"设置" > "应用和服务" > "应用管理"
2. 找到"marker3"应用
3. 点击"权限" > "蓝牙" 和 "位置信息"
4. 开启相关权限''';
    } else {
      return '''Android系统权限设置建议：
1. 进入"设置" > "应用" > "应用管理"
2. 找到"marker3"应用
3. 点击"权限"
4. 开启"蓝牙"和"位置信息"权限''';
    }
  }
}
