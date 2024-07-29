import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marker/widgets/object_list_widget.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  Future<Widget?>? scanResult;

  @override
  void initState() {
    super.initState();
    scanResult = _scanBarcode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: FutureBuilder<Widget?>(
          future: scanResult,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError)  {
                return Text('扫描失败: ${snapshot.error}');
              } else if (snapshot.hasData) {
                return snapshot.data!;
              } else {
                return Text('扫描失败: 未知错误');
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      )
    );
  }

  Future<Widget?> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();

      return ObjectListWidget(id: result.rawContent);
    } catch (e) {
      return Text('扫描失败: ${e.toString()}');
    }
  }
}
