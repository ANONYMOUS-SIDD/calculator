import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/call_break_controller.dart';
import '../../model/user_model.dart';
import 'bid_picker_dialog.dart';
import 'ot_picker_dialog.dart';

/// Player card widget that displays player information and interaction buttons
/// Shows player profile, current bid status, and BID/OT action buttons
class PlayerCard extends StatelessWidget {
  final int index;
  final User player;
  final String tag;

  const PlayerCard({super.key, required this.index, required this.player, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallBreakController>(tag: tag);
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      final currentBid = controller.currentBids[index];
      final bidCompleted = controller.bidCompleted[index];
      final otCompleted = controller.otCompleted[index];
      final bidPhase = controller.bidPhase.value;
      final otPhase = controller.otPhase.value;

      // Get previous bid from last round if available
      final previousBid = controller.rounds.isNotEmpty ? controller.rounds.last.bids[index] : 0;

      // Responsive sizing
      final bool isSmallScreen = screenWidth < 350;
      final double buttonWidth = isSmallScreen ? 50 : 52;
      final double buttonHeight = isSmallScreen ? 28 : 30;
      final double iconSize = isSmallScreen ? 12 : 13;
      final double fontSize = isSmallScreen ? 8 : 9;
      final double borderRadius = isSmallScreen ? 8 : 9;
      final double horizontalPadding = isSmallScreen ? 4 : 5;

      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 1))],
          border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Player Profile with Circular Image
            _buildPlayerProfile(),
            const SizedBox(width: 8),

            // Player Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Player Name
                  Text(
                    player.username,
                    style: GoogleFonts.poppins(fontSize: isSmallScreen ? 13 : 14, fontWeight: FontWeight.w700, color: Colors.blue.shade900),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Current Bid Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 6, spreadRadius: 0.5, offset: const Offset(0, 1))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBidLabel(isSmallScreen),
                        Container(width: 1, height: isSmallScreen ? 10 : 12, margin: const EdgeInsets.symmetric(horizontal: 4), color: Colors.blueAccent.withOpacity(0.4)),
                        _buildBidValue(currentBid, previousBid, isSmallScreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Bid & OT Buttons
            Row(
              children: [
                _buildEnhancedActionButton(icon: Icons.gavel_rounded, label: 'BID', isActive: bidPhase && !bidCompleted, activeColor: Colors.pink, inactiveColor: Colors.blue, onPressed: bidPhase && !bidCompleted ? () => _showBidPicker(context, index, tag) : null, buttonWidth: buttonWidth, buttonHeight: buttonHeight, iconSize: iconSize, fontSize: fontSize, borderRadius: borderRadius, horizontalPadding: horizontalPadding),
                SizedBox(width: isSmallScreen ? 4 : 6),

                _buildEnhancedActionButton(icon: Icons.auto_graph_rounded, label: 'OT', isActive: otPhase && !otCompleted, activeColor: Colors.green, inactiveColor: Colors.cyan, onPressed: otPhase && !otCompleted ? () => _showOTPicker(context, index, tag) : null, buttonWidth: buttonWidth, buttonHeight: buttonHeight, iconSize: iconSize, fontSize: fontSize, borderRadius: borderRadius, horizontalPadding: horizontalPadding),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Builds the player profile circle with image or initials
  Widget _buildPlayerProfile() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 2.0),
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 6, spreadRadius: 1, offset: const Offset(0, 2))],
      ),
      child: ClipOval(child: _buildProfileImage()),
    );
  }

  /// Builds profile image with file check and fallback
  Widget _buildProfileImage() {
    if (player.profileImagePath != null && player.profileImagePath!.isNotEmpty) {
      return _buildFileImage();
    } else {
      return _buildDefaultAvatar();
    }
  }

  /// Builds image from file with error handling
  Widget _buildFileImage() {
    final file = File(player.profileImagePath!);

    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  /// Builds default avatar with gradient and initials
  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: Text(
          _getInitials(player.username),
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  /// Extracts initials from player name for avatar display
  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  /// Builds the bid label text
  Widget _buildBidLabel(bool isSmallScreen) {
    return Text(
      'Current Bid',
      style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.blue.shade800),
    );
  }

  /// Builds the bid value display with color coding
  Widget _buildBidValue(int currentBid, int previousBid, bool isSmallScreen) {
    final hasCurrentBid = currentBid > 0;
    final displayValue = hasCurrentBid ? currentBid : (previousBid > 0 ? previousBid : 0);
    final color = hasCurrentBid ? Colors.blue : Colors.grey;
    final isPreviousBid = !hasCurrentBid && previousBid > 0;

    return Text(
      hasCurrentBid ? '$displayValue' : (isPreviousBid ? '$displayValue' : '-'),
      style: GoogleFonts.poppins(fontSize: isSmallScreen ? 11 : 12, fontWeight: FontWeight.w800, color: isPreviousBid ? Colors.purple : color),
    );
  }

  /// Builds enhanced action button with gradient and shadow effects
  Widget _buildEnhancedActionButton({required IconData icon, required String label, required bool isActive, required Color activeColor, required Color inactiveColor, required VoidCallback? onPressed, required double buttonWidth, required double buttonHeight, required double iconSize, required double fontSize, required double borderRadius, required double horizontalPadding}) {
    // Special handling for OT button in disabled mode - using cyan colors
    final bool isOtButton = label == 'OT';
    final Color disabledOutlineColor = isOtButton ? Colors.cyan[700]! : inactiveColor.withOpacity(0.6);

    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: isActive ? LinearGradient(colors: [activeColor, Color.alphaBlend(activeColor.withOpacity(0.7), activeColor)], begin: Alignment.topLeft, end: Alignment.bottomRight) : LinearGradient(colors: [Colors.grey.shade50, Colors.grey.shade100], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: isActive ? activeColor.withOpacity(0.9) : disabledOutlineColor, width: isActive ? 1.5 : 1.2),
        boxShadow: [if (isActive) BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 5, spreadRadius: 0.5, offset: const Offset(0, 2)) else BoxShadow(color: isOtButton ? Colors.cyan.withOpacity(0.2) : inactiveColor.withOpacity(0.2), blurRadius: 3, spreadRadius: 0.5, offset: const Offset(0, 1.5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed,
          splashColor: isActive ? activeColor.withOpacity(0.2) : inactiveColor.withOpacity(0.1),
          highlightColor: isActive ? activeColor.withOpacity(0.1) : inactiveColor.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: isActive
                      ? Colors.white
                      : isOtButton
                      ? Colors.cyan[700]!
                      : inactiveColor.withOpacity(0.8),
                ),
                SizedBox(width: horizontalPadding - 1),
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w700, color: isActive ? Colors.white : Colors.grey.shade700, letterSpacing: 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows bid picker dialog for the player
  void _showBidPicker(BuildContext context, int playerIndex, String tag) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BidPickerDialog(playerIndex: playerIndex, tag: tag);
      },
    );
  }

  /// Shows OT (overtricks) picker dialog for the player
  void _showOTPicker(BuildContext context, int playerIndex, String tag) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OTPickerDialog(playerIndex: playerIndex, tag: tag);
      },
    );
  }
}
