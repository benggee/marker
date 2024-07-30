import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothManager {
  // Singleton pattern
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() {
    return _instance;
  }
  BluetoothManager._internal();

  BluetoothCharacteristic? _targetCharacteristic;


  BluetoothCharacteristic? get targetCharacteristic => _targetCharacteristic;

  // Discover devices
  Stream<List<ScanResult>> scanForDevices() {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    return FlutterBluePlus.scanResults;
  }

  // Connect to device
  Future<void> connectToDevice(BluetoothDevice device) async {

    if (await Permission.location.request().isGranted &&
        await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      if (device.isConnected == false) {
        await device.connect();
      }
      await _discoverAndSetCharacteristic(device);
    } else {
      throw Exception("Permissions not granted");
    }
  }

  // Disconnect from device
  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    if (await Permission.location.request().isGranted &&
        await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      if (!device.isConnected) return;
      await device.disconnect();
      _targetCharacteristic = null; // Clear the characteristic when disconnecte
    } else {
      throw Exception("Permissions not granted");
    }
  }

  // Get list of connected devices
  Future<List<BluetoothDevice>> getConnectedDevices() async {
    return await FlutterBluePlus.connectedDevices;
  }

  // Discover services of a connected device and set the target characteristic
  Future<void> _discoverAndSetCharacteristic(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        print('Characteristic: ${characteristic.characteristicUuid.toString()}');
        // _targetCharacteristic = characteristic;
        // break;
        if (characteristic.characteristicUuid.toString() == 'beb5483e-36e1-4688-b7f5-ea07361b26a8') {
          _targetCharacteristic = characteristic;
          break;
        }
      }
      if (_targetCharacteristic != null) break;
    }

    print("last-characteristic: ${_targetCharacteristic?.characteristicUuid.toString()}");
    return;
  }

  // Write data to the target characteristic
  Future<void> writeToCharacteristic(List<int> value) async {
    if (_targetCharacteristic != null) {
      await _targetCharacteristic!.write(value, withoutResponse: false);
    } else {
      throw Exception('Target characteristic is not set');
    }
  }

  // Read data from the target characteristic
  Future<List<int>> readFromCharacteristic() async {
    if (_targetCharacteristic != null) {
      return await _targetCharacteristic!.read();
    } else {
      throw Exception('Target characteristic is not set');
    }
  }

  // Notify on characteristic changes
  Stream<List<int>> notifyCharacteristic() {
    if (_targetCharacteristic != null) {
      _targetCharacteristic!.setNotifyValue(true);
      return _targetCharacteristic!.value;
    } else {
      throw Exception('Target characteristic is not set');
    }
  }
}