import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DeviceView();
  }
}

class _DeviceView extends State<DeviceView> {
  String? title;

  List<Map<String, String>> devices = [
    {"name": "Device 1", "status": "Not Connected"},
    {"name": "Device 2", "status": "Not Connected"},
    {"name": "Device 3", "status": "Not Connected"},
  ];

  bool isLoading = false;

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      var args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        title = args["title"];
        setState(() {

        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title ?? "")),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(devices[index]["name"]!),
                        trailing: Text(devices[index]["status"]!),
                        onTap: () {
                          setState(() {
                            isLoading = true;
                          });
                          // 模拟连接延时
                          Future.delayed(Duration(seconds: 2), () {
                            setState(() {
                              devices[index]["status"] = "Connected";
                              isLoading = false;
                            });
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 80), // 给底部按钮留出空间
              ],
            ),
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
                  onPressed: () {
                    // 开始搜索蓝牙设备的逻辑
                  },
                  child: Icon(Icons.search),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}