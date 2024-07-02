
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Utils {
  Utils._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  // App Root Context
  static BuildContext get context => navigatorKey.currentContext!;

  static NavigatorState get navigator => navigatorKey.currentState!;

  static Future push(
      BuildContext context,
      Widget page, {
        bool? fullscreenDialog,
        RouteSettings? settings,
        bool maintainState = true,
      }) {
    return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => page,
          fullscreenDialog: fullscreenDialog ?? false,
          settings: settings,
          maintainState: maintainState,
        ));
  }

  // Redirect to named route
  static Future pushWithNamed(
      BuildContext context,
      String name, {
        Object? arguments,
      }) {
    return Navigator.pushNamed(context, name, arguments: arguments);
  }

  // Custom route
  static Future pushWithPageRoute(BuildContext context, Route route) {
    return Navigator.push(context, route);
  }

  static Future pushNamedAndRemoveUntil(
      BuildContext context,
      String name, {
        Object? arguments,
      }) {
    return Navigator.pushNamedAndRemoveUntil(context, name, (route) => false, arguments: arguments);
  }

  // Clean stack and sta on current page
  static Future pushAndRemoveUntil(
      BuildContext context,
      Widget page, {
        bool? fullscreenDialog,
        RouteSettings? settings,
        bool maintainState = true,
      }) {
    return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => page,
            fullscreenDialog: fullscreenDialog??false,
            settings: settings,
            maintainState: maintainState
        ),
            (route) => false);
  }

  // Replace current Route
  static Future pushReplacement(BuildContext context, Route route, {Object? result}) {
    return Navigator.pushReplacement(context, route, result: result);
  }

  // Replace curr Route
  static Future pushReplacementNamed(
      BuildContext context,
      String name, {
        Object? result,
        Object? arguments,
      }) {
    return Navigator.pushReplacementNamed(context, name, arguments: arguments, result: result);
  }

  // Close current Page
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}