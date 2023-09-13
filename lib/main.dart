import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:guardian/routes/mobile_routes.dart';
import 'package:guardian/routes/web_routes.dart';
// import 'package:get/get.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/db/drift/database.dart';
// import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/helpers/navigator_key_helper.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:flutter/material.dart';
import 'package:guardian/themes/dark_theme.dart';
import 'package:guardian/themes/light_theme.dart';
// import 'package:guardian/models/providers/caching/stub.dart'
//     if (dart.library.io) 'package:guardian/models/providers/caching/caching_provider.dart'
//     if (dart.library.html) 'package:guardian/models/providers/caching/stub.dart';

late bool hasConnection;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (!kIsWeb) {
  //   await MapCaching().initMapCaching();
  // }
  Get.put(GuardianDb());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription subscription;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _setup();
    super.initState();
  }

  Future<StreamSubscription?> _setup() async {
    if (!kIsWeb) {
      return _setupInitialConnectionState().then(
        (_) => subscription = wifiConnectionChecker(
          onHasConnection: () async {
            setState(() {
              hasConnection = true;
            });
            await setShownNoWifiDialog(false);
          },
          onNotHasConnection: () async {
            setState(() {
              hasConnection = false;
            });

            await showNoWifiDialog(navigatorKey.currentContext!);
          },
        ),
      );
    } else {
      hasConnection = true;
    }
    return null;
  }

  Future<void> _setupInitialConnectionState() async {
    if (kIsWeb) hasConnection = await checkInternetConnection(context);
  }

  @override
  Widget build(BuildContext context) {
    // Change status bar color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
            Theme.of(context).brightness == Brightness.light ? gdGradientEnd : gdDarkGradientEnd,
      ),
    );
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
    print('Is web: $kIsWeb');
    return MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Guardian',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: kIsWeb ? webRoutes : mobileRoutes);
  }
}
