import 'package:flutter/material.dart';

/// Dark theme configuration for the application
/// Defines the color scheme and styling for dark mode interface
final ThemeData darkTheme = ThemeData(
  /// Overall brightness setting for dark theme
  brightness: Brightness.dark,

  /// Primary brand color used for key components in dark mode
  primaryColor: Colors.deepPurple,

  /// Background color for scaffold and main app surfaces in dark mode
  scaffoldBackgroundColor: Colors.black,

  /// Styling for application app bars and headers in dark mode
  appBarTheme: const AppBarTheme(color: Colors.deepPurple),
);
