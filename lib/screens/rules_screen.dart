import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color onSurface = Color(0xFF1E293B);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color primaryContainer = Color(0xFFEEF2FF);
}

class RulesScreen extends StatelessWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  const RulesScreen({super.key, required this.tag, required this.color, required this.iconData});

  Widget _buildFloatingShape(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildAppBarDecoration(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ModernColors.primary.withOpacity(0.05), ModernColors.primary.withOpacity(0.02)]),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12.0), // Add rounded corners to the background
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -10, left: 20, child: _buildFloatingShape(25, ModernColors.primary.withOpacity(0.08))),
          Positioned(bottom: 10, right: 40, child: _buildFloatingShape(40, ModernColors.primary.withOpacity(0.06))),
          Positioned(top: 30, left: 100, child: _buildFloatingShape(30, ModernColors.primary.withOpacity(0.1))),
          Positioned(top: 5, right: 80, child: _buildFloatingShape(15, ModernColors.primary.withOpacity(0.12))),
          Positioned(bottom: -5, left: 120, child: _buildFloatingShape(20, ModernColors.primary.withOpacity(0.08))),
          Positioned(bottom: -15, right: 5, child: _buildFloatingShape(35, ModernColors.primary.withOpacity(0.06))),
          Positioned(top: -25, right: 15, child: _buildFloatingShape(50, ModernColors.primary.withOpacity(0.08))),
          Positioned(top: 55, left: 5, child: _buildFloatingShape(10, ModernColors.primary.withOpacity(0.1))),
          Positioned(top: -5, left: 180, child: _buildFloatingShape(22, ModernColors.primary.withOpacity(0.07))),
          Positioned(bottom: 25, left: 50, child: _buildFloatingShape(18, ModernColors.primary.withOpacity(0.09))),
          Positioned(top: 15, right: 20, child: _buildFloatingShape(14, ModernColors.primary.withOpacity(0.12))),
          Positioned(top: 5, left: 50, child: _buildFloatingShape(16, ModernColors.primary.withOpacity(0.08))),
          Positioned(top: 40, right: 100, child: _buildFloatingShape(12, ModernColors.primary.withOpacity(0.1))),
          Positioned(bottom: 0, left: 30, child: _buildFloatingShape(22, ModernColors.primary.withOpacity(0.06))),
          Positioned(bottom: 40, right: 10, child: _buildFloatingShape(18, ModernColors.primary.withOpacity(0.12))),
        ],
      ),
    );
  }

  Widget _buildRuleSection(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: ModernColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
        border: Border.all(color: ModernColors.outline.withOpacity(0.5), width: 1),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [ModernColors.primary.withOpacity(0.15), ModernColors.primary.withOpacity(0.08)]),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: ModernColors.primary),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: ModernColors.onSurface),
        ),
        trailing: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: ModernColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.expand_more_rounded, size: 16, color: ModernColors.primary),
        ),
        collapsedIconColor: ModernColors.onSurfaceVariant,
        iconColor: ModernColors.primary,
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: <Widget>[
          Divider(color: ModernColors.outline.withOpacity(0.5), height: 1, thickness: 1, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              description,
              style: GoogleFonts.inter(color: ModernColors.onSurfaceVariant, fontSize: 14, height: 1.6, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0), // Set the exact height
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(15.0), // Main rounded corners for the app bar
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 7, offset: const Offset(0, 2))],
          ),
          child: AppBar(
            toolbarHeight: 60,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.white,
            elevation: 0, // Remove AppBar's default elevation
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20.0), // Rounded bottom for AppBar
              ),
            ),
            title: Text(
              "Marriage",
              style: GoogleFonts.poppins(letterSpacing: 1.0, fontSize: 17, fontWeight: FontWeight.w800, color: ModernColors.onSurface),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: ModernColors.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: const [],
            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12.0), // Clip the flexible space to rounded corners
              ),
              child: Column(
                children: [
                  Expanded(child: _buildAppBarDecoration(context)),
                  // Divider at the bottom
                  Container(
                    height: 1.5,
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [ModernColors.outline.withOpacity(0.8), ModernColors.outline.withOpacity(0.4), ModernColors.outline.withOpacity(0.8)])),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0, left: 24.0, right: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [ModernColors.primary.withOpacity(0.05), ModernColors.primary.withOpacity(0.02)]),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ModernColors.outline, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Master the Games",
                            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: ModernColors.onSurface, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Learn all the rules and strategies to become a better player. Understand scoring, bidding, and advanced techniques.",
                            style: GoogleFonts.inter(fontSize: 14, color: ModernColors.onSurfaceVariant, fontWeight: FontWeight.w400, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildRuleSection("Marriage Rules", "Detailed guide on declaration, melting, and point calculation for the Marriage game. Learn about trump cards, scoring systems, and winning strategies.", Icons.celebration_rounded),
                    _buildRuleSection("Call Break Rules", "Complete reference for bidding phases, card play, and scoring conditions. Understand how to make successful bids and maximize your points.", Icons.groups_rounded),
                    _buildRuleSection("General App Policy", "Information regarding fair play, accounts, and penalties. Learn about community guidelines, account management, and dispute resolution.", Icons.security_rounded),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
