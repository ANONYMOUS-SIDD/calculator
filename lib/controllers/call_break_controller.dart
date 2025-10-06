import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/round_data.dart';
import '../model/user_model.dart';

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

  var currentBids = <int>[0, 0, 0, 0].obs;
  var currentExtras = <int>[0, 0, 0, 0].obs; // This stores EXTRA tricks
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
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
    }
  }

  void saveGame() {
    try {
      final callBreakBox = Hive.box('callBreakGames');
      callBreakBox.put('currentGame', {'players': selectedPlayers, 'rounds': rounds.map((round) => round.toJson()).toList(), 'currentRound': currentRound.value, 'gameStarted': gameStarted.value});
    } catch (e) {
      print('Error saving game: $e');
    }
  }

  void setPlayers(List<User> players) {
    selectedPlayers.value = players;
    gameStarted.value = true;
    rounds.clear();
    currentRound.value = 1;
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
        final extra = currentExtras[index]; // This is EXTRA tricks

        // Calculate total tricks obtained
        final totalTricks = bid + extra;

        // Check if player failed to meet their bid
        if (totalTricks < bid) {
          // Failed bid: negative points equal to bid
          return -bid.toDouble();
        } else {
          // Successful bid: points = bid + extra
          // But we need to store it as decimal for proper display
          return bid + (extra * 0.1); // This makes 2.1, 2.2, 2.3 etc.
        }
      });

      final roundData = RoundData(roundNumber: currentRound.value, bids: List.from(currentBids), extras: List.from(currentExtras), points: points);

      rounds.add(roundData);
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
    selectedPlayers.clear();
    rounds.clear();
    currentRound.value = 1;
    gameStarted.value = false;
    resetCurrentRound();
    saveGame();
  }

  double getTotalPoints(int playerIndex) {
    return rounds.fold(0.0, (total, round) => total + round.points[playerIndex]);
  }

  // Helper method to format points for display
  String formatPoints(double points) {
    if (points < 0) {
      return points.toStringAsFixed(0); // Show negative as whole number
    } else {
      // Show positive with one decimal place
      return points.toStringAsFixed(1);
    }
  }

  // Add this method for editing rounds
  void updateRound(int roundIndex, List<int> newBids, List<int> newExtras) {
    if (roundIndex >= 0 && roundIndex < rounds.length) {
      // Recalculate points with new bids and extras
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

      // Update the round
      rounds[roundIndex] = RoundData(roundNumber: rounds[roundIndex].roundNumber, bids: newBids, extras: newExtras, points: points);

      saveGame();
      update();
    }
  }
}
