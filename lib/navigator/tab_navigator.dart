
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marker/pages/device_page.dart';
import 'package:marker/pages/print_page.dart';
import 'package:marker/pages/scan_page.dart';
import 'package:permission_handler/permission_handler.dart';

class TabNavigator extends StatefulWidget {
  const TabNavigator({super.key});

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  final _defaultColor = Colors.grey;
  final _activeColor = Colors.blue;
  var _curTab = 0;

  final PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (await Permission.storage
        .request()
        .isGranted) {
      print('Permission granted');
    } else {
      print('Permission denied');
    }
  }

      @override
  Widget build(BuildContext context) {
    return
     Scaffold(
          backgroundColor: Colors.white,
          body: PageView(
            controller: _controller,
            children: <Widget>[
              PrintPage(),
              ScanPage(),
              // ChangeNotifierProvider(create: (context) => DeviceModel(), child: DevicePage(),)
              DevicePage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _curTab,
            unselectedItemColor: _defaultColor,
            selectedItemColor: _activeColor,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              _controller.jumpToPage(index);
              setState(() {
                _curTab = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.print,
                ),
                activeIcon: Icon(
                  Icons.print,
                ),
                label: '打印',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.scanner,
                ),
                activeIcon: Icon(
                  Icons.scanner,
                ),
                label: '扫描',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.devices,
                ),
                activeIcon: Icon(
                  Icons.devices,
                ),
                label: '设备',
              ),
            ],
          ),
        );
  }
}
