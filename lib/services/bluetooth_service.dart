import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:permission_handler/permission_handler.dart';
import '../models/bluetooth_device_model.dart';
import 'database_service.dart';
import '../utils/logger.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  final DatabaseService _databaseService = DatabaseService();
  fbp.BluetoothDevice? _connectedDevice;
  StreamSubscription<List<fbp.ScanResult>>? _scanSubscription;
  StreamSubscription<fbp.BluetoothConnectionState>? _connectionSubscription;

  // 获取当前连接的设备
  fbp.BluetoothDevice? get connectedDevice => _connectedDevice;

  // 检查蓝牙权限
  Future<bool> checkPermissions() async {
    try {
      // 鸿蒙系统需要特殊处理权限
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
        Permission.locationWhenInUse,
      ].request();

      // 检查关键权限是否已授予
      bool hasBluetoothScan = statuses[Permission.bluetoothScan]?.isGranted ?? false;
      bool hasBluetoothConnect = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
      bool hasLocation = statuses[Permission.location]?.isGranted ?? false;

      Logger.logPermissionStatus('蓝牙扫描', hasBluetoothScan.toString());
      Logger.logPermissionStatus('蓝牙连接', hasBluetoothConnect.toString());
      Logger.logPermissionStatus('位置权限', hasLocation.toString());
      
      return hasBluetoothScan && hasBluetoothConnect && hasLocation;
    } catch (e) {
      Logger.e('权限检查失败', e);
      return false;
    }
  }

  // 检查蓝牙是否开启
  Future<bool> isBluetoothEnabled() async {
    return await fbp.FlutterBluePlus.isSupported && await fbp.FlutterBluePlus.adapterState.first == fbp.BluetoothAdapterState.on;
  }

  // 开启蓝牙
  Future<void> turnOnBluetooth() async {
    if (await fbp.FlutterBluePlus.isSupported) {
      await fbp.FlutterBluePlus.turnOn();
    }
  }

  // 扫描设备
  Stream<List<fbp.BluetoothDevice>> scanForDevices() {
    return fbp.FlutterBluePlus.scanResults.map((results) {
      return results.map((result) => result.device).toList();
    });
  }

  // 开始扫描
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      // 首先检查权限
      bool hasPermissions = await checkPermissions();
      if (!hasPermissions) {
        throw Exception('缺少必要的蓝牙权限，请在设置中授予权限');
      }

      // 检查蓝牙是否开启
      if (!await isBluetoothEnabled()) {
        throw Exception('蓝牙未开启，请先开启蓝牙');
      }

      // 开始扫描
      await fbp.FlutterBluePlus.startScan(timeout: timeout);
      Logger.i('蓝牙扫描已开始');
    } catch (e) {
      Logger.e('开始扫描失败', e);
      rethrow;
    }
  }

  // 停止扫描
  Future<void> stopScan() async {
    await fbp.FlutterBluePlus.stopScan();
  }

  // 连接设备
  Future<bool> connectToDevice(fbp.BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      
      // 保存设备到数据库
      final deviceModel = BluetoothDeviceModel(
        id: device.remoteId.toString(),
        name: device.platformName.isNotEmpty ? device.platformName : 'Unknown Device',
        address: device.remoteId.toString(),
        isConnected: true,
        lastConnected: DateTime.now(),
        isRemembered: true,
      );
      
      await _databaseService.insertBluetoothDevice(deviceModel);
      
      // 监听连接状态
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == fbp.BluetoothConnectionState.disconnected) {
          _connectedDevice = null;
        }
      });
      
      return true;
    } catch (e) {
      Logger.e('连接设备失败', e);
      return false;
    }
  }

  // 断开连接
  Future<void> disconnectDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      await _connectionSubscription?.cancel();
    }
  }

  // 发送数据到打印机
  Future<bool> sendToPrinter(String data) async {
    if (_connectedDevice == null) {
      throw Exception('没有连接的设备');
    }

    try {
      // 转换数据为字节
      Uint8List bytes = Uint8List.fromList(data.codeUnits);
      
      // 发送原始字节数据
      return await sendRawData(bytes);
    } catch (e) {
      Logger.e('发送数据失败', e);
      return false;
    }
  }

  // 发送原始字节数据到打印机
  Future<bool> sendRawData(List<int> data) async {
    if (_connectedDevice == null) {
      throw Exception('没有连接的设备');
    }

    try {
      // 发现服务
      List<dynamic> services = await _connectedDevice!.discoverServices();
      
      // 使用与../marker项目相同的特定特征UUID
      dynamic printCharacteristic;
      
      for (dynamic service in services) {
        for (dynamic characteristic in service.characteristics) {
          Logger.i('Characteristic: ${characteristic.uuid.toString()}');
          // 使用../marker项目中的特定UUID
          if (characteristic.uuid.toString() == 'beb5483e-36e1-4688-b7f5-ea07361b26a8') {
            printCharacteristic = characteristic;
            break;
          }
        }
        if (printCharacteristic != null) break;
      }
      
      if (printCharacteristic == null) {
        // 如果没找到特定特征，尝试第一个可写特征作为备选
        for (dynamic service in services) {
          for (dynamic characteristic in service.characteristics) {
            if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
              printCharacteristic = characteristic;
              Logger.w('使用备选特征: ${characteristic.uuid.toString()}');
              break;
            }
          }
          if (printCharacteristic != null) break;
        }
      }
      
      if (printCharacteristic == null) {
        throw Exception('未找到可写的特征');
      }
      
      Logger.i('使用特征: ${printCharacteristic.uuid.toString()}');
      
      // 转换数据为字节
      Uint8List bytes = Uint8List.fromList(data);
      
      // 发送数据 - 使用与../marker项目相同的参数
      await printCharacteristic.write(bytes, withoutResponse: false);
      
      return true;
    } catch (e) {
      Logger.e('发送原始数据失败', e);
      return false;
    }
  }

  // 获取已记住的设备
  Future<List<BluetoothDeviceModel>> getRememberedDevices() async {
    return await _databaseService.getRememberedDevices();
  }

  // 删除记住的设备
  Future<void> removeRememberedDevice(String deviceId) async {
    await _databaseService.deleteBluetoothDevice(deviceId);
  }

  // 更新设备连接状态
  Future<void> updateDeviceConnectionStatus(String deviceId, bool isConnected) async {
    final devices = await _databaseService.getAllBluetoothDevices();
    final device = devices.firstWhere((d) => d.id == deviceId);
    
    final updatedDevice = device.copyWith(
      isConnected: isConnected,
      lastConnected: DateTime.now(),
    );
    
    await _databaseService.updateBluetoothDevice(updatedDevice);
  }

  // 写入数据到设备 (用于发送ADC命令)
  Future<bool> writeData(List<int> data) async {
    try {
      if (_connectedDevice == null) {
        throw Exception('设备未连接');
      }
      
      // 获取设备服务
      List<fbp.BluetoothService> services = await _connectedDevice!.discoverServices();
      fbp.BluetoothCharacteristic? targetCharacteristic;
      
      // 查找目标特征 (使用固定的UUID)
      for (fbp.BluetoothService service in services) {
        for (fbp.BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.characteristicUuid.toString() == 'beb5483e-36e1-4688-b7f5-ea07361b26a8') {
            targetCharacteristic = characteristic;
            break;
          }
        }
        if (targetCharacteristic != null) break;
      }
      
      if (targetCharacteristic == null) {
        // 如果没找到特定特征，尝试第一个可写特征
        for (fbp.BluetoothService service in services) {
          for (fbp.BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
              targetCharacteristic = characteristic;
              break;
            }
          }
          if (targetCharacteristic != null) break;
        }
      }
      
      if (targetCharacteristic == null) {
        throw Exception('未找到可写的特征');
      }
      
      // 发送数据
      await targetCharacteristic.write(Uint8List.fromList(data), withoutResponse: false);
      Logger.i('成功发送数据: $data');
      
      return true;
    } catch (e) {
      Logger.e('写入数据失败', e);
      return false;
    }
  }
  
  // 从设备读取数据 (用于接收ADC响应)
  Future<List<int>?> readData() async {
    try {
      if (_connectedDevice == null) {
        throw Exception('设备未连接');
      }
      
      // 获取设备服务
      List<fbp.BluetoothService> services = await _connectedDevice!.discoverServices();
      fbp.BluetoothCharacteristic? targetCharacteristic;
      
      // 查找目标特征
      for (fbp.BluetoothService service in services) {
        for (fbp.BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.characteristicUuid.toString() == 'beb5483e-36e1-4688-b7f5-ea07361b26a8') {
            targetCharacteristic = characteristic;
            break;
          }
        }
        if (targetCharacteristic != null) break;
      }
      
      if (targetCharacteristic == null) {
        // 如果没找到特定特征，尝试第一个可读特征
        for (fbp.BluetoothService service in services) {
          for (fbp.BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.properties.read) {
              targetCharacteristic = characteristic;
              break;
            }
          }
          if (targetCharacteristic != null) break;
        }
      }
      
      if (targetCharacteristic == null) {
        throw Exception('未找到可读的特征');
      }
      
      // 读取数据
      List<int> data = await targetCharacteristic.read();
      Logger.i('成功读取数据: $data');
      
      return data;
    } catch (e) {
      Logger.e('读取数据失败', e);
      return null;
    }
  }
  
  // 启用特征通知 (用于实时监听设备状态)
  Future<Stream<List<int>>?> enableNotifications() async {
    try {
      if (_connectedDevice == null) {
        throw Exception('设备未连接');
      }
      
      // 获取设备服务
      List<fbp.BluetoothService> services = await _connectedDevice!.discoverServices();
      fbp.BluetoothCharacteristic? targetCharacteristic;
      
      // 查找目标特征
      for (fbp.BluetoothService service in services) {
        for (fbp.BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.characteristicUuid.toString() == 'beb5483e-36e1-4688-b7f5-ea07361b26a8') {
            targetCharacteristic = characteristic;
            break;
          }
        }
        if (targetCharacteristic != null) break;
      }
      
      if (targetCharacteristic == null) {
        throw Exception('未找到目标特征');
      }
      
      // 启用通知
      await targetCharacteristic.setNotifyValue(true);
      Logger.i('成功启用特征通知');
      
      return targetCharacteristic.value;
    } catch (e) {
      Logger.e('启用通知失败', e);
      return null;
    }
  }

  // 释放资源
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
  }
}
