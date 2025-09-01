import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutter_blue;
import '../models/barcode_model.dart';
import '../models/inventory_item_model.dart';
import '../models/bluetooth_device_model.dart';
import '../services/database_service.dart';
import '../services/bluetooth_service.dart';
import '../services/barcode_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService databaseService = DatabaseService();
  final BluetoothService bluetoothService = BluetoothService();
  final BarcodeService barcodeService = BarcodeService();

  // 状态变量
  List<BarcodeModel> _barcodes = [];
  List<InventoryItemModel> _currentInventoryItems = [];
  List<BluetoothDeviceModel> _bluetoothDevices = [];
  BarcodeModel? _currentBarcode;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<BarcodeModel> get barcodes => _barcodes;
  List<InventoryItemModel> get currentInventoryItems => _currentInventoryItems;
  List<BluetoothDeviceModel> get bluetoothDevices => _bluetoothDevices;
  BarcodeModel? get currentBarcode => _currentBarcode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  flutter_blue.BluetoothDevice? get connectedDevice => bluetoothService.connectedDevice;

  // 初始化
  Future<void> initialize() async {
    await loadBarcodes();
    await loadBluetoothDevices();
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 设置错误信息
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // 加载条形码列表
  Future<void> loadBarcodes() async {
    try {
      _setLoading(true);
      _barcodes = await barcodeService.getAllBarcodes();
      _setError(null);
    } catch (e) {
      _setError('加载条形码失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 生成新条形码
  Future<BarcodeModel?> generateBarcode() async {
    try {
      _setLoading(true);
      final barcode = await barcodeService.generateBarcode();
      await loadBarcodes(); // 重新加载列表
      _setError(null);
      return barcode;
    } catch (e) {
      _setError('生成条形码失败: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 打印条形码
  Future<bool> printBarcode(BarcodeModel barcode) async {
    try {
      _setLoading(true);
      final success = await barcodeService.printBarcode(barcode);
      if (success) {
        _setError(null);
      } else {
        _setError('打印失败，请检查蓝牙连接');
      }
      return success;
    } catch (e) {
      _setError('打印条形码失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 设置当前条形码
  void setCurrentBarcode(BarcodeModel? barcode) {
    _currentBarcode = barcode;
    if (barcode != null) {
      loadInventoryItems(barcode.barcodeId);
    } else {
      _currentInventoryItems.clear();
    }
    notifyListeners();
  }

  // 加载库存项目
  Future<void> loadInventoryItems(String barcodeId) async {
    try {
      _setLoading(true);
      _currentInventoryItems = await databaseService.getInventoryItemsByBarcodeId(barcodeId);
      _setError(null);
    } catch (e) {
      _setError('加载库存项目失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 添加库存项目
  Future<bool> addInventoryItem(String barcodeId, String name, String description, int quantity) async {
    try {
      _setLoading(true);
      final item = InventoryItemModel(
        barcodeId: barcodeId,
        name: name,
        description: description,
        quantity: quantity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await databaseService.insertInventoryItem(item);
      await loadInventoryItems(barcodeId);
      _setError(null);
      return true;
    } catch (e) {
      _setError('添加库存项目失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 更新库存项目
  Future<bool> updateInventoryItem(InventoryItemModel item) async {
    try {
      _setLoading(true);
      final updatedItem = item.copyWith(updatedAt: DateTime.now());
      await databaseService.updateInventoryItem(updatedItem);
      await loadInventoryItems(item.barcodeId);
      _setError(null);
      return true;
    } catch (e) {
      _setError('更新库存项目失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 删除库存项目
  Future<bool> deleteInventoryItem(InventoryItemModel item) async {
    try {
      _setLoading(true);
      await databaseService.deleteInventoryItem(item.id!);
      await loadInventoryItems(item.barcodeId);
      _setError(null);
      return true;
    } catch (e) {
      _setError('删除库存项目失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 加载蓝牙设备
  Future<void> loadBluetoothDevices() async {
    try {
      _setLoading(true);
      _bluetoothDevices = await bluetoothService.getRememberedDevices();
      _setError(null);
    } catch (e) {
      _setError('加载蓝牙设备失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 连接蓝牙设备
  Future<bool> connectBluetoothDevice(dynamic device) async {
    try {
      _setLoading(true);
      final success = await bluetoothService.connectToDevice(device);
      if (success) {
        await loadBluetoothDevices();
        _setError(null);
      } else {
        _setError('连接设备失败');
      }
      return success;
    } catch (e) {
      _setError('连接蓝牙设备失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 断开蓝牙连接
  Future<void> disconnectBluetooth() async {
    try {
      _setLoading(true);
      await bluetoothService.disconnectDevice();
      await loadBluetoothDevices();
      _setError(null);
    } catch (e) {
      _setError('断开连接失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 删除记住的蓝牙设备
  Future<void> removeBluetoothDevice(String deviceId) async {
    try {
      _setLoading(true);
      await bluetoothService.removeRememberedDevice(deviceId);
      await loadBluetoothDevices();
      _setError(null);
    } catch (e) {
      _setError('删除设备失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 清除错误信息
  void clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    bluetoothService.dispose();
    super.dispose();
  }
}
