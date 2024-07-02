
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marker/views/device/device.dart';
import 'package:marker/views/home/home.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePath.home:
        return pageRoute(Home(), settings: settings);
      case RoutePath.device:
        return pageRoute(Device(), settings: settings);
      default:
        return pageRoute(Scaffold(
                          body: SafeArea(
                            child: Center(
                              child: Text("No route defined for ${settings.name}")
                            )
                          )
                        ));
    }
  }

  static MaterialPageRoute pageRoute(Widget page, {
    RouteSettings? settings,
    bool? fullscreenDialog,
    bool? maintainState,
    bool? allowSnapshotting,
  }) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
      fullscreenDialog: fullscreenDialog ?? false,
      maintainState: maintainState ?? true,
      allowSnapshotting: allowSnapshotting ?? true,
    );
  }
}

class RoutePath {
  static const String home = "/";

  static const String device = "/device";
}