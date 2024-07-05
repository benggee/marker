import 'package:flutter/foundation.dart';
import 'package:marker/blue/bluetooth_manager.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceItem {
  String uuid;
  String deviceName;
  String characteristicsUUID;
  int state; // 0: disconnected, 1: connecting, 2: connected
  BluetoothDevice device;

  DeviceItem({
    required this.uuid,
    required this.deviceName,
    required this.characteristicsUUID,
    required this.state,
    required this.device,
  });
}

class DeviceModel with ChangeNotifier, DiagnosticableTreeMixin {
  static final DeviceModel _instance = DeviceModel._internal();

  factory DeviceModel() {
    return _instance;
  }

  DeviceModel._internal();


  BluetoothManager _bluetoothManager = BluetoothManager();
  List<DeviceItem> devices = [];
  DeviceItem? targetDevice; // Currenty device

  Future<List<DeviceItem>> fetchDevices() async {

    await for (var scanResults in _bluetoothManager.scanForDevices()) {
      for (var result in scanResults) {

        if (result.device.platformName == "") {
          continue;
        }

        if (devices.any((element) => element.uuid == result.device.remoteId.toString())) {
          continue;
        }

        int state = 0;
        if (result.device.isConnected) {
          state = 1;
        }

        devices.add(DeviceItem(
          uuid: result.device.remoteId.toString(),
          deviceName: result.device.platformName.toString(),
          characteristicsUUID: "",
          state: state,
          device: result.device,
        ));

        notifyListeners();
      }
    }
    return devices;
  }

  void setState(int index, int state) {
    for (var element in devices) {
      element.state = 0;
    }
    devices[index].state = state;
    targetDevice = devices[index];

    notifyListeners();
  }

  DeviceItem? getTargetDevice() {
    BluetoothCharacteristic? characteristic = _bluetoothManager.targetCharacteristic ?? null;

    devices.forEach((element) {
      if (element.uuid == characteristic?.remoteId.toString()) {
        targetDevice = element;
      }
    });

    return targetDevice;
  }
}