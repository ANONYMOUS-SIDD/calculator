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

            // Small gap below app bar
            // const SizedBox(height: 8),
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

                    const SizedBox(height: 16),

                    // FIX 2: Add the ResultsTable here so it is part of the screen layout
                    const ResultsTable(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Actions - Wrapped in Obx to show only when players are selected.
            Obx(
              () => playerController.players.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.15), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, -6))],
                        gradient: LinearGradient(colors: [Colors.white, Colors.purple.shade50], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      ),
                      child: Row(
                        children: [
                          // NEW GAME Button - Pink & Purple Gradient
                          Expanded(
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                boxShadow: [BoxShadow(color: const Color(0xFFEC4899).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _newGame,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
                                      const SizedBox(width: 5),
                                      Text(
                                        'NEW GAME',
                                        style: GoogleFonts.quicksand(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.white, letterSpacing: 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // CALCULATE Button - Cyan & Blue Gradient
                          Expanded(
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0095FF), Color(0xFF0066FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 5))],
                                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _calculateGame,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.rocket_launch_rounded, size: 16, color: Colors.white),
                                      const SizedBox(width: 5),
                                      Text(
                                        'CALCULATE',
                                        style: GoogleFonts.quicksand(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.white, letterSpacing: 0.5),
                                      ),
                                    ],
                                  ),
                                ),
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
