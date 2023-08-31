import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:guardian/models/custom_alert_dialogs.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/navigator_key.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/models/providers/system_provider.dart';

import 'package:guardian/pages/admin/admin_home_page.dart';
import 'package:flutter/material.dart';
import 'package:guardian/pages/admin/admin_device_management_page.dart';
import 'package:guardian/pages/admin/admin_producer_page.dart';
import 'package:guardian/pages/login_page.dart';
import 'package:guardian/pages/producer/add_alert_page.dart';
import 'package:guardian/pages/producer/alerts_management_page.dart';
import 'package:guardian/pages/producer/alerts_page.dart';
import 'package:guardian/pages/producer/device_page.dart';
import 'package:guardian/pages/producer/device_settings_page.dart';
import 'package:guardian/pages/producer/fences_page.dart';
import 'package:guardian/pages/producer/geofencing_page.dart';
import 'package:guardian/pages/producer/manage_fence_page.dart';
import 'package:guardian/pages/producer/producer_devices_page.dart';
import 'package:guardian/pages/producer/producer_home.dart';
import 'package:guardian/pages/profile_page.dart';
import 'package:guardian/pages/welcome_page.dart';
import 'colors.dart';

final globalNavigatorKey = GlobalKey<NavigatorState>();
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

  bool hasConnection = true;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    setup().then(
      (_) => subscription = wifiConnectionChecker(
        context: context,
        onHasConnection: () async {
          print("Has Connection");
          setState(() {
            hasConnection = true;
          });

          await setShownNoWifiDialog(false);
        },
        onNotHasConnection: () async {
          print("No Connection");
          setState(() {
            hasConnection = false;
          });

          await showNoWifiDialog(context);
        },
      ),
    );
    super.initState();
  }

  Future<void> setup() async {
    hasConnection = await checkInternetConnection(context);
  }

  @override
  Widget build(BuildContext context) {
    // Change status bar color
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(147, 215, 166, 1),
      ),
    );
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Guardian',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: gdTextColor),
          bodyMedium: TextStyle(color: gdSecondaryTextColor),
          bodySmall: TextStyle(color: gdTextColor),
          headlineLarge: TextStyle(color: gdTextColor),
          headlineMedium: TextStyle(color: gdTextColor, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: gdTextColor),
          labelLarge: TextStyle(color: gdTextColor),
          labelMedium: TextStyle(color: gdTextColor),
          labelSmall: TextStyle(color: gdTextColor),
          displayLarge: TextStyle(color: gdTextColor),
          displayMedium: TextStyle(color: gdTextColor),
          displaySmall: TextStyle(color: gdTextColor),
          titleLarge: TextStyle(color: gdTextColor),
          titleMedium: TextStyle(color: gdTextColor),
          titleSmall: TextStyle(color: gdTextColor),
        ),
        scaffoldBackgroundColor: gdBackgroundColor,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: gdSecondaryColor,
          selectionHandleColor: gdSecondaryColor,
          selectionColor: gdSecondaryAltColor,
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: gdPrimaryColor,
          onPrimary: gdOnPrimaryColor,
          secondary: gdSecondaryColor,
          onSecondary: gdOnSecondaryColor,
          error: gdErrorColor,
          onError: gdOnErrorColor,
          background: gdBackgroundColor,
          onBackground: gdtOnBackgroundColor,
          surface: gdBackgroundColor,
          onSurface: gdtOnBackgroundColor,
        ),
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(gdSecondaryColor),
          ),
        ),
        switchTheme: const SwitchThemeData(
          thumbColor: MaterialStatePropertyAll(Colors.white),
          trackColor: MaterialStatePropertyAll(gdToggleGreyArea),
          trackOutlineColor: MaterialStatePropertyAll(Colors.transparent),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          focusColor: gdTextColor,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: gdErrorColor),
          ),
          floatingLabelStyle: const TextStyle(color: gdSecondaryTextColor),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 15,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(backgroundColor: gdBackgroundColor),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
        '/admin': (context) => AdminHomePage(hasConnection: hasConnection),
        '/admin/producer': (context) {
          if (ModalRoute.of(context)!.settings.arguments.runtimeType == String) {
            return AdminProducerPage(
              hasConnection: hasConnection,
              producerId: ModalRoute.of(context)!.settings.arguments as String,
            );
          } else {
            throw ErrorDescription('Device not provided');
          }
        },
        '/admin/producer/device': (context) {
          if (ModalRoute.of(context)!.settings.arguments != null) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return AdminDeviceManagementPage(
              device: args['device'] as Device,
              producerId: args['producerId'] as String,
              hasConnection: hasConnection,
            );
          } else {
            throw ErrorDescription('Device not provided');
          }
        },
        '/producer': (context) => ProducerHome(
              hasConnection: hasConnection,
            ),
        '/producer/fences': (context) {
          if (ModalRoute.of(context)!.settings.arguments.runtimeType == bool) {
            return FencesPage(
              isSelect: ModalRoute.of(context)!.settings.arguments as bool,
              hasConnection: hasConnection,
            );
          } else {
            return FencesPage(
              hasConnection: hasConnection,
            );
          }
        },
        '/producer/fence/manage': (context) {
          return ManageFencePage(
            fence: ModalRoute.of(context)!.settings.arguments as Fence,
            hasConnection: hasConnection,
          );
        },
        '/producer/geofencing': (context) {
          if (ModalRoute.of(context)!.settings.arguments.runtimeType == Fence) {
            return GeofencingPage(
              fence: ModalRoute.of(context)!.settings.arguments as Fence,
            );
          } else {
            return const GeofencingPage();
          }
        },
        '/producer/devices': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args != null) {
            final data = (args as Map<String, dynamic>);

            return ProducerDevicesPage(
              isSelect: data['isSelect'] as bool,
              fenceId: data.containsKey('fenceId') ? data['fenceId'] as String : null,
              alertId: data.containsKey('alertId') ? data['alertId'] as String : null,
              notToShowDevices: data.containsKey('notToShowDevices')
                  ? data['notToShowDevices'] as List<String>
                  : null,
              hasConnection: hasConnection,
            );
          } else {
            return ProducerDevicesPage(hasConnection: hasConnection);
          }
        },
        '/producer/device': (context) {
          if (ModalRoute.of(context)!.settings.arguments != null) {
            final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return DevicePage(
              device: data['device'] as Device,
              hasConnection: hasConnection,
            );
          } else {
            throw ErrorDescription('Device not provided');
          }
        },
        '/producer/device/settings': (context) {
          if (ModalRoute.of(context)!.settings.arguments.runtimeType == Device) {
            return DeviceSettingsPage(
              device: ModalRoute.of(context)!.settings.arguments as Device,
            );
          } else {
            throw ErrorDescription('Device not provided');
          }
        },
        '/producer/alerts': (context) => AlertsPage(hasConnection: hasConnection),
        '/producer/alerts/add': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args != null) {
            final data = args as Map<String, dynamic>;
            return AddAlertPage(
              isEdit: data['isEdit'] as bool,
              alert: data['alert'] as UserAlert,
            );
          } else {
            return const AddAlertPage();
          }
        },
        '/producer/alert/management': (context) {
          if (ModalRoute.of(context)!.settings.arguments.runtimeType == bool) {
            return AlertsManagementPage(
              isSelect: ModalRoute.of(context)!.settings.arguments as bool,
              hasConnection: hasConnection,
            );
          } else {
            throw ErrorDescription('isSelect not provided');
          }
        },
      },
    );
  }
}
