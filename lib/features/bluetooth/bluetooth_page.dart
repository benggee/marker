import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/app_provider.dart';
import '../../models/bluetooth_device_model.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/permission_helper.dart';
import '../../utils/logger.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> _discoveredDevices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final hasPermissions = await PermissionHelper.checkBluetoothPermissions();
      if (!hasPermissions) {
        if (mounted) {
          // 显示详细的权限说明对话框
          await PermissionHelper.showPermissionDialog(context);
        }
      }
    } catch (e) {
      Logger.e('权限检查失败', e);
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _discoveredDevices.clear();
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // 首先检查权限
      bool hasPermissions = await PermissionHelper.checkBluetoothPermissions();
      if (!hasPermissions) {
        throw Exception('缺少必要的蓝牙权限');
      }
      
      await provider.bluetoothService.startScan(timeout: const Duration(seconds: 10));
      
      // 监听扫描结果
      provider.bluetoothService.scanForDevices().listen((devices) {
        setState(() {
          _discoveredDevices = devices;
        });
      });

      // 10秒后停止扫描
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
          provider.bluetoothService.stopScan();
        }
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
        String errorMessage = '扫描失败';
        if (e.toString().contains('Permission') || e.toString().contains('权限')) {
          errorMessage = '缺少蓝牙权限，请在设置中授予以下权限：\n• 蓝牙扫描\n• 蓝牙连接\n• 位置信息';
        } else if (e.toString().contains('蓝牙未开启')) {
          errorMessage = '蓝牙未开启，请先开启蓝牙';
        } else {
          errorMessage += ': $e';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '去设置',
              onPressed: () {
                // 打开应用设置页面
                openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: '加载中...');
          }

          return Column(
            children: [
              // 当前连接状态
              _buildConnectionStatus(provider),
              
              // 扫描按钮
              _buildScanButton(),
              
              // 已记住的设备
              _buildRememberedDevices(provider),
              
              // 发现的设备
              _buildDiscoveredDevices(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatus(AppProvider provider) {
    final connectedDevice = provider.connectedDevice;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: connectedDevice != null ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: connectedDevice != null ? Colors.green : Colors.grey,
        ),
      ),
      child: Row(
        children: [
          Icon(
            connectedDevice != null ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: connectedDevice != null ? Colors.green : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connectedDevice != null ? '已连接' : '未连接',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: connectedDevice != null ? Colors.green : Colors.grey,
                  ),
                ),
                if (connectedDevice != null)
                  Text(
                    connectedDevice.platformName.isNotEmpty 
                        ? connectedDevice.platformName 
                        : 'Unknown Device',
                    style: const TextStyle(fontSize: 14),
                  ),
              ],
            ),
          ),
          if (connectedDevice != null)
            TextButton(
              onPressed: () => provider.disconnectBluetooth(),
              child: const Text('断开'),
            ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isScanning ? null : _startScan,
          icon: _isScanning 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search),
          label: Text(_isScanning ? '扫描中...' : '扫描设备'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildRememberedDevices(AppProvider provider) {
    if (provider.bluetoothDevices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '已记住的设备',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.bluetoothDevices.length,
          itemBuilder: (context, index) {
            final device = provider.bluetoothDevices[index];
            return _buildDeviceTile(device, provider, isRemembered: true);
          },
        ),
      ],
    );
  }

  Widget _buildDiscoveredDevices() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '发现的设备',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _discoveredDevices.isEmpty
                ? const Center(
                    child: Text(
                      '没有发现设备',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _discoveredDevices.length,
                    itemBuilder: (context, index) {
                      final device = _discoveredDevices[index];
                      return _buildDiscoveredDeviceTile(device);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(BluetoothDeviceModel device, AppProvider provider, {bool isRemembered = false}) {
    return ListTile(
      leading: Icon(
        device.isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
        color: device.isConnected ? Colors.green : Colors.grey,
      ),
      title: Text(device.name),
      subtitle: Text(device.address),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (device.isConnected)
            const Chip(
              label: Text('已连接'),
              backgroundColor: Colors.green,
              labelStyle: TextStyle(color: Colors.white),
            ),
          if (isRemembered)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeDevice(device, provider),
            ),
        ],
      ),
      onTap: () => _connectToDevice(device, provider),
    );
  }

  Widget _buildDiscoveredDeviceTile(BluetoothDevice device) {
    return ListTile(
      leading: const Icon(Icons.bluetooth_searching),
      title: Text(device.platformName.isNotEmpty ? device.platformName : 'Unknown Device'),
      subtitle: Text(device.remoteId.toString()),
      trailing: ElevatedButton(
        onPressed: () => _connectToDiscoveredDevice(device),
        child: const Text('连接'),
      ),
    );
  }

  Future<void> _connectToDevice(BluetoothDeviceModel device, AppProvider provider) async {
    // 这里需要从数据库模型转换为实际的BluetoothDevice对象
    // 由于数据库只存储了基本信息，这里简化处理
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('请重新扫描并连接设备')),
    );
  }

  Future<void> _connectToDiscoveredDevice(BluetoothDevice device) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final success = await provider.connectBluetoothDevice(device);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('连接成功')),
      );
    }
  }

  Future<void> _removeDevice(BluetoothDeviceModel device, AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除设备'),
        content: Text('确定要删除设备 "${device.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.removeBluetoothDevice(device.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('设备已删除')),
        );
      }
    }
  }
}
