import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  var gameCompleted = false.obs; // ADD THIS LINE

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
        gameCompleted.value = savedGame['gameCompleted'] ?? false; // ADD THIS LINE
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
    }
  }

  void saveGame() {
    try {
      final callBreakBox = Hive.box('callBreakGames');
      callBreakBox.put('currentGame', {
        'players': selectedPlayers,
        'rounds': rounds.map((round) => round.toJson()).toList(),
        'currentRound': currentRound.value,
        'gameStarted': gameStarted.value,
        'gameCompleted': gameCompleted.value, // ADD THIS LINE
      });
    } catch (e) {
      debugPrint('Error saving game: $e');
    }
  }

  void saveGameHistory() {
    try {
      // Only save history if game was actually played (has rounds)
      if (rounds.isNotEmpty && selectedPlayers.isNotEmpty) {
        // Calculate total scores for each player
        List<int> totalScores = List.generate(selectedPlayers.length, (index) {
          return getTotalPoints(index).round();
        });

        // PRINT EACH ROUND'S DATA
        debugPrint('📋 ROUND-BY-ROUND DATA:');
        for (int i = 0; i < rounds.length; i++) {
          final round = rounds[i];
          debugPrint('🎯 Round ${round.roundNumber}:');
          debugPrint('   Bids: ${round.bids}');
          debugPrint('   Extras: ${round.extras}');
          debugPrint('   Points: ${round.points}');

          // Calculate and print bid success for each player
          for (int playerIndex = 0; playerIndex < round.bids.length; playerIndex++) {
            final bid = round.bids[playerIndex];
            final extra = round.extras[playerIndex];
            final totalTricks = bid + extra;
            final bidSuccess = totalTricks >= bid;
            final playerName = selectedPlayers[playerIndex].username;

            debugPrint('   ${playerName}: Bid=$bid, OT=$extra, Total=$totalTricks, Success=$bidSuccess');
          }
          debugPrint(''); // Empty line for separation
        }

        // Save the game history WITH ROUND DATA
        HistoryRepository.saveCompletedGame(playerNames: selectedPlayers.map((player) => player.username).toList(), totalScores: totalScores, totalRounds: rounds.length, gameTag: tag, rounds: rounds);

        debugPrint('✅ Game history saved successfully for $tag');
        debugPrint('📊 Players: ${selectedPlayers.map((p) => p.username).toList()}');
        debugPrint('🎯 Final Scores: $totalScores');
        debugPrint('🔄 Total Rounds played: ${rounds.length}');
        debugPrint('📝 Round details saved: ${rounds.length} rounds with complete data');
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
    gameCompleted.value = false; // ADD THIS LINE
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
        saveGameHistory(); // Save history when game completes
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

  void resetGame() {
    // Save history only if game was completed OR had rounds played
    if (gameCompleted.value || rounds.isNotEmpty) {
      saveGameHistory();
    }

    // Reset everything
    selectedPlayers.clear();
    rounds.clear();
    currentRound.value = 1;
    gameStarted.value = false;
    gameCompleted.value = false; // Reset completion status
    resetCurrentRound();
    saveGame();
  }

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

  // Temporary test method (you can remove later)
  void testHistorySave() {
    saveGameHistory();
    Get.snackbar('History Test', 'Game history saved for testing!', backgroundColor: Colors.green, colorText: Colors.white);
  }
}
