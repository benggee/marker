import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:marker/route/routes.dart';
import 'package:marker/route/utils.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Home();
  }

}

class _Home extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _printerView(false, "HP Printer Model X", "在线", 0.8),
            _btnView(),
            _listView(),
          ],
        )
      )
    );
  }

  Widget _printerView(bool isConnected, String printerName, String status, double batteryLevel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.print, size: 24.0), // 打印图标
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(printerName, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)), // 打印名称
                  Row(
                    children: [
                      Icon(Icons.battery_full, size: 20.0), // 电量图标
                      SizedBox(width: 5),
                      Text(status) // 状态
                    ],
                  )
                ],
              ),
            ],
          ),
          if (!isConnected) // 如果设备未连接
            TextButtonTheme(
              data: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  minimumSize: Size(60, 36), // 按钮最小尺寸
                  padding: EdgeInsets.symmetric(horizontal: 20.0), // 水平内边距
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0), // 圆角
                  ),
                ),
              ),
              child: TextButton(
                onPressed: () {
                  Utils.pushWithNamed(context, RoutePath.device, arguments: {
                    "title": "设备管理",
                  });
                  // 连接设备的逻辑
                  print('Connecting to device...');
                },
                child: Text('连接设备'),
              ),
            ),
        ],
      ),
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
                child:  TextButton(
                  onPressed: () {
                    print("Button Pressed");
                  },
                  child: Text("生成条码"),
                ),
              ),
              SizedBox(width: 16,),
              Expanded(
                child:  TextButton(
                  onPressed: () {
                    print("Button Pressed");
                  },
                  child: Text("扫描条码"),
                ),
              )
            ],
          )
      ),
    );
  }
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
            _buildTabContent([]), // 标签列表内容
            _buildTabContent([]), // 打印历史内容
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
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 两列
        childAspectRatio: 0.6, // 调整单元格宽高比
      ),
      itemBuilder: (context, index) {
        return _buildItem(items[index]);
      },
    );
  }
}

Widget _buildItem(item) {
  return Column(
    children: [
      Image.network(item['imageUrl'], fit: BoxFit.cover), // 条码图片
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(item['barcodeId'], style: TextStyle(fontWeight: FontWeight.bold)), // 条码ID
      ),
      Text(item['dimensions']), // 规格尺寸
    ],
  );
}