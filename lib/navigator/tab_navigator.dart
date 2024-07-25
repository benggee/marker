
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marker/pages/device_page.dart';
import 'package:marker/pages/print_page.dart';
import 'package:marker/pages/scan_page.dart';
import 'package:marker/pages/search_page.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _controller,
        children: <Widget>[
          PrintPage(),
          SearchPage(),
          ScanPage(),
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
              Icons.search,
            ),
            activeIcon: Icon(
              Icons.search,
            ),
            label: '搜索',
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
