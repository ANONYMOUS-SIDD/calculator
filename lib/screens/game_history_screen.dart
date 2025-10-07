// game_history_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../model/game_history_models.dart';
import '../../repositories/history_repository.dart';
import '../model/user_model.dart';
import '../widgets/game_details_dialog.dart';
import 'base_detail_screen.dart';

class ModernColors {
  static const Color primaryBlue = Color(0xFF1E3C72);
  static const Color accentPurple = Color(0xFF2A5298);
  static const Color textDark = Color(0xFF1A243F);
  static const Color textLight = Color(0xFF666666);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
}

class GameHistoryScreen extends StatefulWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  const GameHistoryScreen({super.key, required this.tag, required this.color, required this.iconData});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  List<String> _allPlayers = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  void _loadPlayers() {
    _allPlayers = HistoryRepository.getAllPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return BaseDetailScreen(
      title: "Game History",
      heroTag: widget.tag,
      color: widget.color,
      iconData: widget.iconData,
      bodyContent: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildTopPlayersSection(),
            const SizedBox(height: 12),
            Expanded(child: _buildGamesList()),
          ],
        ),
      ),
    );
  }

  // Top Players Section - Enhanced with Better Glowing Effects
  Widget _buildTopPlayersSection() {
    final topPlayers = _getTopPlayers();
    if (topPlayers.length < 3) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced margin
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.blue.shade50, Colors.purple.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 2nd Place (Left)
          _buildTopPlayerItem(topPlayers[1], 1),

          // 1st Place (Center - Special)
          _buildTopPlayerItem(topPlayers[0], 0),

          // 3rd Place (Right)
          _buildTopPlayerItem(topPlayers[2], 2),
        ],
      ),
    );
  }

  Widget _buildTopPlayerItem(String playerName, int rank) {
    return Column(
      children: [
        // Ranking Badge at Top with Enhanced Glow and Icons for All Positions
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: _getRankGradient(rank),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(2), bottomRight: Radius.circular(2)),
            boxShadow: [
              BoxShadow(color: _getRankColor(rank).withOpacity(0.4), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 3)),
              BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 2, offset: const Offset(0, 1)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getRankIcon(rank), color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                _getRankText(rank),
                style: GoogleFonts.poppins(fontSize: rank == 0 ? 12 : 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Player Avatar - Original Size
        Container(
          width: rank == 0 ? 56 : 48,
          height: rank == 0 ? 56 : 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _getRankBorderColor(rank), width: rank == 0 ? 2.0 : 1.5),
            boxShadow: [BoxShadow(color: _getRankColor(rank).withOpacity(0.3), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 3))],
          ),
          child: _buildPlayerAvatar(playerName),
        ),
        const SizedBox(height: 6),

        // Player Name with Thinner Outline Container - Original Size
        Text(
          _getShortName(playerName),
          style: GoogleFonts.quicksand(fontSize: rank == 0 ? 12 : 11, fontWeight: FontWeight.w900, color: rank == 0 ? Colors.amber.shade800 : Colors.blue.shade900, letterSpacing: 0.3),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  // Games List - MODIFIED to group by date and REVERSE the order (Newest First)
  Widget _buildGamesList() {
    // 1. Get all games
    final allGames = HistoryRepository.getAllGames();

    if (allGames.isEmpty) {
      return _buildEmptyState('No game history yet', Icons.history_toggle_off);
    }

    // 2. Group games by date
    final groupedGames = <String, List<CallBreakGameHistory>>{};
    for (final game in allGames) {
      // Create a sortable date key (YYYY-MM-DD)
      final dateKey = '${game.timestamp.year}-${game.timestamp.month.toString().padLeft(2, '0')}-${game.timestamp.day.toString().padLeft(2, '0')}';
      if (!groupedGames.containsKey(dateKey)) {
        groupedGames[dateKey] = [];
      }
      groupedGames[dateKey]!.add(game);
    }

    // 3. Sort keys (dates) in descending order (Newest date at the beginning of the list)
    final sortedDateKeys = groupedGames.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: sortedDateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDateKeys[index];
        final gamesForDate = groupedGames[dateKey]!;

        // The 'isMostRecent' parameter is removed as we are reverting the special highlighting
        return _buildDateGroupContainer(dateKey, gamesForDate);
      },
    );
  }

  // MODIFIED: Reverted styling to the subtle, original iOS-like look
  Widget _buildDateGroupContainer(String dateKey, List<CallBreakGameHistory> games) {
    // Retaining the subtle original styling for all groups
    const Color borderColor = Colors.grey;
    const double borderWidth = 1.0;
    const Color shadowColor = Colors.grey;
    const double blurRadius = 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.0), // Subtle outline
        boxShadow: [
          // Subtle iOS-like elevation shadow
          BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 8)),
          BoxShadow(
            color: Colors.white.withOpacity(0.9), // Inner light shadow for depth
            blurRadius: 1,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              _formatDateHeader(dateKey),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ModernColors.textDark, // Standard header text color
              ),
            ),
          ),
          // List of games for that date. Reverse game order for same-day history too (newest game first)
          // The .reversed call ensures that within a date group, the most recent game is at the top.
          ...games.reversed.map((game) => _buildModernGameCard(game)).toList(),
        ],
      ),
    );
  }

  // Modern Game Card - Compact with Updated Rank Section
  Widget _buildModernGameCard(CallBreakGameHistory game) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 350;

    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Keep margin between cards
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Subtle inner shadow for the card itself, complementing the group container's shadow
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.05), blurRadius: 5, spreadRadius: 0.5, offset: const Offset(0, 1))],
        border: Border.all(color: Colors.grey.shade200, width: 1.0),
      ),
      child: InkWell(
        onTap: () => GameDetailsDialog.show(game),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Compact Date and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Compact Date Container (Year/Month/Day)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1.0),
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 6, spreadRadius: 0.5, offset: const Offset(0, 2))],
                      gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.purple.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${game.timestamp.year}',
                          style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.purple.shade700),
                        ),
                        Container(
                          height: 10,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.4), borderRadius: BorderRadius.circular(1)),
                        ),
                        Text(
                          '${game.timestamp.month}',
                          style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.purple.shade700),
                        ),
                        Container(
                          height: 10,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.4), borderRadius: BorderRadius.circular(1)),
                        ),
                        Text(
                          '${game.timestamp.day}',
                          style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.purple.shade700),
                        ),
                      ],
                    ),
                  ),

                  // Compact Time Container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1.0),
                      boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.15), blurRadius: 6, spreadRadius: 0.5, offset: const Offset(0, 2))],
                      gradient: LinearGradient(colors: [Colors.purple.shade50, Colors.blue.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.watch_later_rounded, size: isSmallScreen ? 10 : 11, color: Colors.purple.shade700),
                        const SizedBox(width: 3),
                        Text(
                          '${game.timestamp.hour}:${game.timestamp.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.purple.shade800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Players with Ranks - Updated Rank Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.purple.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.15), width: 1),
                ),
                child: Row(
                  children: game.playerNames.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    final rank = _getPlayerRank(game, index);

                    return Expanded(
                      child: Column(
                        children: [
                          // Updated Rank Badge at Top with Reversed Shape (Top rounded, bottom sharp)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: _getRankGradient(rank),
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getRankIcon(rank), color: Colors.white, size: 8),
                                const SizedBox(width: 2),
                                Text(
                                  _getRankText(rank),
                                  style: GoogleFonts.poppins(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Player Avatar - Original Size
                          Container(
                            width: isSmallScreen ? 36 : 40,
                            height: isSmallScreen ? 36 : 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _getRankBorderColor(rank), width: 1.5),
                            ),
                            child: _buildPlayerAvatar(player),
                          ),
                          const SizedBox(height: 4),

                          // Player Name - Smaller Container and Font Size
                          Text(
                            _getShortName(player),
                            style: GoogleFonts.quicksand(
                              fontSize: isSmallScreen ? 9 : 10, // Reduced font size
                              fontWeight: FontWeight.w900,
                              color: Colors.blue.shade900,
                            ),
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
            ],
          ),
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: ModernColors.textLight),
          const SizedBox(height: 12),
          Text(message, style: GoogleFonts.inter(color: ModernColors.textLight, fontSize: 14)),
        ],
      ),
    );
  }

  // Build Player Avatar with Hive Profile Image
  Widget _buildPlayerAvatar(String playerName) {
    final userBox = Hive.box<User>('usersBox');
    final user = userBox.values.firstWhere((user) => user.username == playerName, orElse: () => User(username: playerName));

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

  // Fallback avatar when no profile image is available
  Widget _buildFallbackAvatar(String playerName) {
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

  // Utility Methods

  String _formatDateHeader(String dateKey) {
    final parts = dateKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    final dateTime = DateTime(year, month, day);

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final isToday = dateTime.year == today.year && dateTime.month == today.month && dateTime.day == today.day;
    final isYesterday = dateTime.year == yesterday.year && dateTime.month == yesterday.month && dateTime.day == yesterday.day;

    if (isToday) {
      return 'Today';
    } else if (isYesterday) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd('en_US').format(dateTime);
    }
  }

  List<String> _getTopPlayers() {
    return HistoryRepository.getAllPlayers().take(3).toList();
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

  int _getPlayerRank(CallBreakGameHistory game, int playerIndex) {
    // FIX: Explicitly map all scores to double to handle old data saved as int.
    // This resolves the 'type 'int' is not a subtype of type 'double' in type cast' error
    // when Hive retrieves old List<int> data into the new List<double> field.
    final List<double> scores = game.totalScores.map((score) => score.toDouble()).toList();

    List<Map<String, dynamic>> playersWithPoints = [];

    // Iterate over the safely converted 'scores' list.
    for (int i = 0; i < game.playerNames.length; i++) {
      playersWithPoints.add({'index': i, 'points': scores[i]});
    }

    // Sorting logic now reliably compares doubles.
    playersWithPoints.sort((a, b) => b['points'].compareTo(a['points']));

    for (int i = 0; i < playersWithPoints.length; i++) {
      if (playersWithPoints[i]['index'] == playerIndex) {
        // Return the 0-indexed rank.
        return i;
      }
    }
    // Fallback in case of error
    return playersWithPoints.length - 1;
  }

  Gradient _getRankGradient(int rank) {
    switch (rank) {
      case 0:
        return LinearGradient(colors: [Colors.amber.shade600, Colors.orange.shade800]);
      case 1:
        return LinearGradient(colors: [Colors.grey.shade500, Colors.grey.shade700]);
      case 2:
        return LinearGradient(colors: [Colors.brown.shade400, Colors.brown.shade600]);
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
        return Colors.brown;
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
        return Colors.brown.shade400;
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
}
