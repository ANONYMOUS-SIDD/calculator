import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'base_detail_screen.dart'; // Import the template

// The following classes/constants would typically be in a single 'theme' or 'constants' file.
// Redefining them here for completeness but ensure your project structure is clean.
class ModernColors {
  static const Color gradientStart = Color(0xFF1E3C72);
  static const Color gradientEnd = Color(0xFF2A5298);
  static const Color darkSurface = Color(0xFF1A243F);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color textMuted = Color(0xFFA0A0CC);
}

class MarriageScreen extends StatelessWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  const MarriageScreen({super.key, required this.tag, required this.color, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return BaseDetailScreen(
      title: "Marriage", // Specific title
      heroTag: tag,
      color: color,
      iconData: iconData,
      // 👈 This is the UNIQUE content area for the Marriage page
      bodyContent: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Game Status",
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: ModernColors.neonCyan),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ModernColors.darkSurface.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
              child: Text("Implement your live game data, scoreboards, and play buttons here. This is the custom functionality for the Marriage game.", style: GoogleFonts.inter(fontSize: 16, color: ModernColors.textMuted)),
            ),
            // Add more widgets like buttons, lists, or forms specific to Marriage game...
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Marriage Game Logic: Start new game, etc.
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text("Start New Marriage Game"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
