import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/call_break_controller.dart';
import '../../model/user_model.dart';

class RoundHistory extends StatelessWidget {
  final String tag;

  const RoundHistory({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallBreakController>(tag: tag);
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.rounds.isEmpty && !controller.bidCompleted.any((completed) => completed)) {
        return const SizedBox();
      }

      final bool isSmallScreen = screenWidth < 350;
      final double valueFontSize = isSmallScreen ? 11 : 13;
      final double playerNameFontSize = isSmallScreen ? 9 : 11;

      return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 25, spreadRadius: 3, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 2),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.blue.shade50, Colors.purple.shade50]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Players Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.purple.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: controller.selectedPlayers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final player = entry.value;

                  return Expanded(
                    child: Column(
                      children: [
                        // Circular Player Avatar
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _getPlayerColor(index).withOpacity(0.8), width: 2.5),
                            boxShadow: [BoxShadow(color: _getPlayerColor(index).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                          ),
                          child: ClipOval(child: _buildPlayerAvatar(player)),
                        ),
                        const SizedBox(height: 8),

                        // Player Name with Deep Blue Color
                        Text(
                          _getShortName(player.username),
                          style: GoogleFonts.quicksand(
                            fontSize: playerNameFontSize,
                            fontWeight: FontWeight.w900,
                            color: Colors.blue.shade900, // Deep blue color
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Completed Rounds with Current Bids as Last Row
            ...controller.rounds.map((round) {
              return Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    // Round Results
                    ...round.bids.asMap().entries.map((entry) {
                      final index = entry.key;
                      final bid = entry.value;
                      final extra = round.extras[index];
                      final failed = extra < bid;

                      return Expanded(child: Center(child: _buildRoundResult(bid, extra, failed, valueFontSize)));
                    }).toList(),
                  ],
                ),
              );
            }).toList(),

            // Current Bids with Pink and Purple Outlines
            if (controller.bidCompleted.any((completed) => completed) || controller.currentBids.any((bid) => bid > 0)) ...[
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(top: 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink.withOpacity(0.3), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    ...controller.currentBids.asMap().entries.map((entry) {
                      final index = entry.key;
                      final bid = entry.value;
                      final bidCompleted = controller.bidCompleted[index];

                      return Expanded(
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: bidCompleted || bid > 0
                                    ? Colors
                                          .purple // Purple outline when bid is placed
                                    : Colors.pink.withOpacity(0.6), // Pink outline when empty
                                width: 2.0,
                              ),
                            ),
                            child: Center(
                              child: bidCompleted || bid > 0
                                  ? Text(
                                      '$bid',
                                      style: GoogleFonts.poppins(fontSize: valueFontSize, fontWeight: FontWeight.w800, color: Colors.purple.shade700),
                                    )
                                  : const SizedBox(), // Empty circle when no bid
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],

            // Updated Final Score Section - Smaller and better designed
            if (controller.rounds.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                  border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                ),
                child: Column(
                  children: [
                    // Player Profiles and Names Row
                    Row(
                      children: controller.selectedPlayers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final player = entry.value;
                        final rank = _getPlayerRank(controller, index);

                        return Expanded(
                          child: Column(
                            children: [
                              // Ranking Badge (1st, 2nd, 3rd) - Based on actual rank
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: _getRankGradient(rank),
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                                  boxShadow: [BoxShadow(color: _getRankColor(rank).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_getRankIcon(rank), color: Colors.white, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getRankText(rank),
                                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),

                              // Player Avatar
                              Container(
                                width: 56,
                                height: 56,
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _getRankBorderColor(rank), width: 2.5),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
                                ),
                                child: ClipOval(child: _buildPlayerAvatar(player)),
                              ),
                              const SizedBox(height: 8),

                              // Player Name with Deep Blue Color
                              Text(
                                _getShortName(player.username),
                                style: GoogleFonts.quicksand(
                                  fontSize: playerNameFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blue.shade900, // Deep blue color
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    // Smaller Points Container with Better Design
                    // Smaller Points Container with Cyan Outline and Blue Glowing Shadow
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.cyan.withOpacity(0.6), // Cyan outline
                          width: 0.8, // Reduced from 1.5 to 0.8
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.2), // Cyan glow
                            blurRadius: 15, // Softer glow
                            spreadRadius: 2, // Wider spread for proper glow
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.15), // Blue accent glow
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: controller.selectedPlayers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final totalPoints = controller.getTotalPoints(index);
                          final isNegative = totalPoints < 0;
                          final isLast = index == controller.selectedPlayers.length - 1;

                          return Expanded(
                            child: Container(
                              height: 28, // Reduced height for more compact look
                              child: Stack(
                                children: [
                                  Center(
                                    child: isNegative
                                        ? Container(
                                            width: 24, // Slightly smaller circle
                                            height: 24, // Slightly smaller circle
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.red, width: 1.5),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${totalPoints.abs()}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 8, // Smaller font for smaller circle
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            '${totalPoints.abs()}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12, // Slightly smaller font
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green.shade600,
                                            ),
                                          ),
                                  ),
                                  // Shorter vertical divider
                                  if (!isLast)
                                    Positioned(
                                      right: 0,
                                      top: 6, // Start divider lower
                                      bottom: 6, // End divider higher
                                      child: Container(
                                        width: 0.8,
                                        color: Colors.blueAccent.withOpacity(0.4), // Blue glowing divider
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // Helper method to get player color based on index
  Color _getPlayerColor(int index) {
    final colors = [Colors.blue.shade700, Colors.purple.shade700, Colors.green.shade700, Colors.orange.shade700, Colors.red.shade700];
    return colors[index % colors.length];
  }

  // Helper method to get player rank based on points
  int _getPlayerRank(CallBreakController controller, int playerIndex) {
    List<Map<String, dynamic>> playersWithPoints = [];

    for (int i = 0; i < controller.selectedPlayers.length; i++) {
      playersWithPoints.add({'index': i, 'points': controller.getTotalPoints(i)});
    }

    // Sort by points descending
    playersWithPoints.sort((a, b) => b['points'].compareTo(a['points']));

    // Find the rank of the current player
    for (int i = 0; i < playersWithPoints.length; i++) {
      if (playersWithPoints[i]['index'] == playerIndex) {
        return i; // Return the rank (0-based)
      }
    }

    return playersWithPoints.length - 1; // Default to last rank if not found
  }

  // Helper methods for ranking
  Gradient _getRankGradient(int rank) {
    switch (rank) {
      case 0: // 1st
        return LinearGradient(colors: [Colors.amber.shade600, Colors.orange.shade800]);
      case 1: // 2nd
        return LinearGradient(colors: [Colors.grey.shade500, Colors.grey.shade700]);
      case 2: // 3rd
        return LinearGradient(colors: [Colors.orange.shade700, Colors.deepOrange.shade800]);
      default:
        return LinearGradient(colors: [Colors.blue.shade500, Colors.blue.shade700]);
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getRankBorderColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber.shade400;
      case 1:
        return Colors.grey.shade400;
      case 2:
        return Colors.orange.shade400;
      default:
        return Colors.blue.shade400;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 0:
        return Icons.emoji_events_rounded;
      case 1:
        return Icons.workspace_premium_rounded;
      case 2:
        return Icons.military_tech_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  String _getRankText(int rank) {
    switch (rank) {
      case 0:
        return '1st';
      case 1:
        return '2nd';
      case 2:
        return '3rd';
      default:
        return '${rank + 1}th';
    }
  }

  Widget _buildPlayerAvatar(User player) {
    if (player.profileImagePath != null && player.profileImagePath!.isNotEmpty) {
      return _buildFileImage(player.profileImagePath!);
    } else {
      return _buildDefaultAvatar(player.username);
    }
  }

  Widget _buildFileImage(String filePath) {
    final file = File(filePath);

    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar("Error");
        },
      );
    } else {
      return _buildDefaultAvatar("No File");
    }
  }

  Widget _buildDefaultAvatar(String username) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: Text(
          _getInitials(username),
          style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  String _getShortName(String name) {
    final names = name.split(' ');
    return names.first;
  }

  Widget _buildRoundResult(int bid, int extra, bool failed, double fontSize) {
    if (failed) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.red, width: 2.0),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Text(
            '$bid',
            style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w800, color: Colors.red),
          ),
        ),
      );
    } else {
      final extraValue = extra - bid;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$bid.$extraValue',
            style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w700, color: extraValue > 0 ? Colors.green.shade600 : Colors.blue.shade600),
          ),
        ],
      );
    }
  }
}
