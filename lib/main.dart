import 'package:flutter/services.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/pages/admin/admin_home_page.dart';
import 'package:flutter/material.dart';
import 'package:guardian/pages/admin/admin_device_management_page.dart';
import 'package:guardian/pages/admin/admin_producer_page.dart';
import 'package:guardian/pages/login_page.dart';
import 'package:guardian/pages/producer/fences_page.dart';
import 'package:guardian/pages/producer/geofencing_page.dart';
import 'package:guardian/pages/producer/manage_fence_page.dart';
import 'package:guardian/pages/producer/producer_devices_page.dart';
import 'package:guardian/pages/producer/producer_home.dart';
import 'package:guardian/pages/profile_page.dart';
import 'package:guardian/pages/welcome_page.dart';
import 'colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Change status bar color
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(147, 215, 166, 1),
      ),
    );
    return MaterialApp(
      title: 'Guardian',
      debugShowCheckedModeBanner: false,
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
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
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
        '/admin': (context) => const AdminHomePage(),
        '/admin/producer': (context) => const AdminProducerPage(),
        '/admin/producer/device': (context) => const AdminDeviceManagementPage(),
        '/producer': (context) => const ProducerHome(),
        '/producer/fences': (context) => const FencesPage(),
        '/producer/fence/manage': (context) {
          return ManageFencePage(
            fence: ModalRoute.of(context)!.settings.arguments as Fence,
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
          if (ModalRoute.of(context)!.settings.arguments.runtimeType == bool) {
            return const ProducerDevicesPage(
              isSelect: true,
            );
          } else {
            return const ProducerDevicesPage();
          }
        },
        '/producer/device': (context) {
          if (ModalRoute.of(context)!.settings.arguments.runtimeType == bool) {
            return const ProducerDevicesPage(
              isSelect: true,
            );
          } else {
            return const ProducerDevicesPage();
          }
        },
      },
    );
  }
}
