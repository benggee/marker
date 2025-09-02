import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import '../models/barcode_model.dart';
import 'database_service.dart';
import 'bluetooth_service.dart';
import '../utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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
        return false;
      }
      
      // 使用您的协议
      await _printBarcodeWithProtocol(barcode.barcodeId);
      Logger.i('条形码打印成功: ${barcode.barcodeId}');
      return true;
    } catch (e) {
      Logger.e('打印条形码失败: ${barcode.barcodeId}', e);
      return false;
    }
  }

  // 完全按照您的协议实现
  Future<void> _printBarcodeWithProtocol(String id) async {
    Logger.i('开始打印条形码: $id');
    
    // 等待一下，确保上次打印完全结束
    await Future.delayed(Duration(milliseconds: 200));
    
    // 对于6位纯数字，Code39比Code128密度更低，更适合热敏打印机
    final Barcode barcode = Barcode.code39();  // 使用Code39，密度较低，更清晰
    final String data = formatBarcodeId(id);    // 格式化为6位数字

    // 55mm热敏纸，使用适中分辨率平衡速度和质量
    // 55mm纸张 ≈ 6点/mm 分辨率，既保证质量又提升速度
    // 根据实际打印效果调整，可能需要更高的分辨率设置
    const int paperWidth = 384;   // 调整为更准确的55mm对应像素值
    const int barcodeWidth = 380; // 几乎占满整个宽度，只留2像素边距
    const int barcodeHeight = 90; // 保持高度90像素
    const int textHeight = 30;    // 文字高度30像素
    const int padding = 8;        // 内部边距
    const int bottomPadding = 35; // 增加ID下方空白到35像素
    const int totalHeight = barcodeHeight + textHeight + padding * 2 + bottomPadding; // 总高度约153像素

    final String svgStr = barcode.toSvg(
      data, 
      width: barcodeWidth.toDouble(), 
      height: barcodeHeight.toDouble(),
      drawText: false, // 我们将手动绘制文本以更好控制位置
    );

    final DrawableRoot svgRoot = await svg.fromSvgString(svgStr, '');
    final Picture picture = svgRoot.toPicture();
    
    // 创建居中的画布
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // 调整左边距，让条形码更靠左以减少右边空隙
    final double barcodeOffsetX = 1.0; // 左边距设为1像素，让条形码靠左
    final double barcodeOffsetY = padding.toDouble(); // 条形码距离顶部的位置
    
    Logger.i('55mm纸张布局调整: 纸张宽度=${paperWidth}px, 条形码宽度=${barcodeWidth}px, 左边距=${barcodeOffsetX}px, 右边距=${paperWidth - barcodeWidth - barcodeOffsetX}px');
    
    // 填充纯白色背景
    final backgroundPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, paperWidth.toDouble(), totalHeight.toDouble()),
      backgroundPaint,
    );
    
    // 绘制条形码
    canvas.save();
    canvas.translate(barcodeOffsetX, barcodeOffsetY);
    canvas.drawPicture(picture);
    canvas.restore();
    
    // 绘制ID文字
    final textStyle = TextStyle(
      color: const Color(0xFF000000), // 黑色文字
      fontSize: 26, // 继续增加字体大小到26
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: data,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // 计算文字居中位置
    final textOffsetX = (paperWidth - textPainter.width) / 2;
    final textOffsetY = barcodeOffsetY + barcodeHeight + padding.toDouble();
    
    // 绘制文字
    textPainter.paint(canvas, Offset(textOffsetX, textOffsetY));
    
    final Picture centeredPicture = recorder.endRecording();
    final ui.Image uiImage = await centeredPicture.toImage(paperWidth, totalHeight);
    Logger.i('生成图像尺寸: ${uiImage.width}x${uiImage.height}');

    final ByteData? byteData = await uiImage.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    if (byteData == null) {
      Logger.e('无法获取图像数据');
      return;
    }

    final Uint8List imageData = byteData.buffer.asUint8List();
    Logger.i('图像数据大小: ${imageData.length} bytes');

    int width = uiImage.width;  // 现在是384像素
    int height = uiImage.height; // 现在是80像素

    Uint8List pixels = Uint8List(width * height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixelIndex = (y * width + x) * 4;
        
        // 获取RGBA值
        int r = imageData[pixelIndex];     // 红色
        int g = imageData[pixelIndex + 1]; // 绿色
        int b = imageData[pixelIndex + 2]; // 蓝色
        int a = imageData[pixelIndex + 3]; // Alpha
        
        // 计算亮度 (使用标准RGB到灰度转换公式)
        int luma = ((r * 299 + g * 587 + b * 114) / 1000).round();
        
        // 考虑alpha通道
        if (a < 128) {
          // 透明像素视为白色
          pixels[y * width + x] = 255; // 白色
        } else {
          // 根据亮度判断黑白，亮度低的为黑色（条形码），亮度高的为白色（背景）
          pixels[y * width + x] = luma < 128 ? 0 : 255; // 0=黑色(条形码), 255=白色(背景)
        }
      }
    }

    // 统计黑白像素数量
    int blackPixels = 0;
    int whitePixels = 0;
    for (int pixel in pixels) {
      if (pixel == 0) blackPixels++;
      else whitePixels++;
    }
    Logger.i('像素统计 - 黑色: $blackPixels, 白色: $whitePixels');

    // 验证像素数据的完整性
    if (blackPixels == 0) {
      Logger.w('警告：没有检测到黑色像素，条形码可能为空');
    }
    if (whitePixels == 0) {
      Logger.w('警告：没有检测到白色像素，背景可能有问题');
    }

    List<Uint8List> dataRows = [];
    for (int y = 0; y < height; y++) {
      Uint8List rowData = Uint8List((width / 8).ceil());
      for (int x = 0; x < width; x++) {
        int byteIndex = x ~/ 8;
        int bitIndex = 7 - (x % 8);
        // 如果像素是黑色(0)，则设置对应位为1（表示打印）
        if (pixels[y * width + x] == 0) {
          rowData[byteIndex] |= (1 << bitIndex);
        }
        // 白色像素(255)对应位保持0（表示不打印）
      }
      dataRows.add(rowData);
    }

    List<int> prefix = [0xA5, 0xA5, 0xA5, 0xA5, 0x03];
    List<int> suffix = [0xA6, 0xA6, 0xA6, 0xA6, 0x01];
    
    // 验证协议头内容
    Logger.i('协议头定义: ${prefix.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
    Logger.i('协议头十进制: $prefix');

    Logger.i('准备发送数据：条形码 ${dataRows.length} 行，ID下方已增加额外空白');
    Logger.i('每行数据大小: ${(paperWidth ~/ 8)} bytes, 图像尺寸: ${width}x${height}');

    // 发送协议头
    Logger.i('即将发送协议头: $prefix');
    bool prefixSent = await _bluetoothService.sendRawData(prefix);
    if (!prefixSent) {
      Logger.e('协议头发送失败');
      throw Exception('协议头发送失败');
    }
    await Future.delayed(Duration(milliseconds: 50)); // 减少延迟
    Logger.i('协议头发送成功: ${prefix.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
    
    // 检查是否需要发送数据长度信息（某些打印机协议需要）
    // 如果打印机不工作，可能需要取消注释下面的代码
    /*
    int totalDataLength = allImageData.length;
    List<int> lengthInfo = [
      (totalDataLength & 0xFF),         // 长度低字节
      ((totalDataLength >> 8) & 0xFF),  // 长度高字节
    ];
    bool lengthSent = await _bluetoothService.sendRawData(lengthInfo);
    if (!lengthSent) {
      Logger.e('数据长度信息发送失败');
      throw Exception('数据长度信息发送失败');
    }
    Logger.i('数据长度信息发送成功: $totalDataLength bytes');
    await Future.delayed(Duration(milliseconds: 10));
    */

    // 回到逐行发送方式，这可能是你的打印机协议要求的
    Logger.i('开始逐行发送图像数据');
    
    // 先发送条形码数据
    for (int i = 0; i < dataRows.length; i++) {
      bool rowSent = await _bluetoothService.sendRawData(dataRows[i]);
      if (!rowSent) {
        Logger.e('条形码数据第 ${i + 1} 行发送失败');
        throw Exception('条形码数据发送失败');
      }
      await Future.delayed(Duration(milliseconds: 1)); // 减少延迟，提高速度
    }
    Logger.i('条形码数据发送完成，共 ${dataRows.length} 行');
    
    // 发送协议尾，结束图像数据传输
    // 打印机端将自动处理走纸
    bool suffixSent = await _bluetoothService.sendRawData(suffix);
    if (!suffixSent) {
      Logger.e('协议尾发送失败');
      throw Exception('协议尾发送失败');
    }
    Logger.i('协议尾发送成功: ${suffix.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
    Logger.i('打印命令发送完成，打印机端将自动处理走纸');
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
