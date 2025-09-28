import 'package:get/get.dart';

import '../model/marriage_game.dart';
import '../model/user_model.dart';

class PlayerController extends GetxController {
  // The list of players now starts empty (players.obs is initialized as an empty list).
  final RxList<MarriagePlayer> players = <MarriagePlayer>[].obs;

  static const int defaultPlayerCount = 4;

  // 1. Reactive state variables for Game Setup
  final RxInt selectedPlayerCount = defaultPlayerCount.obs;
  final RxDouble pointsPerRupee = 1.0.obs; // Default value is 1 Rupee per Point

  @override
  void onInit() {
    super.onInit();
    // Removed the logic that initialized default players (Player 1, 2, 3, 4).
    // The player list now starts empty, awaiting user selection.
  }

  // Removed _initializeDefaultPlayers() method.

  void initializePlayers(List<MarriagePlayer> initialPlayers) {
    players.assignAll(initialPlayers);
  }

  void updatePlayersFromUsers(List<User> newUsers) {
    final Map<String, MarriagePlayer> existingPlayersMap = {for (var player in players) player.userName: player};

    final List<MarriagePlayer> newMarriagePlayers = newUsers.map((user) {
      final String username = user.username;
      final oldPlayer = existingPlayersMap[username];

      final bool isDoubleeStatus = oldPlayer?.isDoublee ?? false;

      final int currentScore = oldPlayer?.currentScore ?? 0;
      final double pointsEarned = oldPlayer?.pointsEarned ?? 0.0;

      return MarriagePlayer(userId: username, userName: username, userImage: user.profileImagePath, isDoublee: isDoubleeStatus, currentScore: currentScore, pointsEarned: pointsEarned);
    }).toList();

    players.assignAll(newMarriagePlayers);
  }

  // --- Game Setup Management Methods ---

  void updatePlayerCount(int newCount) {
    if (newCount >= 3 && newCount <= 6) {
      // Assuming 3-6 is the valid range
      selectedPlayerCount.value = newCount;
    }
  }

  void updatePointsPerRupee(double value) {
    if (value > 0) {
      pointsPerRupee.value = value;
    }
  }

  void resetGame() {
    // Reset player scores and flags, but keep the current list of players.
    // This allows a new round/game without re-selecting participants.
    final List<MarriagePlayer> resetPlayers = players.map((player) {
      return player.copyWith(currentScore: 0, pointsEarned: 0.0, isDoublee: false);
    }).toList();

    players.assignAll(resetPlayers);
  }

  // Use String for userName/userId, which aligns with GetX best practices
  void updatePlayerScore(String userName, double newPoints) {
    final index = players.indexWhere((p) => p.userName == userName);
    if (index != -1) {
      // We update both pointsEarned (double) and currentScore (int) for a robust model.
      final updatedPlayer = players[index].copyWith(
        pointsEarned: newPoints,
        currentScore: newPoints.toInt(), // Assuming you want to keep currentScore as a rounded integer
      );
      players[index] = updatedPlayer;
    }
  }

  void toggleDoublee(String userName) {
    final index = players.indexWhere((p) => p.userName == userName);
    if (index != -1) {
      players[index] = players[index].copyWith(isDoublee: !players[index].isDoublee);
    }
  }
}
