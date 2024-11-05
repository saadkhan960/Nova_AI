import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nova_ai/Theme/text%20theme/text_theme.dart';
import 'package:nova_ai/Utils/Colors/app_colors.dart';

class CustomThemeData {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.backgroundLight,
    useMaterial3: true,
    primaryColor: AppColors.primary,
    primaryColorLight: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    fontFamily: 'Poppins',
    textTheme: NTextTheme.textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor:
            AppColors.backgroundLight, // Status bar background color
        statusBarIconBrightness:
            Brightness.dark, // Dark icons for light background
        statusBarBrightness: Brightness.light, // Brightness of the status bar
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.backgroundDark,
    useMaterial3: true,
    primaryColor: AppColors.primary,
    primaryColorLight: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    fontFamily: 'Poppins',
    textTheme: NTextTheme.textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundDark, // Status bar background color
        statusBarIconBrightness:
            Brightness.light, // Light icons for dark background
        statusBarBrightness: Brightness.dark, // Brightness of the status bar
      ),
    ),
  );
}
