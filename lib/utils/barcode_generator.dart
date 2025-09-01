import 'package:barcode/barcode.dart';

/// 条形码生成工具类
/// 参考专业的条形码生成和打印实现
class BarcodeGenerator {
  /// 生成Code128条形码的SVG字符串
  static String generateCode128Svg(String data, {double width = 300, double height = 100}) {
    final bc = Barcode.code128();
    return bc.toSvg(data, width: width, height: height);
  }

  /// 生成Code93条形码的SVG字符串
  static String generateCode93Svg(String data, {double width = 300, double height = 100}) {
    final bc = Barcode.code93();
    return bc.toSvg(data, width: width, height: height);
  }

  /// 生成EAN13条形码的SVG字符串
  static String generateEan13Svg(String data, {double width = 300, double height = 100}) {
    final bc = Barcode.ean13();
    return bc.toSvg(data, width: width, height: height);
  }

  /// 生成UPC条形码的SVG字符串
  static String generateUpcSvg(String data, {double width = 300, double height = 100}) {
    final bc = Barcode.upcA();
    return bc.toSvg(data, width: width, height: height);
  }

  /// 生成QR码的SVG字符串
  static String generateQrSvg(String data, {double width = 300, double height = 300}) {
    final bc = Barcode.qrCode();
    return bc.toSvg(data, width: width, height: height);
  }

  /// 验证条形码数据格式
  static bool isValidBarcodeData(String data, BarcodeType type) {
    try {
      switch (type) {
        case BarcodeType.code128:
          return data.isNotEmpty;
        case BarcodeType.code93:
          return data.isNotEmpty;
        case BarcodeType.ean13:
          return data.length == 13 && RegExp(r'^\d{13}$').hasMatch(data);
        case BarcodeType.upc:
          return data.length == 12 && RegExp(r'^\d{12}$').hasMatch(data);
        case BarcodeType.qr:
          return data.isNotEmpty;
        // 所有类型都已在上面的case中处理
        // 这里不会执行到
      }
    } catch (e) {
      return false;
    }
  }

  /// 获取条形码类型
  static BarcodeType getBarcodeType(String data) {
    if (data.length == 13 && RegExp(r'^\d{13}$').hasMatch(data)) {
      return BarcodeType.ean13;
    } else if (data.length == 12 && RegExp(r'^\d{12}$').hasMatch(data)) {
      return BarcodeType.upc;
    } else if (data.length == 6 && RegExp(r'^\d{6}$').hasMatch(data)) {
      return BarcodeType.code128; // 我们的6位数字ID使用Code128
    } else {
      return BarcodeType.code128; // 默认使用Code128
    }
  }
}

/// 条形码类型枚举
enum BarcodeType {
  code128,
  code93,
  ean13,
  upc,
  qr,
}
