
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
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

      /// START FROM SPLASH
      initialRoute: RoutesName.splashScreen,
      onGenerateRoute: Routes.generateRoute,

      /// 🆕 Upgrader integration
      builder: (context, child) {
        return UpgradeAlert(
          upgrader: Upgrader(
            debugLogging: true,               // logs to console (optional)
            debugDisplayAlways: false,        // show only when update available
            durationUntilAlertAgain: const Duration(days: 1),
            countryCode: 'in',                // set to your country code
            // minAppVersion: '2.0.0',        // optional – enforce minimum version
          ),
          dialogStyle: UpgradeDialogStyle.material,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

