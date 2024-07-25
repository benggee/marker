import 'package:flutter/material.dart';
import 'package:marker/navigator/tab_navigator.dart';
import 'package:marker/route/utils.dart';
import 'package:marker/route/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Marker());
}

class Marker extends StatelessWidget {
  const Marker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TabNavigator(),
      // navigatorKey: Utils.navigatorKey,
      // onGenerateRoute: Routes.generateRoute,
      // initialRoute: RoutePath.home,
    );
  }
}