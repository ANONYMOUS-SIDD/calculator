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
      final points = List<int>.generate(4, (index) {
        final bid = currentBids[index];
        final extra = currentExtras[index];

        if (extra < bid) {
          return -bid;
        } else {
          return bid + (extra - bid);
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

  void setExtra(int playerIndex, int extra) {
    currentExtras[playerIndex] = extra;
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

  int getTotalPoints(int playerIndex) {
    return rounds.fold(0, (total, round) => total + round.points[playerIndex]);
  }
}
