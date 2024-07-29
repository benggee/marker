import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:marker/blue/bluetooth_manager.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:marker/store/shared_preference.dart';

class DeviceItem {
  String uuid;
  String deviceName;
  String characteristicsUUID;
  int state; // 0: disconnected, 1: connecting, 2: connected
  BluetoothDevice? device;

  DeviceItem({
    required this.uuid,
    required this.deviceName,
    required this.characteristicsUUID,
    required this.state,
    required this.device,
  });

  static fromJson(Map<String, dynamic> json) {
    return DeviceItem(
      uuid: json['uuid'],
      deviceName: json['deviceName'],
      characteristicsUUID: json['characteristicsUUID'],
      state: json['state'],
      device: null,
    );
  }

  static Map<String, dynamic> toJson(DeviceItem device) {
    return {
      'uuid': device.uuid,
      'deviceName': device.deviceName,
      'characteristicsUUID': device.characteristicsUUID,
      'state': device.state,
    };
  }
}

class DeviceModel with ChangeNotifier, DiagnosticableTreeMixin {
  static final DeviceModel _instance = DeviceModel._internal();
  final SharedPreference db = SharedPreference.instance;

  factory DeviceModel() {
    return _instance;
  }

  DeviceModel._internal();


  final BluetoothManager _bluetoothManager = BluetoothManager();
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

  Future<void> saveDevice(DeviceItem device) async {
    // print("device-json-0000001:${jsonEncode(device)}");
    await db.saveContent("connected-device", jsonEncode(DeviceItem.toJson(device)));
  }

  Future<DeviceItem?> getDevice() async {
    String? val = await db.getContent("connected-device");
    print("device-json:$val");
    if (val != "") {
      Map<String, dynamic> json = jsonDecode(val!);
      return DeviceItem.fromJson(json);
    }

    return null;
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