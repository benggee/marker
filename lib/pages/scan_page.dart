import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marker/widgets/object_list_widget.dart';

import '../utils/view_utils.dart';

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
    scanResult = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: scanResult == null
            ? GestureDetector(
          onTap: () {
            setState(() {
              scanResult = _scanBarcode();
            });
          },
          child: Container(
            height: 60,
            width: 200,
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black12, width: 1),
            ),
            child: Stack(
              children: [
                // Image(image: AssetImage('images/printer.png'), width: 20, height: 20, color: Colors.white,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.scanner,
                      color: Colors.black54,
                    ),
                    hiSpace(width: 10),
                    Text(
                      '扫描条码',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ],
                )
              ],
            ),
          ),
        )


        // ElevatedButton(
        //   onPressed: () {
        //     setState(() {
        //       scanResult = _scanBarcode();
        //     });
        //   },
        //   child: Text("扫描条码"),
        // )
            : FutureBuilder<Widget?>(
          future: scanResult,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
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
      ),
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