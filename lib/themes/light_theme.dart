import 'package:flutter/material.dart';

/// Light theme configuration for the application
/// Defines the color scheme and styling for light mode interface
final ThemeData lightTheme = ThemeData(
  /// Overall brightness setting for the theme
  brightness: Brightness.light,

  /// Primary brand color used for key components and accents
  primaryColor: Colors.blueAccent,

  /// Background color for scaffold and main app surfaces
  scaffoldBackgroundColor: Colors.white,

  /// Styling for application app bars and headers
  appBarTheme: const AppBarTheme(color: Colors.blueAccent),
);
