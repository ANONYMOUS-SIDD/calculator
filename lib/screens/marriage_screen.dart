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

class MarriageScreen extends StatelessWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  MarriageScreen({super.key, required this.tag, required this.color, required this.iconData});

  final PlayerController playerController = Get.find<PlayerController>();

  void _onPlayersConfirmed(List<User> confirmedUsers) {
    playerController.updatePlayersFromUsers(confirmedUsers);
  }

  void _onPlayersChanged(int newCount) {
    playerController.updatePlayerCount(newCount);
    playerController.players.clear();
  }

  void _onPointsChanged(double value) {
    playerController.updatePointsPerRupee(value);
  }

  void _calculateGame() {
    playerController.calculateGame();
  }

  void _newGame() {
    _showNewGameConfirmationDialog();
  }

  void _showNewGameConfirmationDialog() {
    // Check if there is data that might be lost (i.e., any players are set up)
    bool hasGameInProgress = playerController.players.isNotEmpty;

    Get.defaultDialog(
      // --- DIALOG STYLING ---
      backgroundColor: Colors.white,
      radius: 14.0,
      title: "",
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,

      // --- CUSTOM CONTENT SECTION ---
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Title (Top padding set for spacing)
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 5.0, left: 15.0, right: 15.0),
            child: Text(
              "Start New Game",
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black),
            ),
          ),

          // 2. Warning/Info Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: hasGameInProgress ? 15.0 : 10.0),
                  child: Text(
                    "Do you want to start a  new game?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // --- CUSTOM ACTIONS SECTION (Single Row with Divider) ---
      actions: [
        // Top Divider (separates content from actions)
        Column(
          children: [
            const Divider(color: Colors.black12, height: 1.0, thickness: 0.8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. Cancel Action (Left Button - Primary/Safe Action in this context)
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const RoundedRectangleBorder()),
                    onPressed: () {
                      Get.back(); // Simply close the dialog
                    },
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.blue, // Blue for the primary action
                      ),
                    ),
                  ),
                ),

                // Vertical Divider
                Container(height: 45, width: 0.8, color: Colors.black12),

                // 2. Confirm/Refresh Action (Right Button - Destructive/Confirms Reset)
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const RoundedRectangleBorder()),
                    onPressed: () {
                      Get.back();
                      // FIRST: Save the current game to history before resetting
                      _saveCurrentGameToHistory();
                      // THEN: Reset for new game
                      playerController.resetGame();
                    },
                    child: Text(
                      "Confirm",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.red.shade600, // Red for the action that causes data loss/reset
                      ),
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

  void _saveCurrentGameToHistory() {
    // 1. Check if the score calculation has been run.
    final bool calculationRun = playerController.players.any((player) => player.currentScore != 0.0);

    // Only save if there are players AND a calculation has been performed.
    if (playerController.players.isEmpty || !calculationRun) {
      print('INFO: Skipped saving history. Game not fully calculated.');
      return;
    }

    try {
      // Convert current players to MarriagePlayerHistory
      final List<MarriagePlayerHistory> playerHistories = playerController.players.map((player) {
        return MarriagePlayerHistory(userId: player.userId, userName: player.userName, userImage: player.userImage, maalPoints: player.maalPoints, isSequence: player.isSequence, isDoublee: player.isDoublee, pointsEarned: player.pointsEarned, currentScore: player.currentScore, mode: player.mode.toString());
      }).toList();

      // Calculate total maal points
      final totalMaalPoints = playerController.players.fold(0.0, (sum, player) => sum + player.maalPoints);

      // Save to history
      HistoryRepository.saveMarriageGame(id: DateTime.now().millisecondsSinceEpoch.toString(), playedAt: DateTime.now(), numberOfPlayers: playerController.players.length, pointsPerRupee: playerController.pointsPerRupee.value, totalMaalPoints: totalMaalPoints, players: playerHistories);

      // Show success message
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text('Game saved to history'), duration: Duration(seconds: 2), backgroundColor: Colors.green));

      print('✅ Marriage game saved to history');
    } catch (e) {
      print('❌ Error saving marriage game: $e');
      // Optional: Show error message
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text('Failed to save game history'), duration: Duration(seconds: 2), backgroundColor: Colors.red));
    }
  }

  // Widget to display Lottie animation when no players are selected
  Widget _buildEmptyStateLottie() {
    return Column(
      children: [
        SizedBox(width: 200, height: 200, child: Lottie.asset('assets/lottie/intro3.json', fit: BoxFit.contain)),
        const SizedBox(height: 16),
        Text(
          "Setup to start game",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.grey[700]),
        ),
        const SizedBox(height: 40), // Extra spacing at the bottom
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
                  Obx(() => playerController.players.isNotEmpty ? PlayerCardsGrid(onPointsChanged: playerController.updatePlayerScore, onDoubleeToggle: playerController.toggleDoublee) : const SizedBox.shrink()),
                  const SizedBox(height: 5),
                  const ResultsTable(),

                  const SizedBox(height: 20),

                  // FIX: Wrapping ModernGameSetup in Obx to ensure it rebuilds when
                  // playerController.selectedPlayerCount or playerController.pointsPerRupee changes.
                  Obx(() => ModernGameSetup(selectedPlayers: playerController.selectedPlayerCount.value, pointsPerRupee: playerController.pointsPerRupee.value, selectedPlayersList: playerController.players, onPlayersChanged: _onPlayersChanged, onPointsChanged: _onPointsChanged, onPlayersConfirmed: _onPlayersConfirmed)),

                  // Display Lottie animation when no players are selected
                  Obx(() => playerController.players.isEmpty ? _buildEmptyStateLottie() : const SizedBox.shrink()),
                ],
              ),
            ),
          ),

          // RESPONSIVE BOTTOM CONTAINER
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

  Widget _buildResponsiveButtons(double buttonHeight, double fontSize, double iconSize, double screenWidth) {
    // For very small screens, stack buttons vertically
    if (screenWidth < 350) {
      return Column(children: [_buildNewGameButton(buttonHeight, fontSize, iconSize), const SizedBox(height: 10), _buildCalculateButton(buttonHeight, fontSize, iconSize)]);
    }

    // For normal screens, use horizontal layout
    return Row(
      children: [
        Expanded(child: _buildNewGameButton(buttonHeight, fontSize, iconSize)),
        SizedBox(width: screenWidth < 400 ? 10.0 : 14.0),
        Expanded(child: _buildCalculateButton(buttonHeight, fontSize, iconSize)),
      ],
    );
  }

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
              SizedBox(width: 6),
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

  Widget _buildCalculateButton(double height, double fontSize, double iconSize) {
    return Obx(() {
      final canCalculate = playerController.canCalculate;

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
                SizedBox(width: 6),
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
