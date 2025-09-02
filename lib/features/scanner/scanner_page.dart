import 'package:flutter/material.dart';
import '../../widgets/status_indicator.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫描'),
        leading: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: StatusIndicator(),
        ),
        leadingWidth: 160, // 给状态指示器留足够的空间
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              '扫描功能',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '扫描功能暂时不可用',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // 暂时禁用扫描功能
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('扫描功能正在开发中...'),
                  ),
                );
              },
              child: const Text('扫描条形码'),
            ),
          ],
        ),
      ),
    );
  }
}
