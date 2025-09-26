import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'base_detail_screen.dart'; // Import the template

// Assuming ModernColors is defined or imported globally
class ModernColors {
  static const Color gradientStart = Color(0xFF1E3C72);
  static const Color gradientEnd = Color(0xFF2A5298);
  static const Color darkSurface = Color(0xFF1A243F);
  static const Color textLight = Color(0xFFE0E0E0);
  static const Color textMuted = Color(0xFFA0A0CC);
}

class RulesScreen extends StatelessWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  const RulesScreen({super.key, required this.tag, required this.color, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return BaseDetailScreen(
      title: "Game Rules",
      heroTag: tag,
      color: color,
      iconData: iconData,
      bodyContent: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildRuleSection("Marriage Rules", "Detailed guide on declaration, melting, and point calculation for the Marriage game.", color), _buildRuleSection("Call Break Rules", "Complete reference for bidding phases, card play, and scoring conditions.", color), _buildRuleSection("General App Policy", "Information regarding fair play, accounts, and penalties.", color)]),
      ),
    );
  }

  Widget _buildRuleSection(String title, String description, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ExpansionTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: accentColor),
        ),
        collapsedIconColor: ModernColors.textMuted,
        iconColor: accentColor,
        backgroundColor: ModernColors.darkSurface.withOpacity(0.4),
        collapsedBackgroundColor: ModernColors.darkSurface.withOpacity(0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(description, style: GoogleFonts.inter(color: ModernColors.textLight.withOpacity(0.8), fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
