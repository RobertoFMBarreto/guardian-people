import 'package:flutter/services.dart';
import 'package:guardian/pages/admin/admin_home_page.dart';
import 'package:flutter/material.dart';
import 'package:guardian/pages/admin/admin_device_management_page.dart';
import 'package:guardian/pages/admin/producer_page.dart';
import 'colors.dart';

void main() {
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
      title: 'August Demo',
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
      initialRoute: '/admin',
      routes: {
        '/admin': (context) => const AdminHomePage(),
        '/admin/producer': (context) => const ProducerPage(),
        '/admin/producer/device': (context) => const AdminDeviceManagementPage(),
      },
    );
  }
}
