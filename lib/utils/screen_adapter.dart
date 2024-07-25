

import 'package:flutter/cupertino.dart';

extension IntFix on int {
  double get px {
    return ScreenAdapter.getPx(toDouble());
  }
}

extension DoubleFix on double {
  double get px {
    return ScreenAdapter.getPx(this);
  }
}

class ScreenAdapter {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double ratio;

  static int(BuildContext context, {double baseWidth = 375}) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    ratio = screenWidth / baseWidth;
  }

  static double getPx(double size) {
    return ScreenAdapter.ratio * size;
  }
}