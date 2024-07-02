import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:barcode/barcode.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class BarcodeDialog {
  static void show(BuildContext context) {
    String randomId = _generateRandomId();
    String barcodeSvg = _generateBarcode(randomId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.string(barcodeSvg, width: 300, height: 100),
              SizedBox(height: 10),
              Text(randomId, style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _saveBarcode(randomId, barcodeSvg);
                      await _setPrintedStatus(randomId, true);
                      print('Print button pressed');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Barcode printed and saved')),
                      );
                    },
                    child: Text('去打印'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _saveBarcode(randomId, barcodeSvg);
                      print('Save button pressed');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Barcode saved')),
                      );
                    },
                    child: Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static String _generateRandomId() {
    const length = 10;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }

  static String _generateBarcode(String data) {
    final bc = Barcode.code128();
    final svg = bc.toSvg(data, width: 300, height: 100);
    return svg;
  }

  static Future<void> _saveBarcode(String id, String barcodeSvg) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$id.png';
      final picture = await _svgStringToPicture(barcodeSvg, 300, 100);
      final image = await picture.toImage(300, 100);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      print("save-path: $path");

      final file = File(path);
      await file.writeAsBytes(buffer);
      print('Barcode saved to $path');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${id}_printed', false); // Set initial print status to false
    } catch (e) {
      print('Error saving barcode: $e');
    }
  }

  static Future<ui.Picture> _svgStringToPicture(String svgString, double width, double height) async {
    final svgRoot = await svg.fromSvgString(svgString, svgString);
    return svgRoot.toPicture(size: Size(width, height));
  }

  static Future<void> _setPrintedStatus(String id, bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${id}_printed', status);
  }

  static Future<bool> _getPrintedStatus(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${id}_printed') ?? false;
  }
}
