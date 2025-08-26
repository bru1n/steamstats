import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Color(0xFF00709B),
    secondary: Color(0xFF2D8EB3),
    surface: Colors.white,
    surfaceContainer: Colors.black12,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.black,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF00709B).withValues(alpha: 0.7),
    secondary: Color(0xFF2D8EB3).withValues(alpha: 0.7),
    surface: Color(0xFF1E1E1E),
    surfaceContainer: Colors.white12,
    onPrimary: Colors.black,
    onSecondary: Colors.white,
    onSurface: Colors.white,
  ),
);
