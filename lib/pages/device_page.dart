import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marker/blue/bluetooth_manager.dart';
import 'package:marker/model/device_model.dart';
import 'package:provider/provider.dart';
import 'package:marker/utils/route.dart' as RouteUtils;

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DevicePage();
  }
}

class _DevicePage extends State<DevicePage> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  String? title;
  bool isLoading = false;

  @override
  void initState(){
    super.initState();

    _fetchDevice();
  }

  Future<void> _fetchDevice() async {

    DeviceModel deviceModel = Provider.of<DeviceModel>(context, listen: false);

    await deviceModel.fetchDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title ?? "")),
      body: SafeArea(
        child: Stack(
          children: [
            _deviceView(),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  onPressed: () {
                    isLoading = true;
                    _fetchDevice();

                  },
                  child: Text('刷新', style: TextStyle(color: Colors.black54)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceView() {
    return Consumer<DeviceModel>(builder: (context, value, child) {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: value.devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(value.devices[index].deviceName!),
                  // trailing: Text(value.devices[index].state == 0 ? '未连接' : '已连接'),
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });

                    await _bluetoothManager.connectToDevice(value.devices[index].device!);

                    setState(() {
                      isLoading = false;
                    });

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          title: Text('连接成功', style: TextStyle(fontSize: 14)),
                          content: Text('已连接到设备: ${value.devices[index].deviceName}'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                DeviceModel deviceModel = Provider.of<DeviceModel>(context, listen: false);
                                await deviceModel.saveDevice(value.devices[index]);
                                RouteUtils.Utils.pushWithNamed(context, '/');
                              },
                              child: Text('去打印'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 80), // 给底部按钮留出空间
        ],
      );
    });
  }
}