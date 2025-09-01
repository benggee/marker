import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import '../models/barcode_model.dart';
import 'database_service.dart';
import 'bluetooth_service.dart';
import '../utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:barcode/barcode.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BarcodeService {
  static final BarcodeService _instance = BarcodeService._internal();
  factory BarcodeService() => _instance;
  BarcodeService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final BluetoothService _bluetoothService = BluetoothService();

  // 生成新的条形码
  Future<BarcodeModel> generateBarcode() async {
    final nextId = await _databaseService.getNextBarcodeId();
    final now = DateTime.now();
    
    final barcode = BarcodeModel(
      barcodeId: nextId,
      content: nextId,
      createdAt: now,
      updatedAt: now,
    );
    
    await _databaseService.insertBarcode(barcode);
    return barcode;
  }

  // 生成条形码图片
  Future<Uint8List> generateBarcodeImage(String content, {double width = 300, double height = 100}) async {
    // 简化实现，直接返回空字节数组
    // 实际项目中可以使用更复杂的图片生成逻辑
    return Uint8List(0);
  }

  // 打印条形码到蓝牙打印机 - 完全按照您的协议实现
  Future<bool> printBarcode(BarcodeModel barcode) async {
    try {
      Logger.i('开始打印条形码: ${barcode.barcodeId}');
      
      // 检查蓝牙连接状态
      if (_bluetoothService.connectedDevice == null) {
        Logger.e('打印失败：没有连接的蓝牙设备');
        throw Exception('没有连接的蓝牙设备');
      }
      
      // 使用您的协议
      await _printBarcodeWithProtocol(barcode.barcodeId);
      return true;
    } catch (e) {
      Logger.e('打印条形码失败', e);
      return false;
    }
  }

  // 完全按照您的协议实现
  Future<void> _printBarcodeWithProtocol(String id) async {
    final Barcode code128 = Barcode.code93();
    final String data = id;

    final String svgStr = code128.toSvg(data, width: 300, height: 100);

    final DrawableRoot svgRoot = await svg.fromSvgString(svgStr, '');
    final Picture picture = svgRoot.toPicture();
    final ui.Image uiImage = await picture.toImage(300, 100);

    final ByteData? byteData = await uiImage.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    if (byteData == null) return;

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

    await _bluetoothService.sendRawData(prefix);
    await Future.delayed(Duration(microseconds: 50)); // 减少延迟

    for (Uint8List chunk in dataRows) {
      await _bluetoothService.sendRawData(chunk);
      await Future.delayed(Duration(microseconds: 30)); // 减少延迟
    }

    await _bluetoothService.sendRawData(suffix);
    // 移除最后的延迟
  }

  // 获取所有条形码
  Future<List<BarcodeModel>> getAllBarcodes() async {
    return await _databaseService.getAllBarcodes();
  }

  // 根据ID获取条形码
  Future<BarcodeModel?> getBarcodeById(String barcodeId) async {
    return await _databaseService.getBarcodeById(barcodeId);
  }

  // 删除条形码
  Future<int> deleteBarcode(int id) async {
    return await _databaseService.deleteBarcode(id);
  }

  // 格式化条形码ID（前面补0）
  String formatBarcodeId(String id) {
    return id.padLeft(6, '0');
  }

  // 验证条形码格式
  bool isValidBarcode(String barcode) {
    // 检查是否为6位数字
    return RegExp(r'^\d{6}$').hasMatch(barcode);
  }
}
