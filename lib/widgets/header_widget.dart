import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/device_model.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  DeviceModel _deviceModel = DeviceModel();
  DeviceItem? _currDevice = null;
  double batteryLevel = 20.9;

  @override
  void initState() {
    super.initState();
    _fetchCurrDevice();
  }

  void _fetchCurrDevice() async {
    _currDevice = await _deviceModel.getDevice();
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currDevice != null) _deviceStatus(),
          if (_currDevice == null) _connectBtn(),
        ]
      )
    );
  }

  _connectBtn() {
    return ElevatedButtonTheme(
      data: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white,
          minimumSize: Size(35, 25), // 按钮最小尺寸
          padding: EdgeInsets.symmetric(horizontal: 10.0), // 水平内边距
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          // Utils.pushWithNamed(context, RoutePath.device, arguments: {
          //   "title": "设备管理",
          // });
          // 连接设备的逻辑
          print('Connecting to device...');
        },
        child: Text('连接设备', style: TextStyle(fontSize: 10.0, color: Colors.black87)),
      ),
    );
  }

  _deviceStatus() {
    return Container(
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Text(
                    "${_currDevice?.deviceName ?? "Unkown"}",
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight:
                        FontWeight.bold,
                        color:  Colors.black
                    )
                ), // 打印名称
              ),
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 30.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black,
                              width: 1.0
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      Positioned(
                        left: 1.0,
                        child:  Container(
                          // width: (value?.batLevel ?? 0) * 50.0,

                          width: batteryLevel,
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                                color: Colors.green,
                                width: 1.0
                            )
                          ),
                        ),
                      ),
                      Positioned(
                        left: 45,
                        child: Text('$batteryLevel%', style: TextStyle(fontSize: 10.0)),
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        ],
      )
    );
  }
}
