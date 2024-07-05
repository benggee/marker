import 'dart:async';
import 'dart:io';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:marker/route/routes.dart';
import 'package:marker/route/utils.dart';
import 'package:marker/views/device/device_model.dart';
import 'package:marker/widgets/barcode_content_dialog.dart';
import 'package:marker/widgets/barcode_dialog.dart';
import 'package:marker/views/home/barcode_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeView();
  }

}

class _HomeView extends State<HomeView> {
  DeviceModel _deviceModel = DeviceModel();

  List<BarcodeItem> labelList = [];
  List<BarcodeItem> printHistoryList = [];
  String barcode = "";

  @override
  void initState() {
    super.initState();

    _requestPermission();
    _deviceModel.getTargetDevice();
    _fetchData();
  }

  Future<void> _fetchData() async {
    List<BarcodeItem> barcodes = await BarcodeModel.fetchBarcodeItems();
    setState(() {
      labelList = barcodes.where((item) => !item.printed).toList();
      printHistoryList = barcodes.where((item) => item.printed).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _printerView(false, "HP Printer Model X", "在线", 20),
            _btnView(),
            _listView(),
          ],
        )
      )
    );
  }

  Future<void> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      print('Permission granted');
    } else {
      print('Permission denied');
    }
  }

  Widget _printerView(bool isConnected, String printerName, String status, double batteryLevel) {
    return ChangeNotifierProvider(create: (context) {
      return _deviceModel;
    }, child: Consumer<DeviceModel>(builder: (context, value, child) {
      bool notConnected = value.targetDevice?.state == 0 || value.targetDevice?.state == null;

      print("value: ${value.targetDevice?.deviceName}, states: ${value.targetDevice?.state}");
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (notConnected)
                  Icon(
                      Icons.print_disabled_outlined,
                      size: 24.0,
                  ), // 打印图标
                if (!notConnected)
                  Icon(
                      Icons.print_outlined,
                      size: 24.0
                  ), // 打印图标
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        value.targetDevice?.deviceName ?? "Unkown",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight:
                            FontWeight.bold,
                            color: notConnected ? Colors.grey.shade500 : Colors.black
                        )
                    ), // 打印名称
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
                                    color: value.targetDevice?.state == 0 || value.targetDevice?.state == null ? Colors.grey.shade300 : Colors.green,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 45,
                              child: Text('$batteryLevel%', style: TextStyle(fontSize: 10.0)),
                            )
                          ],
                        ),
                        SizedBox(width: 5),
                        Text(value.targetDevice?.state == 0 || value.targetDevice?.state == null ? "未连接" : "已连接", style: TextStyle(fontSize: 10.0)),
                      ],
                    )
                  ],
                ),
              ],
            ),
            if (notConnected) // 如果设备未连接
              ElevatedButtonTheme(
                data: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue.shade300,
                    minimumSize: Size(35, 25), // 按钮最小尺寸
                    padding: EdgeInsets.symmetric(horizontal: 10.0), // 水平内边距
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Utils.pushWithNamed(context, RoutePath.device, arguments: {
                      "title": "设备管理",
                    });
                    // 连接设备的逻辑
                    print('Connecting to device...');
                  },
                  child: Text('连接设备', style: TextStyle(fontSize: 10.0)),
                ),
              ),
          ],
        ),
      );
    })
    );
  }

  Widget _btnView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:  TextButtonTheme(
          data: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                minimumSize: Size(0, 60),
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // 内边距
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
              )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButtonTheme(
                  data: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      minimumSize: Size(50, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)
                      )
                    )
                  )   ,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await BarcodeDialog.show(context, BarcodeItem(id: "", url: "", dimensions: "", printed: false));
                      if (result == true) {
                        _fetchData();
                        setState(() {

                        });
                      }
                    },
                    child: Text("生成条码"),
                  )
                )
              ),
              SizedBox(width: 16,),
              Expanded(
                  child: ElevatedButtonTheme(
                      data: ElevatedButtonThemeData(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              minimumSize: Size(50, 60),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)
                              )
                          )
                      )   ,
                      child: ElevatedButton(
                        onPressed: () async {
                          _scanBarcode();
                          print("Button Pressed");
                        },
                        child: Text("扫描条码"),
                      )
                  )
              ),
            ],
          )
      ),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        barcode = result.rawContent;
      });
      _showScanResult(context, result.rawContent);
    } catch (e) {
      setState(() {
        barcode = 'Error: $e';
      });
    }
  }

  void _showScanResult(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BarcodeContentDialog(id: result);
      },
    );
  }

  Widget _listView() {
    return Expanded( // 1. 填满剩下整个页面
      child: DefaultTabController(
        length: 2, // 2个Tab
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50.0), // 设置TabBar的高度
            child: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(text: '标签列表'), // 第一个Tab
                  Tab(text: '打印历史'), // 第二个Tab
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _buildTabContent(labelList), // 标签列表内容
              _buildTabContent(printHistoryList), // 打印历史内容
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(List items) {
    if (items.isEmpty) {
      return Center(child: Text('暂无数据')); // 3. 没有数据时显示
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 两列
          crossAxisSpacing: 10.0, // 水平间距
          mainAxisSpacing: 10.0, // 垂直间距
          childAspectRatio: 1.6, // 调整单元格宽高比
        ),
        itemBuilder: (context, index) {
          return _buildItem(items[index]);
        },
      );
    }
  }

  Widget _buildItem(item) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          final result = await BarcodeDialog.show(context, item);
          if (result == true) {
            _fetchData();
            setState(() {

            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration (
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.url.endsWith('.png'))
                Flexible(
                    child: AspectRatio(
                      aspectRatio: 2.0,
                        child: Image.file(File(item.url), fit: BoxFit.cover)
                        //child: SvgPicture.file(File(item.url), fit: BoxFit.contain)
                    ),
                )
              else
                Flexible(child: Image.file(File(item.url), fit: BoxFit.cover)), // 条码图
            ],
          ),
        ),
      )
    );
  }
}

