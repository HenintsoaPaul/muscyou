import 'package:flutter/material.dart';

var muscyouTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF6C5CE7), // Vibrant purple base
    brightness: Brightness.light,
    primary: Color(0xFF6C5CE7),
    secondary: Color(0xFFFF6B9D),
    tertiary: Color(0xFFFFD93D),
    surface: Color(0xFFF8F9FA),
    background: Color(0xFFF1F2F6),
  ),
  fontFamily: 'GoogleSans',
  textTheme: TextTheme(
    headlineMedium: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
    bodyLarge: TextStyle(letterSpacing: 0.15),
  ),
);
