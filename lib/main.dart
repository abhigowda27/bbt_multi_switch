import 'dart:async';

import 'package:bbtml_new/api_providers/theme_provider.dart';
import 'package:bbtml_new/common/globals.dart' as globals;
import 'package:bbtml_new/controllers/shared_preference.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/wifi.dart';
import 'package:bbtml_new/screens/splash_screen.dart';
import 'package:bbtml_new/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'common/get_device_id.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SharedPreferenceServices().init();
    await NetworkService().init();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    globals.deviceId = await DeviceUtils.getDeviceId();
    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint("Error $error $stack");
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SafeArea(
      top: false,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'BBT Switch',
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: themeProvider.themeMode,
        home: const SplashScreen(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
