import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';

ThemeData lightTheme = ThemeData(
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
);
