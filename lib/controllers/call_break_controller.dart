import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/round_data.dart';
import '../model/user_model.dart';
import '../repositories/history_repository.dart';

class CallBreakController extends GetxController {
  final String tag;
  CallBreakController(this.tag);

  var selectedPlayers = <User>[].obs;
  var rounds = <RoundData>[].obs;
  var currentRound = 1.obs;
  var gameStarted = false.obs;
  var isLoading = true.obs;
  var bidPhase = false.obs;
  var otPhase = false.obs;
  var gameCompleted = false.obs;

  var currentBids = <int>[0, 0, 0, 0].obs;
  var currentExtras = <int>[0, 0, 0, 0].obs;
  var bidCompleted = <bool>[false, false, false, false].obs;
  var otCompleted = <bool>[false, false, false, false].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      if (!Hive.isBoxOpen('callBreakGames')) {
        await Hive.openBox('callBreakGames');
      }
      _loadSavedGame();
    } catch (e) {
      isLoading.value = false;
    }
  }

  void _loadSavedGame() {
    try {
      final callBreakBox = Hive.box('callBreakGames');
      final savedGame = callBreakBox.get('currentGame');

      if (savedGame != null) {
        selectedPlayers.value = List<User>.from(savedGame['players'] ?? []);
        rounds.value = List<RoundData>.from((savedGame['rounds'] as List).map((e) => RoundData.fromJson(e)) ?? []);
        currentRound.value = savedGame['currentRound'] ?? 1;
        gameStarted.value = savedGame['gameStarted'] ?? false;
        gameCompleted.value = savedGame['gameCompleted'] ?? false;
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
    }
  }

  void saveGame() {
    try {
      final callBreakBox = Hive.box('callBreakGames');
      callBreakBox.put('currentGame', {'players': selectedPlayers, 'rounds': rounds.map((round) => round.toJson()).toList(), 'currentRound': currentRound.value, 'gameStarted': gameStarted.value, 'gameCompleted': gameCompleted.value});
    } catch (e) {
      debugPrint('Error saving game: $e');
    }
  }

  void saveGameHistory() {
    try {
      // Only save history if game was actually played (has rounds)
      if (rounds.isNotEmpty && selectedPlayers.isNotEmpty) {
        // Calculate total scores for each player, preserving decimal precision
        List<double> totalScores = List.generate(selectedPlayers.length, (index) {
          return getTotalPoints(index).toDouble();
        });

        // Save the game history WITH ROUND DATA
        HistoryRepository.saveCompletedGame(
          playerNames: selectedPlayers.map((player) => player.username).toList(),
          totalScores: totalScores, // Now a List<double>
          totalRounds: rounds.length,
          gameTag: tag,
          rounds: rounds,
        );

        debugPrint('✅ Game history saved successfully for $tag');
      }
    } catch (e) {
      debugPrint('❌ Error saving game history: $e');
    }
  }

  void setPlayers(List<User> players) {
    selectedPlayers.value = players;
    gameStarted.value = true;
    rounds.clear();
    currentRound.value = 1;
    gameCompleted.value = false;
    resetCurrentRound();
    saveGame();
  }

  void resetCurrentRound() {
    currentBids.value = [0, 0, 0, 0];
    currentExtras.value = [0, 0, 0, 0];
    bidCompleted.value = [false, false, false, false];
    otCompleted.value = [false, false, false, false];
    bidPhase.value = false;
    otPhase.value = false;
  }

  void startRound() {
    bidPhase.value = true;
    otPhase.value = false;
    bidCompleted.value = [false, false, false, false];
    otCompleted.value = [false, false, false, false];
  }

  void finishBidPhase() {
    if (bidCompleted.every((completed) => completed)) {
      bidPhase.value = false;
      otPhase.value = true;
      otCompleted.value = [false, false, false, false];
    } else {
      Get.snackbar('Warning', 'All players must place their bids first', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    }
  }

  void finishRound() {
    if (otCompleted.every((completed) => completed)) {
      final points = List<double>.generate(4, (index) {
        final bid = currentBids[index];
        final extra = currentExtras[index];
        final totalTricks = bid + extra;

        if (totalTricks < bid) {
          return -bid.toDouble();
        } else {
          return bid + (extra * 0.1);
        }
      });

      final roundData = RoundData(roundNumber: currentRound.value, bids: List.from(currentBids), extras: List.from(currentExtras), points: points);

      rounds.add(roundData);

      // CHECK IF GAME IS COMPLETED (after 5 rounds)
      if (currentRound.value >= 5) {
        gameCompleted.value = true;
        // -------------------------------------------------------------------
        // REMOVED: saveGameHistory() is no longer called here.
        // It is only called when the user presses 'New Game'.
        // -------------------------------------------------------------------
      }

      currentRound.value++;
      resetCurrentRound();
      saveGame();
    } else {
      Get.snackbar('Warning', 'All players must complete their OT first', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    }
  }

  void setBid(int playerIndex, int bid) {
    currentBids[playerIndex] = bid;
    bidCompleted[playerIndex] = true;
  }

  void setExtra(int playerIndex, int extraTricks) {
    currentExtras[playerIndex] = extraTricks;
    otCompleted[playerIndex] = true;
  }

  // -------------------------------------------------------------------
  // REMOVED old resetGame() and replaced it with a dialog caller
  // -------------------------------------------------------------------
  void showNewGameOptions() {
    bool requiresConfirmation = rounds.isNotEmpty;

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
                if (requiresConfirmation)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Text(
                      "The current game progress will be saved before starting a new game.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13, // Slightly increased from 12
                        fontWeight: FontWeight.w500, // Made bolder (was w500)
                        color: Colors.red, // Darker for better readability
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(bottom: requiresConfirmation ? 15.0 : 10.0),
                  child: Text(
                    "Old Player to keep existing player and new player for fresh new start",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13, // Slightly increased from 12
                      fontWeight: FontWeight.w500, // Made bolder (was w500)
                      color: Colors.black87, // Darker for better readability
                    ),
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
                // 1. New Player Action (Left Button - Destructive)
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const RoundedRectangleBorder()),
                    onPressed: () {
                      Get.back();
                      resetGameFresh();
                    },
                    child: Text(
                      "New Player",
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w900, // Bolder (was w600)
                        fontSize: 16, // Larger (was 15)
                        color: Colors.red.shade700, // Better red shade
                      ),
                    ),
                  ),
                ),

                // Vertical Divider
                Container(height: 45, width: 0.8, color: Colors.black12),

                // 2. Old Player Action (Right Button)
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const RoundedRectangleBorder()),
                    onPressed: () {
                      if (rounds.isNotEmpty) saveGameHistory();
                      Get.back();
                      resetGameExisting();
                    },
                    child: Text(
                      "Old Player",
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w900, // Bolder (was w600)
                        fontSize: 16, // Larger (was 15)
                        color: Colors.blue.shade700, // Better blue shade
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

  // New Player option: Clears everything and starts from player selection
  void resetGameFresh() {
    debugPrint("ACTION: Starting FRESH game (New Player).");

    // Save history of the game that was just completed/reset (if any data exists)
    if (rounds.isNotEmpty) {
      saveGameHistory();
    }

    // 1. Reset all game variables, including players
    selectedPlayers.clear();
    rounds.clear();
    currentRound.value = 1;
    gameStarted.value = false; // Player selection screen should follow
    gameCompleted.value = false;
    resetCurrentRound();
    saveGame();

    // Optional: Navigate to Player Selection Screen
    // Get.toNamed('/playerSelection');
  }

  // Old Player option: Keeps existing players, resets scores, starts round 1
  void resetGameExisting() {
    debugPrint("ACTION: Starting game from Round 1 (Old Player).");

    // We rely on the dialog's 'Old Player' button to save the previous game history first.

    // 1. Keep selectedPlayers list intact.
    // 2. Reset game state
    rounds.clear(); // Clear scores/rounds for the new game
    currentRound.value = 1;
    gameStarted.value = true; // Still playing with the same players
    gameCompleted.value = false;
    resetCurrentRound();
    saveGame();

    // IMPORTANT: Log the new empty game state as the initial history entry
    // This is the history of the *new* game being started.
    // However, since history is only saved when rounds are NOT empty,
    // we simply rely on the logic that the NEXT time 'New Game' is pressed,
    // the current (about to be played) game history will be saved.
  }

  // -------------------------------------------------------------------
  // END OF NEW LOGIC
  // -------------------------------------------------------------------

  double getTotalPoints(int playerIndex) {
    return rounds.fold(0.0, (total, round) => total + round.points[playerIndex]);
  }

  String formatPoints(double points) {
    if (points < 0) {
      return points.toStringAsFixed(0);
    } else {
      return points.toStringAsFixed(1);
    }
  }

  void updateRound(int roundIndex, List<int> newBids, List<int> newExtras) {
    if (roundIndex >= 0 && roundIndex < rounds.length) {
      final points = List<double>.generate(4, (index) {
        final bid = newBids[index];
        final extra = newExtras[index];
        final totalTricks = bid + extra;

        if (totalTricks < bid) {
          return -bid.toDouble();
        } else {
          return bid + (extra * 0.1);
        }
      });

      rounds[roundIndex] = RoundData(roundNumber: rounds[roundIndex].roundNumber, bids: newBids, extras: newExtras, points: points);

      saveGame();
      update();
    }
  }

  void testHistorySave() {
    saveGameHistory();
    Get.snackbar('History Test', 'Game history saved for testing!', backgroundColor: Colors.green, colorText: Colors.white);
  }
}
