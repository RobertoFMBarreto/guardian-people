import 'package:guardian/pages/admin/admin_home_page.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'August Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: atTextColor),
          bodyMedium: TextStyle(color: atTextColor),
          bodySmall: TextStyle(color: atTextColor),
          headlineLarge: TextStyle(color: atTextColor),
          headlineMedium: TextStyle(color: atTextColor, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: atTextColor),
          labelLarge: TextStyle(color: atTextColor),
          labelMedium: TextStyle(color: atTextColor),
          labelSmall: TextStyle(color: atTextColor),
        ),
        scaffoldBackgroundColor: atBackgroundColor,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: atSecondaryColor,
          selectionHandleColor: atSecondaryColor,
          selectionColor: atSecondaryColor,
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: atPrimaryColor,
          onPrimary: atOnPrimaryColor,
          secondary: atSecondaryColor,
          onSecondary: atOnSecondaryColor,
          error: atErrorColor,
          onError: atOnErrorColor,
          background: atBackgroundColor,
          onBackground: atOnBackgroundColor,
          surface: atBackgroundColor,
          onSurface: atOnBackgroundColor,
        ),
        bottomSheetTheme: const BottomSheetThemeData(backgroundColor: atBackgroundColor),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AdminHomePage(),
      },
    );
  }
}
