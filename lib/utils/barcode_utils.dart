import 'package:barcode/barcode.dart';

String genBarcode(String data) {
  final bc = Barcode.code128();
  final svg = bc.toSvg(data, width: 300, height: 100);
  return svg;
}