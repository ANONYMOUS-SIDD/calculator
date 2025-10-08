// game_history_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../model/game_history_models.dart';
import '../../model/marriage_game_history.dart';
import '../../repositories/history_repository.dart';
import '../model/user_model.dart';
import '../widgets/game_details_dialog.dart';
import '../widgets/moder_app_bar.dart';

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
  int _selectedGameType = 0; // 0 = Call Break, 1 = Marriage

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;

    return Scaffold(
      appBar: ModernAppBar(title: "Game History"),
      backgroundColor: const Color(0xFFF8FAFF),

      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildTopPlayersSection(),
            const SizedBox(height: 12),
            Expanded(child: _buildGamesList()),
            _buildGameTypeSelector(isSmallScreen),
          ],
        ),
      ),
    );
  }

  // UPDATED: Game Type Selector with Icons and Deep Blue Gradient
  Widget _buildGameTypeSelector(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildGameTypeButton(title: "Call Break", icon: Icons.leaderboard_rounded, isSelected: _selectedGameType == 0, onTap: () => setState(() => _selectedGameType = 0)),
          ),
          Expanded(
            child: _buildGameTypeButton(title: "Marriage", icon: Icons.favorite_rounded, isSelected: _selectedGameType == 1, onTap: () => setState(() => _selectedGameType = 1)),
          ),
        ],
      ),
    );
  }

  // UPDATED: Game Type Button with Icon and Deep Blue Gradient
  Widget _buildGameTypeButton({required String title, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        gradient: isSelected ? const LinearGradient(colors: [Color(0xFF1E3C72), Color(0xFF2A5298)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        color: isSelected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected ? [BoxShadow(color: Colors.blue.shade800.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UPDATED: Top Players Section - Different for Call Break and Marriage
  Widget _buildTopPlayersSection() {
    final topPlayers = _selectedGameType == 0 ? _getTopCallBreakPlayers() : _getTopMarriagePlayers();

    if (topPlayers.length < 3) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        gradient: _selectedGameType == 0 ? LinearGradient(colors: [Colors.white, Colors.blue.shade50, Colors.purple.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight) : LinearGradient(colors: [Colors.white, Colors.blue.shade50, Colors.purple.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: (_selectedGameType == 0 ? Colors.blueAccent : Colors.blueAccent).withOpacity(0.15), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 2),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildTopPlayerItem(topPlayers[1], 1), _buildTopPlayerItem(topPlayers[0], 0), _buildTopPlayerItem(topPlayers[2], 2)]),
    );
  }

  Widget _buildTopPlayerItem(String playerName, int rank) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: _getRankGradient(rank),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(2), bottomRight: Radius.circular(2)),
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

  // Games List - Handles both Call Break and Marriage games
  Widget _buildGamesList() {
    if (_selectedGameType == 0) {
      final allGames = HistoryRepository.getAllCallBreakGames();
      if (allGames.isEmpty) {
        return _buildEmptyState('No Call Break games yet', Icons.history_toggle_off);
      }
      return _buildCallBreakGamesList(allGames);
    } else {
      final allGames = HistoryRepository.getAllMarriageGames();
      if (allGames.isEmpty) {
        return _buildEmptyState('No Marriage games yet', Icons.favorite_border_rounded);
      }
      return _buildMarriageGamesList(allGames);
    }
  }

  // Call Break Games List
  Widget _buildCallBreakGamesList(List<CallBreakGameHistory> allGames) {
    final groupedGames = <String, List<CallBreakGameHistory>>{};
    for (final game in allGames) {
      final dateKey = '${game.timestamp.year}-${game.timestamp.month.toString().padLeft(2, '0')}-${game.timestamp.day.toString().padLeft(2, '0')}';
      if (!groupedGames.containsKey(dateKey)) {
        groupedGames[dateKey] = [];
      }
      groupedGames[dateKey]!.add(game);
    }

    final sortedDateKeys = groupedGames.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: sortedDateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDateKeys[index];
        final gamesForDate = groupedGames[dateKey]!;
        return _buildDateGroupContainer(dateKey, gamesForDate, _buildCallBreakGameCard);
      },
    );
  }

  // Marriage Games List - UPDATED: Show most recent matches at top
  Widget _buildMarriageGamesList(List<MarriageGameHistory> allGames) {
    final groupedGames = <String, List<MarriageGameHistory>>{};
    for (final game in allGames) {
      final dateKey = '${game.playedAt.year}-${game.playedAt.month.toString().padLeft(2, '0')}-${game.playedAt.day.toString().padLeft(2, '0')}';
      if (!groupedGames.containsKey(dateKey)) {
        groupedGames[dateKey] = [];
      }
      groupedGames[dateKey]!.add(game);
    }

    final sortedDateKeys = groupedGames.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: sortedDateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDateKeys[index];
        final gamesForDate = groupedGames[dateKey]!;
        // UPDATED: Remove .reversed() to show most recent first
        return _buildDateGroupContainer(dateKey, gamesForDate, _buildMarriageGameCard);
      },
    );
  }

  // Generic Date Group Container - UPDATED: Remove .reversed() for marriage
  Widget _buildDateGroupContainer<T>(String dateKey, List<T> games, Widget Function(T) buildGameCard) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.0),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 1, spreadRadius: 1, offset: const Offset(0, 0)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              _formatDateHeader(dateKey),
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: ModernColors.textDark),
            ),
          ),
          // UPDATED: For marriage, show games in original order (most recent first)
          ...(_selectedGameType == 1 ? games : games.reversed).map((game) => buildGameCard(game)).toList(),
        ],
      ),
    );
  }

  // Call Break Game Card
  Widget _buildCallBreakGameCard(CallBreakGameHistory game) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              _buildGameHeader(game.timestamp, isSmallScreen),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.15), width: 1),
                ),
                child: Row(
                  children: game.playerNames.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    final rank = _getCallBreakPlayerRank(game, index);

                    return Expanded(
                      child: Column(
                        children: [
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
                          // In _buildCallBreakGameCard method - For Call Break, we don't have modes, so keep as is or remove badges
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
                          Text(
                            _getShortName(player),
                            style: GoogleFonts.quicksand(fontSize: isSmallScreen ? 9 : 10, fontWeight: FontWeight.w900, color: Colors.blue.shade900),
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

  // UPDATED: Marriage Game Card with same colors as Call Break
  Widget _buildMarriageGameCard(MarriageGameHistory game) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.05), blurRadius: 5, spreadRadius: 0.5, offset: const Offset(0, 1))],
        border: Border.all(color: Colors.grey.shade200, width: 1.0),
      ),
      child: InkWell(
        onTap: () => _showMarriageGameDetails(game),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // UPDATED: Date, Maal/Points, and Time in single row with matching heights
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date Container - Original Size
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1.0),
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 6, spreadRadius: 0.5, offset: const Offset(0, 2))],
                      gradient: const LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${game.playedAt.year}',
                          style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.purple.shade700),
                        ),
                        Container(
                          height: 10,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.4), borderRadius: BorderRadius.circular(1)),
                        ),
                        Text(
                          '${game.playedAt.month}',
                          style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.purple.shade700),
                        ),
                        Container(
                          height: 10,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.4), borderRadius: BorderRadius.circular(1)),
                        ),
                        Text(
                          '${game.playedAt.day}',
                          style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.purple.shade700),
                        ),
                      ],
                    ),
                  ),

                  // Maal & Points Container - Matching height, integer values
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), // Same vertical padding as date/time
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1.0),
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 6, spreadRadius: 0.5, offset: const Offset(0, 2))],
                      gradient: const LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Maal Section in row
                        // In _buildMarriageGameCard method, update the Maal section:
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Maal',
                              style: GoogleFonts.poppins(fontSize: isSmallScreen ? 9 : 10, fontWeight: FontWeight.w600, color: Colors.purple.shade700),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_calculateTotalPoints(game).toInt()}', // Show total points instead of 0
                              style: GoogleFonts.poppins(fontSize: isSmallScreen ? 9 : 10, fontWeight: FontWeight.w800, color: Colors.purple.shade900),
                            ),
                          ],
                        ),

                        // Vertical Divider
                        Container(
                          width: 1,
                          height: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.transparent, Colors.blueAccent, Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          ),
                        ),

                        // Points Section in row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Points',
                              style: GoogleFonts.poppins(fontSize: isSmallScreen ? 9 : 10, fontWeight: FontWeight.w600, color: Colors.purple.shade700),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${game.pointsPerRupee.toInt()}', // Convert to integer
                              style: GoogleFonts.poppins(fontSize: isSmallScreen ? 9 : 10, fontWeight: FontWeight.w800, color: Colors.purple.shade900),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Time Container - Original Size
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1.0),
                      boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.15), blurRadius: 6, spreadRadius: 0.5, offset: const Offset(0, 2))],
                      gradient: const LinearGradient(colors: [Color(0xFFF3E5F5), Color(0xFFE3F2FD)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.watch_later_rounded, size: isSmallScreen ? 10 : 11, color: Colors.purple.shade700),
                        const SizedBox(width: 3),
                        Text(
                          '${game.playedAt.hour}:${game.playedAt.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.purple.shade800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Players Section - UPDATED: Same colors as Call Break
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.15), width: 1),
                ),
                child: Row(
                  children: game.players.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    final rank = _getMarriagePlayerRank(game, index);

                    return Expanded(
                      child: Column(
                        children: [
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
                          // In _buildMarriageGameCard method, update the avatar part:
                          // In _buildMarriageGameCard method, update the avatar part:
                          Container(
                            width: isSmallScreen ? 36 : 40,
                            height: isSmallScreen ? 36 : 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _getRankBorderColor(rank), width: 1.5),
                            ),
                            child: _buildPlayerAvatar(
                              player.userName,
                              showWinBadge: _isWinMode(player.mode), // NEW CODE - ADD THIS
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getShortName(player.userName),
                            style: GoogleFonts.quicksand(fontSize: isSmallScreen ? 9 : 10, fontWeight: FontWeight.w900, color: Colors.blue.shade900),
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

  // Add this helper method to check if player was in win mode
  // Add this helper method to check if player was in win mode
  bool _isWinMode(String mode) {
    // Handle different possible string representations of the win mode
    return mode.toLowerCase().contains('win');
  }

  // Add this method to calculate total points for marriage game
  double _calculateTotalPoints(MarriageGameHistory game) {
    double totalPoints = 0.0;

    for (final player in game.players) {
      double playerPoints = player.pointsEarned;
      final isWinPlayer = player.mode?.toString().toLowerCase().contains('win') ?? false;

      if (isWinPlayer) {
        print('✅ WIN PLAYER DETECTED: ${player.userName}');

        // Simple logic: Doublee = 5 points, otherwise Sequence = 3 points
        if (player.isDoublee == true) {
          playerPoints += 5;
          print('➕ Added 5 points for Doublee mode');
        } else {
          playerPoints += 3;
          print('➕ Added 3 points for Sequence mode');
        }
      }

      print('🎯 Final points for ${player.userName}: $playerPoints');
      totalPoints += playerPoints;
    }

    return totalPoints;
  }

  // Marriage Game Details Dialog
  void _showMarriageGameDetails(MarriageGameHistory game) {
    // Calculate total match points from history
    final double totalMatchPoints = game.players.fold(0.0, (sum, player) {
      final isWinPlayer = player.mode.toLowerCase().contains('win');
      if (isWinPlayer) {
        return sum + (player.pointsEarned + (player.isDoublee ? 5.0 : 3.0));
      } else {
        return sum + player.pointsEarned;
      }
    });

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final bool isSmallScreen = maxWidth < 400;
            final double horizontalPadding = isSmallScreen ? 12.0 : 20.0;
            final double verticalPadding = isSmallScreen ? 12.0 : 16.0;

            return Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: isSmallScreen ? 380 : 450),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade100.withOpacity(0.8), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.blueGrey.shade100.withOpacity(0.7), blurRadius: 25, spreadRadius: 2, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Game icon, date in center, and close icon
                  Row(
                    children: [
                      // Game icon container
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300, width: 0.9),
                          boxShadow: [BoxShadow(color: Colors.grey.shade300.withOpacity(0.6), blurRadius: 8, spreadRadius: 0.5, offset: const Offset(0, 4))],
                        ),
                        child: Icon(Icons.sports_esports_rounded, color: Colors.purple.shade500, size: 18),
                      ),

                      const Spacer(),

                      // UPDATED: Date container with glowing outline and vertical dividers
                      Container(
                        // Compact padding is maintained
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          // Thinner border width
                          border: Border.all(color: Colors.blue.shade300.withOpacity(0.9), width: 0.5),
                          boxShadow: [
                            // Subtler Blue Glow (Reduced further)
                            BoxShadow(
                              color: Colors.blue.shade600.withOpacity(0.3), // Reduced opacity
                              blurRadius: 3, // Reduced blur
                              spreadRadius: 0.3, // Reduced spread
                              offset: const Offset(0, 0),
                            ),
                            // Inner White Shadow (keeps the look focused)
                            BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: -1.0, offset: const Offset(0, 0)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              game.playedAt.year.toString(),
                              style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.blue.shade900),
                            ),
                            // Thin, transparent vertical divider
                            Container(
                              height: 10,
                              width: 1.0,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(color: Colors.blue.shade400.withOpacity(0.5), borderRadius: BorderRadius.circular(1.5)),
                            ),
                            Text(
                              game.playedAt.month.toString().padLeft(2, '0'),
                              style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.blue.shade900),
                            ),
                            // Thin, transparent vertical divider
                            Container(
                              height: 10,
                              width: 1.0,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(color: Colors.blue.shade400.withOpacity(0.5), borderRadius: BorderRadius.circular(1.5)),
                            ),
                            Text(
                              game.playedAt.day.toString().padLeft(2, '0'),
                              style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.blue.shade900),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // UPDATED: Close button container identical to game icon
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300, width: 0.9),
                            boxShadow: [BoxShadow(color: Colors.grey.shade300.withOpacity(0.6), blurRadius: 8, spreadRadius: 0.5, offset: const Offset(0, 4))],
                          ),
                          child: Icon(Icons.close_rounded, size: 10, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildGameTallySection(totalMatchPoints, game.pointsPerRupee, game.numberOfPlayers, isSmallScreen),
                  const SizedBox(height: 16),
                  _buildPlayerBreakdownSection(game.players, game.pointsPerRupee, isSmallScreen),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // REST OF THE CODE REMAINS EXACTLY THE SAME AS YOUR PREVIOUS VERSION
  // UPDATED: Negative points now use red color with decline graph
  Widget _buildPlayerRow({required MarriagePlayerHistory player, required double netPointChange, required double totalAmount, required Color primaryColor, required Color secondaryColor, required int playerFlex, required int pointsFlex, required int amountFlex, required bool isSmallScreen}) {
    final bool isPositive = netPointChange > 0;
    final bool isWinner = player.mode.toLowerCase().contains('win');

    // Determine colors based on positive/negative
    final Color pointsColor = isPositive ? Colors.green.shade600 : Colors.red.shade600;
    final Color amountColor = isPositive ? Colors.blue.shade600 : Colors.orange.shade600;
    final IconData pointsIcon = isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.blue.shade50, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: playerFlex,
            child: Row(
              children: [
                _playerAvatar(player, isSmallScreen),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlayerNameText(player.userName, isSmallScreen),
                      SizedBox(height: isSmallScreen ? 3 : 4),
                      _buildModePointsContainer(player.pointsEarned.toStringAsFixed(0), player.mode, player.isDoublee, isSmallScreen),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: pointsFlex,
            child: Align(alignment: Alignment.center, child: _buildPointsContainer(netPointChange.abs().toStringAsFixed(0), pointsColor, pointsIcon, isSmallScreen)),
          ),
          Expanded(
            flex: amountFlex,
            child: Align(alignment: Alignment.centerRight, child: _buildAmountContainer(totalAmount.abs().toStringAsFixed(0), amountColor, isPositive, isSmallScreen)),
          ),
        ],
      ),
    );
  }

  // UPDATED: Points container with proper colors for negative values
  Widget _buildPointsContainer(String text, Color color, IconData icon, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 6, vertical: isSmallScreen ? 2 : 3),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmallScreen ? 8 : 10, color: color),
          SizedBox(width: isSmallScreen ? 2 : 4),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: isSmallScreen ? 9 : 11, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  // UPDATED: Amount container with proper colors for negative values
  Widget _buildAmountContainer(String amount, Color color, bool isPositive, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 6, vertical: isSmallScreen ? 2 : 3),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isPositive ? "Win" : "Loss",
            style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade700),
          ),
          _buildVerticalDivider(height: isSmallScreen ? 10 : 12, margin: isSmallScreen ? 2 : 4),
          Text(
            "$amount",
            style: GoogleFonts.poppins(fontSize: isSmallScreen ? 9 : 11, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  // ========== REST OF THE METHODS REMAIN THE SAME ==========

  Widget _buildGameTallySection(double totalMatchPoints, double pointsPerRupee, int playersCount, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, spreadRadius: 1, offset: const Offset(0, 7))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade100, width: 0.8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 0.5, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatContainer(label: "Total Points", value: totalMatchPoints.toStringAsFixed(0), color: Colors.blue.shade600, isSmallScreen: isSmallScreen),
                _buildVerticalDivider(height: isSmallScreen ? 20 : 24, margin: isSmallScreen ? 4 : 6),
                _buildStatContainer(label: "Rate", value: pointsPerRupee.round().toString(), color: Colors.purple.shade600, isRate: true, isSmallScreen: isSmallScreen),
                _buildVerticalDivider(height: isSmallScreen ? 20 : 24, margin: isSmallScreen ? 4 : 6),
                _buildStatContainer(label: "Players", value: playersCount.toString(), color: Colors.orange.shade600, isSmallScreen: isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatContainer({required String label, required String value, required Color color, bool isRate = false, required bool isSmallScreen}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 6, vertical: isSmallScreen ? 2 : 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade700),
            ),
            const SizedBox(height: 1),
            Text(
              isRate ? "$value" : value,
              style: GoogleFonts.poppins(fontSize: isSmallScreen ? 10 : 11, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerBreakdownSection(List<MarriagePlayerHistory> players, double pointsPerRupee, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [BoxShadow(color: Colors.blueGrey.shade100.withOpacity(0.6), blurRadius: 15, spreadRadius: 0.5, offset: const Offset(0, 8))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 400;
          final int playerFlex = isWide ? 8 : 7;
          final int pointsFlex = isWide ? 3 : 3;
          final int amountFlex = isWide ? 3 : 4;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6.0 : 8.0, horizontal: isSmallScreen ? 8 : 10),
                child: _buildPlayerBreakdownHeader(playerFlex, pointsFlex, amountFlex, isSmallScreen),
              ),
              Divider(height: 1, thickness: 1, color: Colors.blue.shade50),
              ...players.map((player) {
                final double netPointChange = _calculateNetPointsForHistory(player, players);
                final double totalAmount = netPointChange * pointsPerRupee;

                final bool isPositive = netPointChange > 0;
                final Color primaryColor = isPositive ? Colors.green.shade600 : Colors.red.shade600;
                final Color secondaryColor = isPositive ? Colors.blue.shade600 : Colors.orange.shade600;

                return _buildPlayerRow(player: player, netPointChange: netPointChange, totalAmount: totalAmount, primaryColor: primaryColor, secondaryColor: secondaryColor, playerFlex: playerFlex, pointsFlex: pointsFlex, amountFlex: amountFlex, isSmallScreen: isSmallScreen);
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayerBreakdownHeader(int playerFlex, int pointsFlex, int amountFlex, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(flex: playerFlex, child: _buildHeaderContainerContent("Player", Icons.person_pin_circle_rounded, Colors.blue.shade600, TextAlign.center, isSmallScreen)),
        _buildVerticalDivider(height: isSmallScreen ? 16 : 20, margin: isSmallScreen ? 4 : 6),
        Expanded(flex: pointsFlex, child: _buildHeaderContainerContent("Points", Icons.star_purple500_outlined, Colors.pinkAccent, TextAlign.center, isSmallScreen)),
        _buildVerticalDivider(height: isSmallScreen ? 16 : 20, margin: isSmallScreen ? 4 : 6),
        Expanded(flex: amountFlex, child: _buildHeaderContainerContent("Amount", Icons.monetization_on, Colors.purple, TextAlign.center, isSmallScreen)),
      ],
    );
  }

  Widget _buildHeaderContainerContent(String title, IconData icon, Color color, TextAlign align, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: isSmallScreen ? 12 : 14, color: color),
        const SizedBox(width: 3),
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: isSmallScreen ? 10 : 11, color: color),
        ),
      ],
    );
  }

  Widget _buildPlayerNameText(String name, bool isSmallScreen) {
    return Text(
      name,
      style: GoogleFonts.poppins(fontSize: isSmallScreen ? 11 : 12, fontWeight: FontWeight.w700, color: Colors.indigo.shade700),
    );
  }

  Widget _buildModePointsContainer(String points, String mode, bool isDoublee, bool isSmallScreen) {
    final MaterialColor color = Colors.lightBlue;

    final double originalPoints = double.parse(points);
    final double displayPoints = mode.toLowerCase().contains('win') ? (originalPoints + (isDoublee ? 5.0 : 3.0)) : originalPoints;
    final String displayText = displayPoints.toStringAsFixed(0);

    final String modeName = _getModeDisplayName(mode);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 4, vertical: isSmallScreen ? 1 : 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.shade200.withOpacity(0.5), width: 1),
        boxShadow: [BoxShadow(color: color.shade100.withOpacity(0.5), blurRadius: 3, spreadRadius: 0.5, offset: const Offset(0, 1))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            modeName,
            style: GoogleFonts.poppins(fontSize: isSmallScreen ? 7 : 8, fontWeight: FontWeight.w600, color: color.shade700),
          ),
          _buildVerticalDivider(height: isSmallScreen ? 6 : 8, margin: isSmallScreen ? 2 : 3),
          Text(
            displayText,
            style: GoogleFonts.poppins(fontSize: isSmallScreen ? 7 : 8, fontWeight: FontWeight.w800, color: color.shade700),
          ),
          if (mode.toLowerCase().contains('win')) ...[
            _buildVerticalDivider(height: isSmallScreen ? 6 : 8, margin: isSmallScreen ? 2 : 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(color: isDoublee ? Colors.cyan.shade100 : Colors.green.shade100, borderRadius: BorderRadius.circular(2)),
              child: Text(
                isDoublee ? "+5" : "+3",
                style: GoogleFonts.poppins(fontSize: 5, fontWeight: FontWeight.w800, color: isDoublee ? Colors.cyan.shade800 : Colors.green.shade800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getModeDisplayName(String mode) {
    if (mode.toLowerCase().contains('win')) return 'Win';
    if (mode.toLowerCase().contains('blind')) return 'Blind';
    return 'Seen';
  }

  Widget _playerAvatar(MarriagePlayerHistory player, bool isSmallScreen) {
    final double size = isSmallScreen ? 30 : 36;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade300.withOpacity(0.8), width: 1.5),
      ),
      child: ClipOval(child: _buildProfileImage(player, size)),
    );
  }

  Widget _buildProfileImage(MarriagePlayerHistory player, double size) {
    if (player.userImage != null && player.userImage!.isNotEmpty) {
      if (player.userImage!.startsWith('http')) {
        return Image.network(
          player.userImage!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => _defaultProfileIcon(size: size * 0.6),
        );
      } else {
        try {
          final file = File(player.userImage!);
          if (file.existsSync()) {
            return Image.file(
              file,
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (context, error, stackTrace) => _defaultProfileIcon(size: size * 0.6),
            );
          } else {
            return _defaultProfileIcon(size: size * 0.6);
          }
        } catch (e) {
          return _defaultProfileIcon(size: size * 0.6);
        }
      }
    } else {
      return _defaultProfileIcon(size: size * 0.6);
    }
  }

  Widget _defaultProfileIcon({double size = 22}) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade100),
      child: Icon(Icons.person_rounded, size: size, color: Colors.blue.shade600),
    );
  }

  Widget _buildVerticalDivider({double height = 18, double margin = 8}) {
    return Container(
      height: height,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: margin),
      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(0.5)),
    );
  }

  double _calculateNetPointsForHistory(MarriagePlayerHistory player, List<MarriagePlayerHistory> allPlayers) {
    final bool isWinner = player.mode.toLowerCase().contains('win');

    if (isWinner) {
      return player.pointsEarned + (player.isDoublee ? 5.0 : 3.0);
    } else {
      return -player.pointsEarned;
    }
  }

  // Common Game Header
  Widget _buildGameHeader(DateTime timestamp, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1.0),
            boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 6, spreadRadius: 0.5, offset: const Offset(0, 2))],
            gradient: const LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${timestamp.year}',
                style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.purple.shade700),
              ),
              Container(
                height: 10,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.4), borderRadius: BorderRadius.circular(1)),
              ),
              Text(
                '${timestamp.month}',
                style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.purple.shade700),
              ),
              Container(
                height: 10,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.4), borderRadius: BorderRadius.circular(1)),
              ),
              Text(
                '${timestamp.day}',
                style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.purple.shade700),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1.0),
            boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.15), blurRadius: 6, spreadRadius: 0.5, offset: const Offset(0, 2))],
            gradient: const LinearGradient(colors: [Color(0xFFF3E5F5), Color(0xFFE3F2FD)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.watch_later_rounded, size: isSmallScreen ? 10 : 11, color: Colors.purple.shade700),
              const SizedBox(width: 3),
              Text(
                '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 9, fontWeight: FontWeight.w700, color: Colors.purple.shade800),
              ),
            ],
          ),
        ),
      ],
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
  // UPDATED: Build Player Avatar with Win Badge
  Widget _buildPlayerAvatar(String playerName, {bool showWinBadge = false}) {
    final userBox = Hive.box<User>('usersBox');
    final user = userBox.values.firstWhere((user) => user.username == playerName, orElse: () => User(username: playerName));

    Widget avatarWidget;

    if (user.profileImagePath != null && user.profileImagePath!.isNotEmpty) {
      avatarWidget = ClipOval(
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
      avatarWidget = _buildFallbackAvatar(playerName);
    }

    // Add win badge if player won
    if (showWinBadge) {
      return Stack(
        children: [
          avatarWidget,
          Positioned(
            top: -1,
            right: -1,
            child: Container(
              width: 14, // Reduced from 16
              height: 14, // Reduced from 16
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade500.withOpacity(0.8),
                    blurRadius: 5, // Slightly reduced blur
                    spreadRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.star_rounded,
                  size: 7, // Reduced from 8
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return avatarWidget;
  }

  // Fallback avatar when no profile image is available
  Widget _buildFallbackAvatar(String playerName) {
    return Container(
      decoration: const BoxDecoration(
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

  // UPDATED: Get top Call Break players based on matches won
  List<String> _getTopCallBreakPlayers() {
    final allGames = HistoryRepository.getAllCallBreakGames();
    if (allGames.isEmpty) return HistoryRepository.getAllPlayers().take(3).toList();

    // Count wins for each player
    final winCounts = <String, int>{};

    for (final game in allGames) {
      // FIX: Explicitly map all scores to double to handle old data
      final List<double> scores = game.totalScores.map((score) => score.toDouble()).toList();

      // Find the winner (player with highest score)
      double maxScore = scores.reduce((a, b) => a > b ? a : b);
      for (int i = 0; i < game.playerNames.length; i++) {
        if (scores[i] == maxScore) {
          final playerName = game.playerNames[i];
          winCounts[playerName] = (winCounts[playerName] ?? 0) + 1;
        }
      }
    }

    // Sort players by win count (descending)
    final sortedPlayers = winCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Take top 3 or fill with available players
    final topPlayers = sortedPlayers.take(3).map((entry) => entry.key).toList();

    // If we have less than 3 players, fill with other players who have played
    if (topPlayers.length < 3) {
      final allPlayers = HistoryRepository.getAllPlayers();
      for (final player in allPlayers) {
        if (!topPlayers.contains(player) && topPlayers.length < 3) {
          topPlayers.add(player);
        }
      }
    }

    return topPlayers;
  }

  // UPDATED: Get top Marriage players based on total points earned
  List<String> _getTopMarriagePlayers() {
    final allGames = HistoryRepository.getAllMarriageGames();
    if (allGames.isEmpty) return HistoryRepository.getAllPlayers().take(3).toList();

    // Calculate total points earned for each player
    final totalPoints = <String, double>{};

    for (final game in allGames) {
      for (final player in game.players) {
        final playerName = player.userName;
        totalPoints[playerName] = (totalPoints[playerName] ?? 0) + player.pointsEarned;
      }
    }

    // Sort players by total points (descending)
    final sortedPlayers = totalPoints.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Take top 3 or fill with available players
    final topPlayers = sortedPlayers.take(3).map((entry) => entry.key).toList();

    // If we have less than 3 players, fill with other players who have played
    if (topPlayers.length < 3) {
      final allPlayers = HistoryRepository.getAllPlayers();
      for (final player in allPlayers) {
        if (!topPlayers.contains(player) && topPlayers.length < 3) {
          topPlayers.add(player);
        }
      }
    }

    return topPlayers;
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

  int _getCallBreakPlayerRank(CallBreakGameHistory game, int playerIndex) {
    final List<double> scores = game.totalScores.map((score) => score.toDouble()).toList();
    List<Map<String, dynamic>> playersWithPoints = [];

    for (int i = 0; i < game.playerNames.length; i++) {
      playersWithPoints.add({'index': i, 'points': scores[i]});
    }

    playersWithPoints.sort((a, b) => b['points'].compareTo(a['points']));

    for (int i = 0; i < playersWithPoints.length; i++) {
      if (playersWithPoints[i]['index'] == playerIndex) {
        return i;
      }
    }
    return playersWithPoints.length - 1;
  }

  int _getMarriagePlayerRank(MarriageGameHistory game, int playerIndex) {
    List<Map<String, dynamic>> playersWithPoints = [];

    for (int i = 0; i < game.players.length; i++) {
      playersWithPoints.add({'index': i, 'points': game.players[i].pointsEarned});
    }

    playersWithPoints.sort((a, b) => b['points'].compareTo(a['points']));

    for (int i = 0; i < playersWithPoints.length; i++) {
      if (playersWithPoints[i]['index'] == playerIndex) {
        return i;
      }
    }
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
