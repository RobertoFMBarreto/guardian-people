import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/helpers/navigator_key_helper.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:flutter/material.dart';
import 'package:guardian/routes.dart';
import 'package:guardian/themes/dark_theme.dart';
import 'package:guardian/themes/light_theme.dart';

late bool hasConnection;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMapTileCaching.initialise();
  await FMTC.instance('guardian').manage.createAsync();
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

  Future<StreamSubscription> _setup() async {
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
  }

  Future<void> _setupInitialConnectionState() async {
    hasConnection = await checkInternetConnection(context);
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
      routes: routes,
    );
  }
}
