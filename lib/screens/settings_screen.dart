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

/// Settings screen for application configuration and preferences
/// Provides controls for theme, notifications, audio, and account management
class SettingsScreen extends StatefulWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  const SettingsScreen({super.key, required this.tag, required this.color, required this.iconData});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  double _volumeLevel = 0.7;

  @override
  Widget build(BuildContext context) {
    return BaseDetailScreen(
      title: "Settings",
      heroTag: widget.tag,
      color: widget.color,
      iconData: widget.iconData,
      bodyContent: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("General"),
            _buildSettingsTile(
              title: "Theme Mode",
              trailing: const Icon(Icons.brightness_2, color: ModernColors.textMuted),
              onTap: () {
                // Toggle theme logic would be implemented here
              },
            ),
            _buildSectionTitle("Audio & Notifications"),
            _buildSettingsTile(
              title: "Game Notifications",
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: widget.color,
              ),
            ),
            _buildSettingsTile(
              title: "Sound Volume",
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up, color: ModernColors.textMuted),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 150,
                    child: Slider(
                      value: _volumeLevel,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      activeColor: widget.color,
                      inactiveColor: ModernColors.textMuted.withOpacity(0.5),
                      onChanged: (double value) {
                        setState(() {
                          _volumeLevel = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            _buildSectionTitle("Account"),
            _buildSettingsTile(
              title: "Log Out",
              trailing: const Icon(Icons.logout, color: Colors.redAccent),
              onTap: () {
                // Logout logic would be implemented here
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds section title with consistent styling
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: ModernColors.textLight.withOpacity(0.9)),
      ),
    );
  }

  /// Builds individual settings tile with consistent styling
  Widget _buildSettingsTile({required String title, Widget? trailing, VoidCallback? onTap}) {
    return Card(
      color: ModernColors.darkSurface.withOpacity(0.7),
      margin: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        title: Text(title, style: GoogleFonts.inter(color: ModernColors.textLight)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
