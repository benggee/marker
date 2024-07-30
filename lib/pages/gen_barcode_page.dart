import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marker/utils/barcode_utils.dart';
import 'package:marker/utils/str_utils.dart';
import 'package:marker/widgets/header_widget.dart';
import 'package:marker/widgets/object_list_widget.dart';

import '../model/barcode_model.dart';

class GenBarcodePage extends StatefulWidget {
  const GenBarcodePage({super.key});

  @override
  State<GenBarcodePage> createState() => _GenBarcodePageState();
}

class _GenBarcodePageState extends State<GenBarcodePage> {
  @override
  Widget build(BuildContext context) {
    String id = generateRandomId();
    String svgBarcodeImage = genBarcode(id);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HeaderWidget(),
            // Text('打印条码'),
            GestureDetector(
              onTap: () async {
                await BarcodeModel().printBarcode(id);
                print('Print button pressed');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green.shade200,
                    content: Text('条形码已下发到打印机', style: TextStyle(color: Colors.white)),
                    duration: Duration(seconds: 2),
                  ),
                );

                Navigator.of(context).pop(true);
              },
              child: Icon(Icons.print_outlined),
            ),
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              margin: const EdgeInsets.fromLTRB(25, 10, 25, 20),
              child: SvgPicture.string(svgBarcodeImage, height: 120),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Expanded(child: ObjectListWidget(id: id)),
          ],
        )
      )
    );
  }
}
