import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/round_data.dart';
import '../model/user_model.dart';
import '../repositories/history_repository.dart';

/// Controller for managing Call Break card game logic and state
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

  /// Initializes game state and loads saved game if available
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

  /// Loads saved game state from local storage
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

  /// Saves current game state to local storage
  void saveGame() {
    try {
      final callBreakBox = Hive.box('callBreakGames');
      callBreakBox.put('currentGame', {'players': selectedPlayers, 'rounds': rounds.map((round) => round.toJson()).toList(), 'currentRound': currentRound.value, 'gameStarted': gameStarted.value, 'gameCompleted': gameCompleted.value});
    } catch (e) {
      // Error handled silently in production
    }
  }

  /// Saves completed game to history repository
  void saveGameHistory() {
    try {
      if (rounds.isNotEmpty && selectedPlayers.isNotEmpty) {
        List<double> totalScores = List.generate(selectedPlayers.length, (index) {
          return getTotalPoints(index).toDouble();
        });

        HistoryRepository.saveCompletedGame(playerNames: selectedPlayers.map((player) => player.username).toList(), totalScores: totalScores, totalRounds: rounds.length, gameTag: tag, rounds: rounds);
      }
    } catch (e) {
      // Error handled silently in production
    }
  }

  /// Sets players and starts a new game
  void setPlayers(List<User> players) {
    selectedPlayers.value = players;
    gameStarted.value = true;
    rounds.clear();
    currentRound.value = 1;
    gameCompleted.value = false;
    resetCurrentRound();
    saveGame();
  }

  /// Resets current round state
  void resetCurrentRound() {
    currentBids.value = [0, 0, 0, 0];
    currentExtras.value = [0, 0, 0, 0];
    bidCompleted.value = [false, false, false, false];
    otCompleted.value = [false, false, false, false];
    bidPhase.value = false;
    otPhase.value = false;
  }

  /// Starts a new round with bid phase
  void startRound() {
    bidPhase.value = true;
    otPhase.value = false;
    bidCompleted.value = [false, false, false, false];
    otCompleted.value = [false, false, false, false];
  }

  /// Finishes bid phase and starts OT phase if all bids are placed
  void finishBidPhase() {
    if (bidCompleted.every((completed) => completed)) {
      bidPhase.value = false;
      otPhase.value = true;
      otCompleted.value = [false, false, false, false];
    }
  }

  /// Finishes current round and calculates points
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

      if (currentRound.value >= 5) {
        gameCompleted.value = true;
      }

      currentRound.value++;
      resetCurrentRound();
      saveGame();
    }
  }

  /// Sets bid for a player
  void setBid(int playerIndex, int bid) {
    currentBids[playerIndex] = bid;
    bidCompleted[playerIndex] = true;
  }

  /// Sets extra tricks for a player
  void setExtra(int playerIndex, int extraTricks) {
    currentExtras[playerIndex] = extraTricks;
    otCompleted[playerIndex] = true;
  }

  /// Shows new game options dialog
  void showNewGameOptions() {
    bool requiresConfirmation = rounds.isNotEmpty;

    Get.defaultDialog(
      backgroundColor: Colors.white,
      radius: 14.0,
      title: "",
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 5.0, left: 15.0, right: 15.0),
            child: Text(
              "Start New Game",
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black),
            ),
          ),
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
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(bottom: requiresConfirmation ? 15.0 : 10.0),
                  child: Text(
                    "Old Player to keep existing player and new player for fresh new start",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Column(
          children: [
            const Divider(color: Colors.black12, height: 1.0, thickness: 0.8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const RoundedRectangleBorder()),
                    onPressed: () {
                      Get.back();
                      resetGameFresh();
                    },
                    child: Text(
                      "New Player",
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.red.shade700),
                    ),
                  ),
                ),
                Container(height: 45, width: 0.8, color: Colors.black12),
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
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.blue.shade700),
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

  /// Resets game with new players (fresh start)
  void resetGameFresh() {
    if (rounds.isNotEmpty) {
      saveGameHistory();
    }

    selectedPlayers.clear();
    rounds.clear();
    currentRound.value = 1;
    gameStarted.value = false;
    gameCompleted.value = false;
    resetCurrentRound();
    saveGame();
  }

  /// Resets game with existing players
  void resetGameExisting() {
    if (rounds.isNotEmpty) saveGameHistory();

    rounds.clear();
    currentRound.value = 1;
    gameStarted.value = true;
    gameCompleted.value = false;
    resetCurrentRound();
    saveGame();
  }

  /// Calculates total points for a player across all rounds
  double getTotalPoints(int playerIndex) {
    return rounds.fold(0.0, (total, round) => total + round.points[playerIndex]);
  }

  /// Formats points for display (removes decimal for negative values)
  String formatPoints(double points) {
    if (points < 0) {
      return points.toStringAsFixed(0);
    } else {
      return points.toStringAsFixed(1);
    }
  }

  /// Updates round data with new bids and extras
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
}
