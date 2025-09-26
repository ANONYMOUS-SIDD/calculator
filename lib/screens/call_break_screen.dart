import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'base_detail_screen.dart'; // Import the template

// Assuming ModernColors is defined or imported globally
class ModernColors {
  static const Color gradientStart = Color(0xFF1E3C72);
  static const Color gradientEnd = Color(0xFF2A5298);
  static const Color darkSurface = Color(0xFF1A243F);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color electricBlue = Color(0xFF0099FF);
  static const Color textMuted = Color(0xFFA0A0CC);
}

class CallBreakScreen extends StatelessWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  const CallBreakScreen({super.key, required this.tag, required this.color, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return BaseDetailScreen(
      title: "Call Break",
      heroTag: tag,
      color: color,
      iconData: iconData,
      bodyContent: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bidding & Scoring",
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: ModernColors.electricBlue),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ModernColors.darkSurface.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
              child: Text("This area will feature the live bidding tracker, current scores, and round-specific statistics for the Call Break game.", style: GoogleFonts.inter(fontSize: 16, color: ModernColors.textMuted)),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Call Break Game Logic: Start new bidding, etc.
                },
                icon: const Icon(Icons.alarm),
                label: const Text("Place Your Bid"),
                style: ElevatedButton.styleFrom(backgroundColor: ModernColors.electricBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
