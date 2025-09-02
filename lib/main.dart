import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'core/app_theme.dart';
import 'features/bluetooth/bluetooth_page.dart';
import 'features/barcode/barcode_page.dart';
import 'features/scanner/scanner_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider()..initialize(),
      child: MaterialApp(
        title: '条形码管理系统',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BarcodePage(),
    const ScannerPage(),
    const BluetoothPage(),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.print_sharp),
            label: '打印',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: '查询',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.device_hub),
            label: '设备',
          ),

        ],
      ),
    );
  }
}
