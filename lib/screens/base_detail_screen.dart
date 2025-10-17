import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern color palette for consistent UI theming across the app
class ModernColors {
  static const Color gradientStart = Color(0xFF1E3C72);
  static const Color gradientEnd = Color(0xFF2A5298);
  static const Color darkSurface = Color(0xFF1A243F);
  static const Color electricBlue = Color(0xFF0099FF);
  static const Color textLight = Color(0xFFE0E0E0);
}

/// Base detail screen providing consistent layout and styling for detail pages
///
/// This widget serves as a template for detail screens with gradient background,
/// custom app bar with back navigation, and hero animations for smooth transitions.
class BaseDetailScreen extends StatelessWidget {
  final String title;
  final String heroTag;
  final Color color;
  final IconData iconData;
  final Widget bodyContent;

  const BaseDetailScreen({super.key, required this.title, required this.heroTag, required this.color, required this.iconData, required this.bodyContent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkSurface,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ModernColors.gradientStart, ModernColors.gradientEnd]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context),
              Expanded(child: bodyContent),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds custom app bar with back button, title, and hero animated icon
  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: ModernColors.textLight),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),

          // Screen title
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: ModernColors.textLight),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Hero animated icon
          Hero(
            tag: heroTag,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, Color.lerp(color, ModernColors.electricBlue, 0.4)!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 24, color: ModernColors.textLight),
            ),
          ),
        ],
      ),
    );
  }
}
