// lib/controllers/user_list_controller.dart

import 'package:calculators/model/user_model.dart';
import 'package:calculators/repositories/history_repository.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../model/game_history_models.dart';
import '../model/marriage_game_history.dart';

/// Controller for managing user statistics and leaderboard data
class UserListController extends GetxController {
  var isLoading = false.obs;
  var userStats = <String, UserStats>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAllUsersStats();
  }

  /// Loads statistics for all users from the database
  Future<void> _loadAllUsersStats() async {
    isLoading.value = true;
    try {
      final userBox = Hive.box<User>('usersBox');
      final users = userBox.values.toList();

      // Load stats for all users
      for (final user in users) {
        await _loadUserStats(user.username);
      }
    } catch (e) {
      // Error handled silently in production
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads statistics for a specific user
  Future<void> _loadUserStats(String username) async {
    try {
      // Get marriage stats
      final marriageGames = HistoryRepository.getAllMarriageGames();
      final marriageWins = _calculateMarriageWins(marriageGames, username);

      // Get callbreak stats
      final callbreakGames = HistoryRepository.getAllCallBreakGames();
      final callbreakWins = _calculateCallbreakWins(callbreakGames, username);

      final totalWins = marriageWins + callbreakWins;
      final level = _calculateLevel(totalWins);

      userStats[username] = UserStats(totalWins: totalWins, level: level, marriageWins: marriageWins, callbreakWins: callbreakWins);
    } catch (e) {
      // Set default stats on error
      userStats[username] = UserStats(totalWins: 0, level: 1, marriageWins: 0, callbreakWins: 0);
    }
  }

  /// Calculates number of Marriage game wins for a user
  int _calculateMarriageWins(List<dynamic> marriageGames, String username) {
    int wins = 0;
    for (final game in marriageGames) {
      if (game is MarriageGameHistory) {
        final player = game.players.firstWhere(
          (p) => p.userName == username,
          orElse: () => MarriagePlayerHistory(userId: '', userName: '', maalPoints: 0, isSequence: false, isDoublee: false, pointsEarned: 0, currentScore: 0, mode: '', netPointsChange: 0.0, netAmountChange: 0.0),
        );
        if (player.userName == username && player.mode.toLowerCase() == 'win') {
          wins++;
        }
      }
    }
    return wins;
  }

  /// Calculates number of Call Break game wins for a user
  int _calculateCallbreakWins(List<dynamic> callbreakGames, String username) {
    int wins = 0;
    for (final game in callbreakGames) {
      if (game is CallBreakGameHistory) {
        final playerIndex = game.playerNames.indexWhere((name) => name == username);
        if (playerIndex != -1 && playerIndex < game.totalScores.length) {
          final playerScore = game.totalScores[playerIndex];
          final sortedScores = List<double>.from(game.totalScores)..sort((a, b) => b.compareTo(a));
          final position = sortedScores.indexOf(playerScore) + 1;
          if (position == 1) wins++;
        }
      }
    }
    return wins;
  }

  /// Calculates user level based on total wins
  /// Level progression: 0-9 wins = Level 1, 10-19 = Level 2, 20-29 = Level 3, etc.
  int _calculateLevel(int totalWins) {
    return (totalWins ~/ 10) + 1;
  }

  /// Gets total number of matches played across all users
  int getTotalMatches() {
    final marriageGames = HistoryRepository.getAllMarriageGames().length;
    final callbreakGames = HistoryRepository.getAllCallBreakGames().length;
    return marriageGames + callbreakGames;
  }

  /// Gets the highest level achieved among all users
  int getHighestLevel() {
    if (userStats.isEmpty) return 0;
    return userStats.values.map((stats) => stats.level).reduce((a, b) => a > b ? a : b);
  }

  /// Refreshes all user statistics
  Future<void> refreshStats() async {
    await _loadAllUsersStats();
  }
}

/// Represents user statistics for display in leaderboard
class UserStats {
  final int totalWins;
  final int level;
  final int marriageWins;
  final int callbreakWins;

  UserStats({required this.totalWins, required this.level, required this.marriageWins, required this.callbreakWins});
}
