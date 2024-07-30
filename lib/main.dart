import 'package:flutter/material.dart';
import 'package:marker/model/device_model.dart';
import 'package:marker/navigator/tab_navigator.dart';
import 'package:marker/utils/route.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
// import '../views/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DeviceModel())
        ],
        child: const Marker(),
      )
  );
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