import 'dart:async';
import 'package:dart_mq/dart_mq.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:guardian/firebase_options.dart';
import 'package:guardian/models/providers/messaging_provider.dart';
import 'package:guardian/routes/mobile_routes.dart';
import 'package:guardian/routes/web_routes.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/helpers/navigator_key_helper.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:flutter/material.dart';
import 'package:guardian/themes/dark_theme.dart';
import 'package:guardian/themes/light_theme.dart';
import 'package:guardian/models/providers/caching/caching_provider.dart';

late bool hasConnection;
bool isSnackbarActive = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MQClient.initialize();
  FirebaseMessaging.onBackgroundMessage(FCMMessagingProvider.firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await MapCaching().initMapCaching();
  }

  /// Put the reference to the guardian databe in the get package
  Get.put(GuardianDb());

  /// set the show no server connection variable to false
  setShownNoServerConnection(false);

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

  /// Method that realizes all initial setup
  ///
  /// 1. check if there is connection
  /// 2. setup the connection checker
  Future<StreamSubscription?> _setup() async {
    if (!kIsWeb) {
      return _setupInitialConnectionState().then((_) async {
        subscription = wifiConnectionChecker(
          onHasConnection: () async {
            setState(() {
              hasConnection = true;
            });
            await setShownNoWifiDialog(false);
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setState(() {
              isSnackbarActive = false;
            });
          },
          onNotHasConnection: () async {
            setState(() {
              hasConnection = false;
            });
            await showNoWifiDialog(navigatorKey.currentContext!);
            if (!isSnackbarActive) {
              showNoConnectionSnackBar();
            }
          },
        );
        await FCMMessagingProvider.initInfo(navigatorKey);
        return subscription;
      });
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
    /// Change status bar color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
            Theme.of(context).brightness == Brightness.light ? gdGradientEnd : gdDarkGradientEnd,
      ),
    );

    /// Set orientation only to portait
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
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
      routes: kIsWeb ? webRoutes : mobileRoutes,
    );
  }
}
