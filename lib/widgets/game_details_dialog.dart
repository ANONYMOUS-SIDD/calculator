import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../model/game_history_models.dart';
import '../model/user_model.dart';

class GameDetailsDialog {
  static void show(CallBreakGameHistory game) {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    final bool isSmallScreen = screenWidth < 350;
    final double valueFontSize = isSmallScreen ? 11 : 13;
    final double playerNameFontSize = isSmallScreen ? 9 : 11;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(Get.context!).size.height * 0.9),
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 15, left: 8, right: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 25, spreadRadius: 3, offset: const Offset(0, 8)),
                  BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: Colors.grey.shade100, width: 2),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.blue.shade50, Colors.purple.shade50]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern Header with Icon, Date and Close Button
                  Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Game Icon Container
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1),
                            boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {},
                              child: Container(
                                width: isSmallScreen ? 36 : 40,
                                height: isSmallScreen ? 36 : 40,
                                padding: const EdgeInsets.all(8),
                                child: Icon(Icons.sports_esports_rounded, size: isSmallScreen ? 18 : 20, color: Colors.blue.shade700),
                              ),
                            ),
                          ),
                        ),

                        // Modern Date Container with Vertical Dividers
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 3)),
                              BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 5, spreadRadius: 0.5, offset: const Offset(0, 1)),
                            ],
                            gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.purple.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${game.timestamp.year}',
                                style: GoogleFonts.poppins(fontSize: isSmallScreen ? 10 : 12, fontWeight: FontWeight.w600, color: Colors.blue.shade800),
                              ),
                              Container(
                                height: 16,
                                width: 1,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.4), borderRadius: BorderRadius.circular(1)),
                              ),
                              Text(
                                '${game.timestamp.month}',
                                style: GoogleFonts.poppins(fontSize: isSmallScreen ? 10 : 12, fontWeight: FontWeight.w600, color: Colors.blue.shade800),
                              ),
                              Container(
                                height: 16,
                                width: 1,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.4), borderRadius: BorderRadius.circular(1)),
                              ),
                              Text(
                                '${game.timestamp.day}',
                                style: GoogleFonts.poppins(fontSize: isSmallScreen ? 10 : 12, fontWeight: FontWeight.w600, color: Colors.blue.shade800),
                              ),
                            ],
                          ),
                        ),

                        // Modern Close Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Get.back(),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: isSmallScreen ? 36 : 40,
                                height: isSmallScreen ? 36 : 40,
                                padding: const EdgeInsets.all(8),
                                child: Icon(Icons.close_rounded, size: isSmallScreen ? 16 : 18, color: Colors.grey.shade600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Enhanced Players Section with Proper Profile Images
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.purple.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: game.playerNames.asMap().entries.map((entry) {
                        final index = entry.key;
                        final player = entry.value;

                        return Expanded(
                          child: Column(
                            children: [
                              // Circular Player Avatar with Proper Profile Image
                              Container(
                                width: isSmallScreen ? 48 : 52,
                                height: isSmallScreen ? 48 : 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _getPlayerColor(index).withOpacity(0.8), width: 2.5),
                                  boxShadow: [BoxShadow(color: _getPlayerColor(index).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                                ),
                                child: _buildPlayerAvatar(player),
                              ),
                              const SizedBox(height: 8),

                              // Player Name with Deep Blue Color
                              Text(
                                _getShortName(player),
                                style: GoogleFonts.quicksand(fontSize: isSmallScreen ? 8 : playerNameFontSize, fontWeight: FontWeight.w900, color: Colors.blue.shade900),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Score Section - Updated UI
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        // Completed Rounds with Horizontal Dividers
                        if (game.roundDetails != null && game.roundDetails!.isNotEmpty)
                          ...game.roundDetails!.asMap().entries.map((roundEntry) {
                            final roundIndex = roundEntry.key;
                            final round = roundEntry.value;
                            final isLastRound = roundIndex == game.roundDetails!.length - 1;

                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: isSmallScreen ? 8 : 10),
                                  child: Row(
                                    children: [
                                      // Round Results
                                      ...round.bids.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final bid = entry.value;
                                        final extra = round.extras[index];
                                        final totalTricks = bid + extra;
                                        final failed = totalTricks < bid;

                                        return Expanded(child: Center(child: _buildRoundResult(bid, extra, failed, isSmallScreen ? valueFontSize - 1 : valueFontSize)));
                                      }).toList(),
                                    ],
                                  ),
                                ),
                                // Horizontal divider between rounds
                                if (!isLastRound)
                                  Container(
                                    height: 1,
                                    color: Colors.grey.withOpacity(0.2),
                                    margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
                                  ),
                              ],
                            );
                          }).toList(),
                      ],
                    ),
                  ),

                  // Updated Final Score Section
                  if (game.roundDetails != null && game.roundDetails!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
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
                            children: game.playerNames.asMap().entries.map((entry) {
                              final index = entry.key;
                              final player = entry.value;
                              final rank = _getPlayerRank(game, index);

                              return Expanded(
                                child: Column(
                                  children: [
                                    // Ranking Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        gradient: _getRankGradient(rank),
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                                        boxShadow: [BoxShadow(color: _getRankColor(rank).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_getRankIcon(rank), color: Colors.white, size: isSmallScreen ? 8 : 10),
                                          const SizedBox(width: 2),
                                          Text(
                                            _getRankText(rank),
                                            style: GoogleFonts.poppins(fontSize: isSmallScreen ? 7 : 9, fontWeight: FontWeight.w800, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Player Avatar with Proper Profile Image
                                    Container(
                                      width: isSmallScreen ? 40 : 48,
                                      height: isSmallScreen ? 40 : 48,
                                      margin: const EdgeInsets.only(top: 6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: _getRankBorderColor(rank), width: 2.0),
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
                                      ),
                                      child: _buildPlayerAvatar(player),
                                    ),
                                    const SizedBox(height: 6),

                                    // Player Name
                                    Text(
                                      _getShortName(player),
                                      style: GoogleFonts.quicksand(fontSize: isSmallScreen ? 8 : playerNameFontSize, fontWeight: FontWeight.w900, color: Colors.blue.shade900),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 12),

                          // Points Container
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.cyan.withOpacity(0.6), width: 0.8),
                              boxShadow: [
                                BoxShadow(color: Colors.cyan.withOpacity(0.2), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4)),
                                BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              children: game.playerNames.asMap().entries.map((entry) {
                                final index = entry.key;
                                final totalPoints = game.totalScores[index].toDouble();
                                final isNegative = totalPoints < 0;
                                final isLast = index == game.playerNames.length - 1;

                                return Expanded(
                                  child: Container(
                                    height: isSmallScreen ? 20 : 24,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: isNegative
                                              ? Container(
                                                  width: isSmallScreen ? 18 : 22,
                                                  height: isSmallScreen ? 18 : 22,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: Colors.red, width: 1.2),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      totalPoints.abs().toStringAsFixed(0),
                                                      style: GoogleFonts.poppins(fontSize: isSmallScreen ? 6 : 7, fontWeight: FontWeight.w700, color: Colors.red),
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  totalPoints.toStringAsFixed(0),
                                                  style: GoogleFonts.poppins(fontSize: isSmallScreen ? 9 : 11, fontWeight: FontWeight.w700, color: Colors.green.shade600),
                                                ),
                                        ),
                                        if (!isLast) Positioned(right: 0, top: 4, bottom: 4, child: Container(width: 0.8, color: Colors.blueAccent.withOpacity(0.4))),
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
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  static Widget _buildRoundResult(int bid, int extra, bool failed, double fontSize) {
    if (failed) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.red, width: 1.8),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Text(
            '$bid',
            style: GoogleFonts.poppins(fontSize: fontSize - 1, fontWeight: FontWeight.w800, color: Colors.red),
          ),
        ),
      );
    } else {
      final decimalValue = bid + (extra * 0.1);

      return Container(
        height: 32,
        child: Center(
          child: Text(
            decimalValue.toStringAsFixed(1),
            style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w700, color: extra > 0 ? Colors.green.shade600 : Colors.blue.shade600),
          ),
        ),
      );
    }
  }

  static Widget _buildPlayerAvatar(String playerName) {
    // Get the user from Hive database
    final userBox = Hive.box<User>('usersBox');
    final user = userBox.values.firstWhere(
      (user) => user.username == playerName,
      orElse: () => User(username: playerName), // Fallback if user not found
    );

    // If profile image exists and is not empty, display it
    if (user.profileImagePath != null && user.profileImagePath!.isNotEmpty) {
      return ClipOval(
        child: Image.file(
          File(user.profileImagePath!),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackAvatar(playerName);
          },
        ),
      );
    } else {
      return _buildFallbackAvatar(playerName);
    }
  }

  static Widget _buildFallbackAvatar(String playerName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: Text(
          _getInitials(playerName),
          style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  static String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  static String _getShortName(String name) {
    final names = name.split(' ');
    return names.first;
  }

  static Color _getPlayerColor(int index) {
    final colors = [Colors.blue.shade700, Colors.purple.shade700, Colors.green.shade700, Colors.orange.shade700, Colors.red.shade700];
    return colors[index % colors.length];
  }

  static int _getPlayerRank(CallBreakGameHistory game, int playerIndex) {
    List<Map<String, dynamic>> playersWithPoints = [];
    for (int i = 0; i < game.playerNames.length; i++) {
      playersWithPoints.add({'index': i, 'points': game.totalScores[i]});
    }
    playersWithPoints.sort((a, b) => b['points'].compareTo(a['points']));
    for (int i = 0; i < playersWithPoints.length; i++) {
      if (playersWithPoints[i]['index'] == playerIndex) {
        return i;
      }
    }
    return playersWithPoints.length - 1;
  }

  static Gradient _getRankGradient(int rank) {
    switch (rank) {
      case 0:
        return LinearGradient(colors: [Colors.amber.shade600, Colors.orange.shade800]);
      case 1:
        return LinearGradient(colors: [Colors.grey.shade500, Colors.grey.shade700]);
      case 2:
        return LinearGradient(colors: [Colors.orange.shade700, Colors.deepOrange.shade800]);
      default:
        return LinearGradient(colors: [Colors.blue.shade500, Colors.blue.shade700]);
    }
  }

  static Color _getRankColor(int rank) {
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

  static Color _getRankBorderColor(int rank) {
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

  static IconData _getRankIcon(int rank) {
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

  static String _getRankText(int rank) {
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
}
