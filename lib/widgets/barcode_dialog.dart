import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:barcode/barcode.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marker/views/home/barcode_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class BarcodeDialog {
  static Future<bool?> show(BuildContext context, BarcodeItem item) {
    String randomId = item.id ?? "";

    if (item.id.isEmpty) {
      randomId =  _generateRandomId();
    }
    String barcodeSvg = "";
    if (item.url.isEmpty) {
      barcodeSvg = _generateBarcode(randomId);
    }

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.url.isEmpty)
                SvgPicture.string(barcodeSvg, width: 300, height: 100),
              if (item.url.isNotEmpty)
                Image.file(File(item.url), width: 300, height: 100),
              //SvgPicture.string(barcodeSvg, width: 300, height: 100),
              SizedBox(height: 10),
              // Text(randomId, style: TextStyle(fontSize: 24)),
              // SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (item.url.isNotEmpty)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: Colors.red.shade400,
                        ),
                        onPressed: () async {
                          await _deleteFile(item.url);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                backgroundColor: Colors.red.shade200,
                                content: Text('已删除条形码', style: TextStyle(color: Colors.white)),
                                duration: Duration(seconds: 2),
                            ),
                          );

                          Navigator.of(context).pop(true);
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child:Text('删除', style: TextStyle(color: Colors.white)),
                        )
                      ),
                    ),
                  SizedBox(width: 10),
                  if (item.url.isEmpty)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            )
                        ),
                        onPressed: () async {
                          await _saveBarcode(randomId, barcodeSvg);
                          print('Save button pressed');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green.shade200,
                              content: Text('条形码已保存', style: TextStyle(color: Colors.white)),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          Navigator.of(context).pop(true);
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child:  Text('保存'),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        )
                    ),
                    onPressed: () async {
                      // PrinterService printerService = PrinterService();
                      // String url = "https://pngimg.com/uploads/barcode/barcode_PNG75.png";
                      // await printTest.testPrint(url);
                      if (barcodeSvg.isNotEmpty) {
                        await _saveBarcode(randomId, barcodeSvg);
                      }
                      await BarcodeModel().printBarcode(randomId);
                      await _setPrintedStatus(randomId, true);
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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child:  Text('打印'),
                    )
                  ),)
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

  static Future<void> _deleteFile(String filePath) async {
    try {
      File file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        print('File deleted successfully: $filePath');
      } else {
        print('File does not exist: $filePath');
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  static Future<void> _saveBarcode(String id, String barcodeSvg) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      //final path = '${directory.path}/$id.svg';

      await _svgStringToPicture(barcodeSvg, 300, 100).then((ui.Picture picture) async {
        final img = await picture.toImage(300, 100);
        final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
        final pngUint8List = Uint8List.view(pngBytes!.buffer);
        final file = File('${directory.path}/$id.png');
        await file.writeAsBytes(pngUint8List);

        print('Barcode saved to: ${directory.path}/${id}.png');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('${id}_printed', false);

      });

      // final file = File(path);
      // await file.writeAsString(barcodeSvg);
      //
      // print('Barcode saved to: $path');

      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setBool('${id}_printed', false);

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
