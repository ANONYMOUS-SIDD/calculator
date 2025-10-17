import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../model/game_history_models.dart';
import '../model/marriage_game_history.dart';
import '../repositories/history_repository.dart';

// =========================================================================
// STATS MODELS
// =========================================================================

/// Statistics for Marriage game performance
class MarriageStats {
  final int totalMatches;
  final int wins;
  final double totalAmountEarned;
  final double totalMarriagePoints;

  MarriageStats({required this.totalMatches, required this.wins, required this.totalAmountEarned, required this.totalMarriagePoints});

  /// Calculates win rate percentage
  double get winRate => totalMatches > 0 ? (wins / totalMatches) * 100 : 0.0;
}

/// Statistics for Call Break game performance
class CallbreakStats {
  final int totalMatches;
  final int firstPlace;
  final int secondPlace;
  final int thirdPlace;
  final int fourthPlace;

  CallbreakStats({required this.totalMatches, required this.firstPlace, required this.secondPlace, required this.thirdPlace, required this.fourthPlace});
}

/// Container for both Marriage and Call Break statistics
class StatsResult {
  final MarriageStats? marriageStats;
  final CallbreakStats? callbreakStats;

  StatsResult(this.marriageStats, this.callbreakStats);
}

// =========================================================================
// USER STATS CONTROLLER (MAIN THREAD)
// =========================================================================

/// Controller for managing user statistics across both game types
class UserStatsController extends GetxController {
  final String userName;

  var selectedDateRange = Rx<Map<String, DateTime>?>(null);
  var marriageStats = Rx<MarriageStats?>(null);
  var callbreakStats = Rx<CallbreakStats?>(null);
  var isLoading = false.obs;
  var isToday = true.obs;

  UserStatsController(this.userName);

  @override
  void onInit() {
    super.onInit();
    _loadTodaysStatistics();
  }

  /// Sets date range for statistics filtering
  void setDateRange(DateTime start, DateTime end) {
    selectedDateRange.value = {'start': start, 'end': end};
    isToday.value = _isTodayRange(start, end);
    _loadStatisticsAsync();
  }

  /// Clears date range and loads today's statistics
  void clearDateRange() {
    selectedDateRange.value = null;
    isToday.value = true;
    _loadTodaysStatistics();
  }

  /// Reloads today's statistics
  void loadTodaysStatistics() {
    _loadTodaysStatistics();
  }

  /// Loads statistics for today
  void _loadTodaysStatistics() {
    isLoading.value = true;
    _loadStatisticsAsync(isTodayLoad: true);
  }

  /// Loads statistics asynchronously using compute for background processing
  void _loadStatisticsAsync({bool isTodayLoad = false}) async {
    isLoading.value = true;

    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final hivePath = appDocumentDir.path;

      final arguments = {'userName': userName, 'dateRange': selectedDateRange.value, 'isTodayLoad': isTodayLoad, 'hivePath': hivePath};

      final result = await compute(_loadAndCalculateStats, arguments);

      marriageStats.value = result.marriageStats;
      callbreakStats.value = result.callbreakStats;
    } catch (e) {
      marriageStats.value = null;
      callbreakStats.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Checks if the given date range represents today
  bool _isTodayRange(DateTime start, DateTime end) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return start.isAtSameMomentAs(todayStart) && end.isAtSameMomentAs(todayEnd);
  }
}

// =========================================================================
// TOP-LEVEL FUNCTIONS FOR ISOLATE EXECUTION
// =========================================================================

/// Top-level function for background statistics calculation
Future<StatsResult> _loadAndCalculateStats(Map<String, dynamic> arguments) async {
  final userName = arguments['userName'] as String;
  final dateRange = arguments['dateRange'] as Map<String, DateTime>?;
  final isTodayLoad = arguments['isTodayLoad'] as bool;
  final hivePath = arguments['hivePath'] as String;

  try {
    await HistoryRepository.initializeIsolate(hivePath);
  } catch (e) {
    return StatsResult(null, null);
  }

  // Data retrieval
  List<MarriageGameHistory> marriageGames;
  List<CallBreakGameHistory> callbreakGames;

  if (isTodayLoad) {
    marriageGames = _getTodaysMarriageGamesIsolate(userName);
    callbreakGames = _getTodaysCallbreakGamesIsolate(userName);
  } else {
    marriageGames = _getFilteredMarriageGamesIsolate(userName, dateRange);
    callbreakGames = _getFilteredCallbreakGamesIsolate(userName, dateRange);
  }

  // Data calculation
  final marriageStats = _calculateMarriageStatsIsolate(marriageGames, userName);
  final callbreakStats = _calculateCallbreakStatsIsolate(callbreakGames, userName);

  return StatsResult(marriageStats, callbreakStats);
}

