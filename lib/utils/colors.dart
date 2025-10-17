// lib/utils/colors.dart

import 'package:flutter/material.dart';

/// Modern color palette for consistent theming across the application
/// Provides a cohesive set of colors for gradients, surfaces, and UI elements
class ModernColors {
  // ---------------------------------------------------------------------------
  // Gradient Background Colors
  // Used for main app backgrounds and gradient overlays
  // ---------------------------------------------------------------------------

  /// Starting color for primary gradient backgrounds
  static const Color gradientStart = Color(0xFF1E3C72);

  /// Ending color for primary gradient backgrounds
  static const Color gradientEnd = Color(0xFF2A5298);

  // ---------------------------------------------------------------------------
  // Surface & Accent Colors
  // Used for cards, containers, and interactive elements
  // ---------------------------------------------------------------------------

  /// Dark surface color for cards and containers
  static const Color darkSurface = Color(0xFF1A243F);

  /// Bright cyan color for highlights and accents
  static const Color neonCyan = Color(0xFF00FFFF);

  /// Electric blue for primary buttons and interactive elements
  static const Color electricBlue = Color(0xFF0099FF);

  /// Light text color for dark backgrounds
  static const Color textLight = Color(0xFFE0E0E0);

  /// Muted text color for secondary information
  static const Color textMuted = Color(0xFFA0A0CC);

  // ---------------------------------------------------------------------------
  // Grid Accent Colors
  // Specific colors for different grid items and features
  // ---------------------------------------------------------------------------

  /// Cyan color for Marriage game related elements
  static const Color gridMarriage = Color(0xFF00E5FF);

  /// Blue color for Callbreak game related elements
  static const Color gridCallBreak = Color(0xFF3366FF);

  /// Purple color for History and statistics elements
  static const Color gridHistory = Color(0xFF9966FF);

  /// Orange color for User management elements
  static const Color gridUsers = Color(0xFFFF9900);

  /// Green color for Rules and information elements
  static const Color gridRules = Color(0xFF00FF99);

  /// Grey color for Settings and configuration elements
  static const Color gridSettings = Color(0xFFCCCCCC);
}
