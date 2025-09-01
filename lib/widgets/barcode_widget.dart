import 'package:flutter/material.dart';
import 'package:barcode/barcode.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BarcodeDisplayWidget extends StatelessWidget {
  final String barcodeId;
  final double width;
  final double height;

  const BarcodeDisplayWidget({
    super.key,
    required this.barcodeId,
    this.width = 300,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 条形码显示
          Expanded(
            child: Center(
              child: SvgPicture.string(
                _generateBarcodeSvg(),
                width: width * 0.8, // 条形码宽度为容器的80%
                height: height * 0.6, // 条形码高度为容器的60%
                fit: BoxFit.contain,
              ),
            ),
          ),
          // ID显示
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              barcodeId.padLeft(6, '0'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _generateBarcodeSvg() {
    final Barcode code93 = Barcode.code93();
    return code93.toSvg(
      barcodeId,
      width: (width * 0.8).toDouble(),
      height: (height * 0.6).toDouble(),
      drawText: false, // 不显示文本，我们单独显示ID
    );
  }
}
