
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:barcode/barcode.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marker/blue/bluetooth_manager.dart';
import 'package:marker/model/device_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarcodeItem {
  final String id;
  final String url;
  final String dimensions;
  final bool printed;

  BarcodeItem({
    required this.id,
    required this.url,
    required this.dimensions,
    required this.printed,
  });
}

class BarcodeModel {
  BluetoothManager _bluetoothManager = BluetoothManager();

  static Future<List<BarcodeItem>> fetchBarcodeItems() async {
    final directory = await getApplicationDocumentsDirectory();
    final prefs = await SharedPreferences.getInstance();

    final files = directory.listSync().where((file) => file.path.endsWith('.png')).toList();
    List<BarcodeItem> barcodes = [];

    for (var file in files) {
      final id = file.path.split('/').last.split('.').first;
      final printed = prefs.getBool('${id}_printed') ?? false;
      barcodes.add(BarcodeItem(id: id, url: file.path, dimensions: "298x100", printed: printed));
    }

    return barcodes;
  }

  Future<void> printBarcode(String id) async {
    final Barcode code128 = Barcode.code93();
    final String data = id;

    final String svgStr = code128.toSvg(data, width: 300, height: 100);

    final DrawableRoot svgRoot = await svg.fromSvgString(svgStr, '');
    final Picture picture = svgRoot.toPicture();
    final ui.Image uiImage = await picture.toImage(300, 100);

    final ByteData? byteData = await uiImage.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    if (byteData == null) return null;

    final Uint8List imageData = byteData.buffer.asUint8List();

    int width = uiImage.width;
    int height = uiImage.height;

    Uint8List pixels = Uint8List(width * height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixelIndex = (y * width + x) * 4;
        int alpha = imageData[pixelIndex + 3];

        int luma = (alpha > 128) ? 255 : 0;
        pixels[y * width + x] = luma >= 128 ? 0 : 255;
      }
    }

    List<Uint8List> dataRows = [];
    for (int y = 0; y < height; y++) {
      Uint8List rowData = Uint8List((width / 8).ceil());
      for (int x = 0; x < width; x++) {
        int byteIndex = x ~/ 8;
        int bitIndex = 7 - (x % 8);
        if (pixels[y * width + x] == 0) {
          rowData[byteIndex] |= (1 << bitIndex);
        }
      }
      dataRows.add(rowData);
    }

    List<int> prefix = [0xA5, 0xA5, 0xA5, 0xA5, 0x03];
    List<int> suffix = [0xA6, 0xA6, 0xA6, 0xA6, 0x01];

    await _bluetoothManager.writeToCharacteristic(prefix);
    await Future.delayed(Duration(microseconds: 100));

    for (Uint8List chunk in dataRows) {
      await _bluetoothManager.writeToCharacteristic(chunk);
      await Future.delayed(Duration(microseconds: 100));
    }

    await _bluetoothManager.writeToCharacteristic(suffix);
    // await Future.delayed(Duration(milliseconds: 10));
  }
}
