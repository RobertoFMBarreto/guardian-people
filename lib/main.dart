import 'dart:async';
import 'package:dart_mq/dart_mq.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:guardian/firebase_options.dart';
import 'package:guardian/models/providers/api/requests/alerts_requests.dart';
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

// only import the libraries of the current platform
import 'package:guardian/models/providers/caching/caching_stub.dart'
    if (dart.library.io) 'package:guardian/models/providers/caching/caching_provider_mobile.dart'
    if (dart.library.js) 'package:guardian/models/providers/caching/caching_provider_web.dart'
    as caching_helper;

// global variable that stores the device connection state
late bool hasConnection;
// global variable that stores the snackbar state
bool isSnackbarActive = false;
// global variable that is true if te screen is big enough for tablet mode
bool isBigScreen = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MQClient.initialize();
  FirebaseMessaging.onBackgroundMessage(FCMMessagingProvider.firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await caching_helper.MapCaching().initMapCaching();
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
  bool _firstRun = true;

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
      await _getAlertableSensors();
      hasConnection = true;
    }
    return null;
  }

  /// Method that allows to get the initial connection state
  Future<void> _setupInitialConnectionState() async {
    if (kIsWeb) hasConnection = await checkInternetConnection(context);
  }

  /// Method that allows to get all alertable sensors
  Future<void> _getAlertableSensors() async {
    await AlertRequests.getAlertableSensorsFromApi(
      context: context,
      onDataGotten: (data) async {},
      onFailed: (statusCode) {
        if (!hasConnection && !isSnackbarActive) {
          showNoConnectionSnackBar();
        } else {
          if (statusCode == 507 || statusCode == 404) {
            if (_firstRun == true) {
              showNoConnectionSnackBar();
            }
            _firstRun = false;
          } else if (!isSnackbarActive) {
            AppLocalizations localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(localizations.server_error)));
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (width >= 1000 || height >= 1000) {
      isBigScreen = true;
    } else {
      isBigScreen = false;
    }

    /// Change status bar color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
            Theme.of(context).brightness == Brightness.light ? gdGradientEnd : gdDarkGradientEnd,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    /// Set orientation only to portait
    /// Or landscape if the screen is big enough
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        if (!kIsWeb && !isBigScreen) DeviceOrientation.portraitUp,
        if (isBigScreen) ...[DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
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
      routes: kIsWeb || isBigScreen ? webRoutes : mobileRoutes,
    );
  }
}
