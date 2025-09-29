import 'package:calculators/controllers/player_controller.dart';
import 'package:calculators/screens/player_cards_grid.dart';
import 'package:calculators/screens/results_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/user_model.dart';
import '../screens/user_app_bar.dart';
// Import the ResultsTable widget
import 'modern_game_setup.dart';

// MarriageScreen is a StatelessWidget that observes the PlayerController.
class MarriageScreen extends StatelessWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  MarriageScreen({super.key, required this.tag, required this.color, required this.iconData});

  // Instantiate and find the PlayerController
  final PlayerController playerController = Get.find<PlayerController>();

  // --- CONTROLLER INTERACTION METHODS ---

  // Called by ModernGameSetup when the user successfully selects a new list of players.
  void _onPlayersConfirmed(List<User> confirmedUsers) {
    playerController.updatePlayersFromUsers(confirmedUsers);
  }

  // Called by ModernGameSetup when the user changes the target player count (3, 4, 5, or 6).
  void _onPlayersChanged(int newCount) {
    // 1. Update the target count in the controller.
    playerController.updatePlayerCount(newCount);
    // 2. Clear the existing players, forcing the user to re-select for the new size.
    playerController.players.clear();
  }

  // Called by ModernGameSetup when the points per rupee value is updated.
  void _onPointsChanged(double value) {
    playerController.updatePointsPerRupee(value);
  }

  void _calculateGame() {
    // FIX 1: Now correctly calling the calculation logic in the PlayerController
    playerController.calculateGame();
  }

  void _newGame() {
    // Correctly implemented game reset logic
    playerController.resetGame();
  }

  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // The UI now entirely relies on the reactive state provided by the PlayerController.
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: Column(
          children: [
            const UserAppBar(title: "Marriage"),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Game Setup - Wrapped in Obx to listen for target count and points changes.
                    Obx(
                      () => ModernGameSetup(
                        // 1. Target count from controller
                        selectedPlayers: playerController.selectedPlayerCount.value,
                        // 2. Points value from controller
                        pointsPerRupee: playerController.pointsPerRupee.value,
                        // 3. Reactive list of actual players from controller
                        selectedPlayersList: playerController.players,

                        // 4. Map callbacks to controller methods
                        onPlayersChanged: _onPlayersChanged,
                        onPointsChanged: _onPointsChanged,
                        onPlayersConfirmed: _onPlayersConfirmed,
                      ),
                    ),

                    // Players Grid - Wrapped in Obx to show only when players list is populated.
                    Obx(
                      () => playerController.players.isNotEmpty
                          ? PlayerCardsGrid(
                              // Delegate state changes to the controller
                              onPointsChanged: playerController.updatePlayerScore,
                              onDoubleeToggle: playerController.toggleDoublee,

                              // PlayerCardsGrid must be updated to use Get.find() internally
                              // to get the players list, or the list must be passed as a prop
                              // if it's simpler. (Assuming it uses Get.find() or the list is implicit).
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 20),

                    // FIX 2: Add the ResultsTable here so it is part of the screen layout
                    const ResultsTable(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Actions - Wrapped in Obx to show only when players are selected.
            Obx(
              () => playerController.players.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _newGame,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: const BorderSide(color: Color(0xFF0066FF)),
                              ),
                              child: Text(
                                'NEW GAME',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF0066FF)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _calculateGame,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: const Color(0xFF0066FF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                              child: Text(
                                'CALCULATE',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                          ),
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
}
