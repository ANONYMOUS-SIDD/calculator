import 'package:calculators/controllers/player_controller.dart';
import 'package:calculators/screens/player_cards_grid.dart';
import 'package:calculators/screens/results_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/user_model.dart';
import '../screens/user_app_bar.dart';
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
    playerController.resetGame();
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: Column(
          children: [
            const UserAppBar(title: "Marriage"),

            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Obx(() => playerController.players.isNotEmpty ? PlayerCardsGrid(onPointsChanged: playerController.updatePlayerScore, onDoubleeToggle: playerController.toggleDoublee) : const SizedBox.shrink()),

                    const SizedBox(height: 10),

                    const ResultsTable(),

                    const SizedBox(height: 5),

                    Obx(() => ModernGameSetup(selectedPlayers: playerController.selectedPlayerCount.value, pointsPerRupee: playerController.pointsPerRupee.value, selectedPlayersList: playerController.players, onPlayersChanged: _onPlayersChanged, onPointsChanged: _onPointsChanged, onPlayersConfirmed: _onPlayersConfirmed)),
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
