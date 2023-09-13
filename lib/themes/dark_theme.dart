import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: gdDarkTextColor),
    bodyMedium: TextStyle(color: gdSecondaryTextColor),
    bodySmall: TextStyle(color: gdDarkTextColor),
    headlineLarge: TextStyle(color: gdDarkTextColor),
    headlineMedium: TextStyle(color: gdDarkTextColor, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(color: gdDarkTextColor),
    labelLarge: TextStyle(color: gdDarkTextColor),
    labelMedium: TextStyle(color: gdDarkTextColor),
    labelSmall: TextStyle(color: gdDarkTextColor),
    displayLarge: TextStyle(color: gdDarkTextColor),
    displayMedium: TextStyle(color: gdDarkTextColor),
    displaySmall: TextStyle(color: gdDarkTextColor),
    titleLarge: TextStyle(color: gdDarkTextColor),
    titleMedium: TextStyle(color: gdDarkTextColor),
    titleSmall: TextStyle(color: gdDarkTextColor),
  ),
  scaffoldBackgroundColor: gdDarkBackgroundColor,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: gdDarkSecondaryColor,
    selectionHandleColor: gdDarkSecondaryColor,
    selectionColor: gdSecondaryAltColor,
  ),
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: gdPrimaryColor,
    onPrimary: gdOnPrimaryColor,
    secondary: gdDarkSecondaryColor,
    onSecondary: gdOnSecondaryColor,
    error: gdErrorColor,
    onError: gdOnErrorColor,
    background: gdDarkBackgroundColor,
    onBackground: gdDarktOnBackgroundColor,
    surface: gdDarkBackgroundColor,
    onSurface: gdDarktOnBackgroundColor,
  ),
  elevatedButtonTheme: const ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(gdDarkSecondaryColor),
    ),
  ),
  switchTheme: const SwitchThemeData(
    thumbColor: MaterialStatePropertyAll(Colors.white),
    trackColor: MaterialStatePropertyAll(gdToggleGreyArea),
    trackOutlineColor: MaterialStatePropertyAll(Colors.transparent),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.transparent,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: gdInputTextBorderColors),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    focusColor: gdDarkTextColor,
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
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: gdDarkBackgroundColor,
  ),
  cardTheme: CardTheme(
    elevation: 3,
    color: gdDarkCardBackgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(
        width: 0.5,
        color: Colors.grey.shade900,
      ),
    ),
  ),
  dropdownMenuTheme: const DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: MaterialStatePropertyAll(gdDarkToggleGreyArea),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: gdInputTextBorderColors),
      ),
    ),
  ),
);
