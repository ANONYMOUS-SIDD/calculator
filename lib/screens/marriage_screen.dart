import 'package:calculators/controllers/player_controller.dart';
import 'package:calculators/screens/player_cards_grid.dart';
import 'package:calculators/screens/results_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../model/marriage_game_history.dart';
import '../model/user_model.dart';
import '../repositories/history_repository.dart';
import '../widgets/moder_app_bar.dart';
import 'modern_game_setup.dart';

/// Main screen for Marriage game with player setup and calculation
class MarriageScreen extends StatelessWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  MarriageScreen({super.key, required this.tag, required this.color, required this.iconData});

  final PlayerController playerController = Get.find<PlayerController>();

  /// Handles player confirmation from selection dialog
  void _onPlayersConfirmed(List<User> confirmedUsers) {
    playerController.updatePlayersFromUsers(confirmedUsers);
  }

  /// Updates player count and clears existing players
  void _onPlayersChanged(int newCount) {
    playerController.updatePlayerCount(newCount);
    playerController.players.clear();
  }

  /// Updates points per rupee value
  void _onPointsChanged(double value) {
    playerController.updatePointsPerRupee(value);
  }

  /// Triggers game calculation
  void _calculateGame() {
    playerController.calculateGame();
  }

  /// Initiates new game flow
  void _newGame() {
    _showNewGameConfirmationDialog();
  }

  /// Shows confirmation dialog for starting a new game
  void _showNewGameConfirmationDialog() {
    final bool hasGameInProgress = playerController.players.isNotEmpty;

    Get.defaultDialog(
      backgroundColor: Colors.white,
      radius: 14.0,
      title: "",
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Section
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 5.0, left: 15.0, right: 15.0),
            child: Text(
              "Start  New  Game",
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black),
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: hasGameInProgress ? 15.0 : 10.0),
                  child: Text(
                    "Do you want to start a new game",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Actions Section
      actions: [
        Column(
          children: [
            const Divider(color: Colors.black12, height: 1.0, thickness: 0.8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel Button
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const RoundedRectangleBorder()),
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.blue.shade700),
                    ),
                  ),
                ),

                // Vertical Divider
                Container(height: 45, width: 0.8, color: Colors.black12),

                // Confirm Button
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const RoundedRectangleBorder()),
                    onPressed: () {
                      Get.back();
                      _saveCurrentGameToHistory();
                      playerController.resetGame();
                    },
                    child: Text(
                      "Confirm",
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.red.shade700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Saves current game to history repository
  void _saveCurrentGameToHistory() {
    final List<CalculatedResult> calculatedResults = playerController.calculatedResults;

    // Skip saving if no calculation has been performed
    if (calculatedResults.isEmpty) {
      return;
    }

    /// Converts player mode enum to display string
    String _getModeString(dynamic mode) {
      final modeString = mode.toString().toLowerCase();
      if (modeString.endsWith('.blind')) return 'Blind';
      if (modeString.endsWith('.seen')) return 'Seen';
      if (modeString.endsWith('.win')) return 'Win';
      return modeString;
    }

    try {
      // Map calculated results to history format
      final List<MarriagePlayerHistory> playerHistories = calculatedResults.map((result) {
        final player = result.player;
        final double netAmount = result.netPoints * playerController.pointsPerRupee.value;

        return MarriagePlayerHistory(userId: player.userId, userName: player.userName, userImage: player.userImage, maalPoints: player.maalPoints, isSequence: player.isSequence, isDoublee: player.isDoublee, pointsEarned: player.pointsEarned, currentScore: player.currentScore, mode: _getModeString(player.mode), netPointsChange: result.netPoints, netAmountChange: netAmount);
      }).toList();

      // Calculate total maal points
      final totalMaalPoints = playerController.players.fold(0.0, (sum, player) => sum + player.maalPoints);

      // Save to history repository
      HistoryRepository.saveMarriageGame(id: DateTime.now().millisecondsSinceEpoch.toString(), playedAt: DateTime.now(), numberOfPlayers: playerController.players.length, pointsPerRupee: playerController.pointsPerRupee.value, totalMaalPoints: totalMaalPoints, players: playerHistories);
    } catch (e) {
      // Error handling without snackbar
    }
  }

  /// Builds empty state animation when no players are selected
  Widget _buildEmptyStateLottie() {
    return Column(
      children: [
        SizedBox(width: 200, height: 200, child: Lottie.asset('assets/lottie/intro3.json', fit: BoxFit.contain)),
        const SizedBox(height: 16),
        Text(
          "Setup to start game",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.grey[700]),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    final horizontalPadding = screenWidth < 400 ? 12.0 : 16.0;
    final buttonHeight = screenHeight < 700 ? 40.0 : 42.0;
    final buttonFontSize = screenWidth < 350 ? 11.0 : 13.0;
    final iconSize = screenWidth < 350 ? 16.0 : 18.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: ModernAppBar(title: "Marriage"),
      body: Column(
        children: [
          const SizedBox(height: 5),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Player cards grid (only when players exist)
                  Obx(() => playerController.players.isNotEmpty ? PlayerCardsGrid(onPointsChanged: playerController.updatePlayerScore, onDoubleeToggle: playerController.toggleDoublee) : const SizedBox.shrink()),
                  const SizedBox(height: 5),
                  const ResultsTable(),
                  const SizedBox(height: 20),

                  // Game setup section
                  Obx(() => ModernGameSetup(selectedPlayers: playerController.selectedPlayerCount.value, pointsPerRupee: playerController.pointsPerRupee.value, selectedPlayersList: playerController.players, onPlayersChanged: _onPlayersChanged, onPointsChanged: _onPointsChanged, onPlayersConfirmed: _onPlayersConfirmed)),

                  // Empty state animation
                  Obx(() => playerController.players.isEmpty ? _buildEmptyStateLottie() : const SizedBox.shrink()),
                ],
              ),
            ),
          ),

          // Bottom action buttons (only when players exist)
          Obx(
            () => playerController.players.isNotEmpty
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: screenHeight < 700 ? 8.0 : 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 25, spreadRadius: 1, offset: const Offset(0, -6))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: screenWidth < 350 ? 8.0 : 12.0, vertical: screenHeight < 700 ? 8.0 : 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(colors: [Colors.grey.shade50, Colors.grey.shade100], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 6))],
                          ),
                          child: _buildResponsiveButtons(buttonHeight, buttonFontSize, iconSize, screenWidth),
                        ),
                        SizedBox(height: screenHeight < 700 ? 4.0 : 6.0),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Builds responsive button layout based on screen width
  Widget _buildResponsiveButtons(double buttonHeight, double fontSize, double iconSize, double screenWidth) {
    // Vertical layout for very small screens
    if (screenWidth < 350) {
      return Column(children: [_buildNewGameButton(buttonHeight, fontSize, iconSize), const SizedBox(height: 10), _buildCalculateButton(buttonHeight, fontSize, iconSize)]);
    }

    // Horizontal layout for normal screens
    return Row(
      children: [
        Expanded(child: _buildNewGameButton(buttonHeight, fontSize, iconSize)),
        SizedBox(width: screenWidth < 400 ? 10.0 : 14.0),
        Expanded(child: _buildCalculateButton(buttonHeight, fontSize, iconSize)),
      ],
    );
  }

  /// Builds the new game button
  Widget _buildNewGameButton(double height, double fontSize, double iconSize) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [Colors.pinkAccent.shade200, Colors.pinkAccent.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _newGame,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh_rounded, size: iconSize, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                "NEW GAME",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: fontSize, color: Colors.white, letterSpacing: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the calculate button with enabled/disabled states
  Widget _buildCalculateButton(double height, double fontSize, double iconSize) {
    return Obx(() {
      final bool canCalculate = playerController.canCalculate;

      return Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: canCalculate ? const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0066FF)], begin: Alignment.topLeft, end: Alignment.bottomRight) : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: canCalculate ? [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))] : [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: canCalculate ? _calculateGame : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calculate_rounded, size: iconSize, color: canCalculate ? Colors.white : Colors.grey.shade200),
                const SizedBox(width: 6),
                Text(
                  "CALCULATE",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: fontSize, color: canCalculate ? Colors.white : Colors.grey.shade200, letterSpacing: 0.6),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
