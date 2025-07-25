import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2853AF);
  static const Color secondary = Color(0xFFE8EFFF);
  static const Color bgcolor = Color(0xFFF5F6FA);
  static const Color blackText = Colors.black;
  static const Color greyText = Color(0xFF6A6A6A);
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.bgcolor,
  colorScheme: ColorScheme.light(                       
    primary: AppColors.primary,                     
    secondary: AppColors.secondary,           
  ),
);