// =========================================================================
// HELPER FUNCTIONS FOR ISOLATE
// =========================================================================

/// Gets today's Marriage games for a specific user
List<MarriageGameHistory> _getTodaysMarriageGamesIsolate(String userName) {
  return HistoryRepository.getTodaysMarriageGames().where((game) {
    return game.players.any((player) => player.userName == userName);
  }).toList();
}

/// Gets today's Call Break games for a specific user
List<CallBreakGameHistory> _getTodaysCallbreakGamesIsolate(String userName) {
  return HistoryRepository.getTodaysGames()
      .where((game) {
        if (game is CallBreakGameHistory) {
          return game.playerNames.contains(userName);
        }
        return false;
      })
      .cast<CallBreakGameHistory>()
      .toList();
}

/// Gets filtered Marriage games by date range for a specific user
List<MarriageGameHistory> _getFilteredMarriageGamesIsolate(String userName, Map<String, DateTime>? dateRange) {
  final allGames = HistoryRepository.getAllMarriageGames();
  return _filterGamesByDateRangeIsolate<MarriageGameHistory>(allGames, dateRange).where((game) {
    return game.players.any((player) => player.userName == userName);
  }).toList();
}

/// Gets filtered Call Break games by date range for a specific user
List<CallBreakGameHistory> _getFilteredCallbreakGamesIsolate(String userName, Map<String, DateTime>? dateRange) {
  final allGames = HistoryRepository.getAllCallBreakGames();
  return _filterGamesByDateRangeIsolate<CallBreakGameHistory>(allGames, dateRange)
      .where((game) {
        if (game is CallBreakGameHistory) {
          return game.playerNames.contains(userName);
        }
        return false;
      })
      .cast<CallBreakGameHistory>()
      .toList();
}

/// Filters games by date range for both game types
List<T> _filterGamesByDateRangeIsolate<T>(List<T> games, Map<String, DateTime>? selectedDateRange) {
  if (selectedDateRange == null) return games;

  final startDate = selectedDateRange['start']!;
  final endDate = selectedDateRange['end']!;

  return games.where((game) {
    DateTime gameDate;

    if (game is MarriageGameHistory) {
      gameDate = game.playedAt;
    } else if (game is CallBreakGameHistory) {
      gameDate = game.timestamp;
    } else {
      return false;
    }

    return gameDate.isAfter(startDate.subtract(const Duration(milliseconds: 1))) && gameDate.isBefore(endDate.add(const Duration(milliseconds: 1)));
  }).toList();
}

/// Calculates Marriage game statistics for a user
MarriageStats _calculateMarriageStatsIsolate(List<MarriageGameHistory> games, String userName) {
  int totalMatches = 0;
  int wins = 0;
  double totalAmountEarned = 0.0;
  double totalMarriagePoints = 0.0;

  for (final game in games) {
    final player = game.players.firstWhere(
      (p) => p.userName == userName,
      orElse: () => MarriagePlayerHistory(userId: '', userName: '', maalPoints: 0, isSequence: false, isDoublee: false, pointsEarned: 0, currentScore: 0, mode: '', netPointsChange: 0.0, netAmountChange: 0.0),
    );

    if (player.userName == userName) {
      totalMatches++;

      if (player.mode.toLowerCase() == 'win') {
        wins++;
      }

      totalAmountEarned += player.netAmountChange;
      totalMarriagePoints += player.netPointsChange;
    }
  }

  return MarriageStats(totalMatches: totalMatches, wins: wins, totalAmountEarned: totalAmountEarned, totalMarriagePoints: totalMarriagePoints);
}

/// Calculates Call Break game statistics for a user
CallbreakStats _calculateCallbreakStatsIsolate(List<CallBreakGameHistory> games, String userName) {
  int totalMatches = 0;
  int firstPlace = 0;
  int secondPlace = 0;
  int thirdPlace = 0;
  int fourthPlace = 0;

  for (final game in games) {
    final playerIndex = game.playerNames.indexWhere((name) => name == userName);

    if (playerIndex != -1 && playerIndex < game.totalScores.length) {
      totalMatches++;

      final playerScore = game.totalScores[playerIndex];
      final sortedScores = List<double>.from(game.totalScores)..sort((a, b) => b.compareTo(a));
      final position = sortedScores.indexOf(playerScore) + 1;

      switch (position) {
        case 1:
          firstPlace++;
          break;
        case 2:
          secondPlace++;
          break;
        case 3:
          thirdPlace++;
          break;
        case 4:
          fourthPlace++;
          break;
      }
    }
  }

  return CallbreakStats(totalMatches: totalMatches, firstPlace: firstPlace, secondPlace: secondPlace, thirdPlace: thirdPlace, fourthPlace: fourthPlace);
}
