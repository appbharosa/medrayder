
import 'package:flutter/material.dart';
import 'config/routes/routes.dart';
import 'config/routes/routes_name.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Rayder Partner',

      ///  START FROM SPLASH
      initialRoute: RoutesName.splashScreen,

      onGenerateRoute: Routes.generateRoute,
    );
  }
}

