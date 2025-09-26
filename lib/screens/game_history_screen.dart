import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'base_detail_screen.dart'; // Import the template

// Assuming ModernColors is defined or imported globally
class ModernColors {
  static const Color gradientStart = Color(0xFF1E3C72);
  static const Color gradientEnd = Color(0xFF2A5298);
  static const Color darkSurface = Color(0xFF1A243F);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color textMuted = Color(0xFFA0A0CC);
}

class GameHistoryScreen extends StatelessWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  const GameHistoryScreen({super.key, required this.tag, required this.color, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return BaseDetailScreen(
      title: "Game History",
      heroTag: tag,
      color: color,
      iconData: iconData,
      bodyContent: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Past Matches & Records",
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 15),
            Expanded(child: ListView(children: [_buildHistoryTile("Match #101 - Victory", "Call Break, 4 players, 20 rounds", Icons.military_tech), _buildHistoryTile("Match #100 - Loss", "Marriage, 3 players, 1 hour 30 min", Icons.flag), _buildHistoryTile("Match #99 - Draw", "Call Break, Quick Match", Icons.replay)])),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(String title, String subtitle, IconData icon) {
    return Card(
      color: ModernColors.darkSurface.withOpacity(0.7),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          title,
          style: GoogleFonts.inter(color: ModernColors.neonCyan, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: GoogleFonts.inter(color: ModernColors.textMuted)),
        trailing: const Icon(Icons.arrow_forward_ios, color: ModernColors.textMuted, size: 16),
        onTap: () {
          // Navigate to detailed match summary
        },
      ),
    );
  }
}
