import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../model/game_history_models.dart';
import '../model/marriage_game_history.dart';
import '../repositories/history_repository.dart';

// =========================================================================
// STATS MODELS
// =========================================================================

class MarriageStats {
  final int totalMatches;
  final int wins;
  final double totalAmountEarned; // Now represents Net Profit/Loss (Rupees)
  final double totalMarriagePoints; // Now represents Net Profit/Loss (Points)

  MarriageStats({required this.totalMatches, required this.wins, required this.totalAmountEarned, required this.totalMarriagePoints});

  double get winRate => totalMatches > 0 ? (wins / totalMatches) * 100 : 0.0;
}

class CallbreakStats {
  final int totalMatches;
  final int firstPlace;
  final int secondPlace;
  final int thirdPlace;
  final int fourthPlace;

  CallbreakStats({required this.totalMatches, required this.firstPlace, required this.secondPlace, required this.thirdPlace, required this.fourthPlace});
}

class StatsResult {
  final MarriageStats? marriageStats;
  final CallbreakStats? callbreakStats;
  StatsResult(this.marriageStats, this.callbreakStats);
}

// =========================================================================
// USER STATS CONTROLLER (MAIN THREAD)
// =========================================================================

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

  void setDateRange(DateTime start, DateTime end) {
    selectedDateRange.value = {'start': start, 'end': end};
    isToday.value = _isTodayRange(start, end);
    _loadStatisticsAsync();
  }

  void clearDateRange() {
    selectedDateRange.value = null;
    isToday.value = true;
    _loadTodaysStatistics();
  }

  void loadTodaysStatistics() {
    _loadTodaysStatistics();
  }

  void _loadTodaysStatistics() {
    isLoading.value = true;
    _loadStatisticsAsync(isTodayLoad: true);
  }

  void _loadStatisticsAsync({bool isTodayLoad = false}) async {
    print('📊 [Controller] Starting statistics load. isTodayLoad: $isTodayLoad');
    isLoading.value = true;
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final hivePath = appDocumentDir.path;

      final arguments = {'userName': userName, 'dateRange': selectedDateRange.value, 'isTodayLoad': isTodayLoad, 'hivePath': hivePath};

      final startTime = DateTime.now();

      final result = await compute(_loadAndCalculateStats, arguments);

      final duration = DateTime.now().difference(startTime);
      print('✅ [Controller] Isolate calculation finished in ${duration.inMilliseconds}ms');

      marriageStats.value = result.marriageStats;
      callbreakStats.value = result.callbreakStats;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error loading statistics: $e');
      marriageStats.value = null;
      callbreakStats.value = null;
    } finally {
      print('🎉 [Controller] Statistics assigned. Loading state removed.');
      isLoading.value = false;
    }
  }

  bool _isTodayRange(DateTime start, DateTime end) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return start.isAtSameMomentAs(todayStart) && end.isAtSameMomentAs(todayEnd);
  }
}

// =========================================================================
// TOP-LEVEL (OR STATIC) FUNCTIONS FOR ISOLATE EXECUTION
// =========================================================================

Future<StatsResult> _loadAndCalculateStats(Map<String, dynamic> arguments) async {
  final userName = arguments['userName'] as String;
  final dateRange = arguments['dateRange'] as Map<String, DateTime>?;
  final isTodayLoad = arguments['isTodayLoad'] as bool;
  final hivePath = arguments['hivePath'] as String;

  print('⚙️ [Isolate] Started background processing for user: $userName');
  final isolateStartTime = DateTime.now();

  try {
    await HistoryRepository.initializeIsolate(hivePath);
  } catch (e) {
    print('FATAL ISOLATE ERROR: Failed to initialize repository: $e');
    return StatsResult(null, null);
  }

  // --- Data Retrieval ---
  List<MarriageGameHistory> marriageGames;
  List<CallBreakGameHistory> callbreakGames;

  final retrievalStart = DateTime.now();

  if (isTodayLoad) {
    marriageGames = _getTodaysMarriageGamesIsolate(userName);
    callbreakGames = _getTodaysCallbreakGamesIsolate(userName);
  } else {
    marriageGames = _getFilteredMarriageGamesIsolate(userName, dateRange);
    callbreakGames = _getFilteredCallbreakGamesIsolate(userName, dateRange);
  }

  final retrievalDuration = DateTime.now().difference(retrievalStart);
  print('⚠️ [Isolate] Data Retrieval + Initial Filtering time: ${retrievalDuration.inMilliseconds}ms');
  print('   Marriage Games Fetched: ${marriageGames.length}');
  // Assuming CallBreakGameHistory is available in context
  // print('   Callbreak Games Fetched: ${callbreakGames.length}');

  // --- Data Calculation ---
  // --- Data Calculation ---
  final calculationStart = DateTime.now();
  final marriageStats = _calculateMarriageStatsIsolate(marriageGames, userName);
  final callbreakStats = _calculateCallbreakStatsIsolate(callbreakGames, userName); // ✅ FIXED: Actually calculate callbreak stats// Temporary placeholder
  final calculationDuration = DateTime.now().difference(calculationStart);
  print('📈 [Isolate] Final Calculation time: ${calculationDuration.inMilliseconds}ms');

  final totalDuration = DateTime.now().difference(isolateStartTime);
  print('✅ [Isolate] Total background processing time: ${totalDuration.inMilliseconds}ms');

  return StatsResult(marriageStats, callbreakStats);
}

// --- Helper Functions for Isolate ---

List<MarriageGameHistory> _getTodaysMarriageGamesIsolate(String userName) {
  return HistoryRepository.getTodaysMarriageGames().where((game) {
    return game.players.any((player) => player.userName == userName);
  }).toList();
}

// Assuming CallbreakGameHistory and its methods are defined elsewhere
List<CallBreakGameHistory> _getTodaysCallbreakGamesIsolate(String userName) {
  return HistoryRepository.getTodaysGames()
      .where((game) {
        // Assuming CallBreakGameHistory has a playerNames property
        if (game is CallBreakGameHistory) {
          return game.playerNames.contains(userName);
        }
        return false;
      })
      .cast<CallBreakGameHistory>()
      .toList();
}

List<MarriageGameHistory> _getFilteredMarriageGamesIsolate(String userName, Map<String, DateTime>? dateRange) {
  final allGames = HistoryRepository.getAllMarriageGames();
  return _filterGamesByDateRangeIsolate<MarriageGameHistory>(allGames, dateRange).where((game) {
    return game.players.any((player) => player.userName == userName);
  }).toList();
}

List<CallBreakGameHistory> _getFilteredCallbreakGamesIsolate(String userName, Map<String, DateTime>? dateRange) {
  final allGames = HistoryRepository.getAllCallBreakGames();
  return _filterGamesByDateRangeIsolate<CallBreakGameHistory>(allGames, dateRange)
      .where((game) {
        // Assuming CallBreakGameHistory has a playerNames property
        if (game is CallBreakGameHistory) {
          return game.playerNames.contains(userName);
        }
        return false;
      })
      .cast<CallBreakGameHistory>()
      .toList();
}

List<T> _filterGamesByDateRangeIsolate<T>(List<T> games, Map<String, DateTime>? selectedDateRange) {
  if (selectedDateRange == null) return games;

  final startDate = selectedDateRange['start']!;
  final endDate = selectedDateRange['end']!;

  return games.where((game) {
    DateTime gameDate;

    if (game is MarriageGameHistory) {
      gameDate = game.playedAt;
    } else if (game is CallBreakGameHistory) {
      gameDate = game.timestamp; // Assuming CallBreakGameHistory has a timestamp property
    } else {
      return false;
    }

    // Filter games that start after the start date (inclusive) and end before the end date (inclusive)
    return gameDate.isAfter(startDate.subtract(const Duration(milliseconds: 1))) && gameDate.isBefore(endDate.add(const Duration(milliseconds: 1)));
  }).toList();
}

// 🎯 CORRECTED LOGIC FOR MARRIAGE STATS (Uses net calculated fields)
// 🎯 CORRECTED LOGIC FOR MARRIAGE STATS (Uses net calculated fields)
MarriageStats _calculateMarriageStatsIsolate(List<MarriageGameHistory> games, String userName) {
  int totalMatches = 0;
  int wins = 0;
  double totalAmountEarned = 0.0; // Accumulates net amount change (P/L in Rupees)
  double totalMarriagePoints = 0.0; // Accumulates net points change (P/L in Points)

  for (final game in games) {
    // Find the player's history in the current game
    final player = game.players.firstWhere(
      (p) => p.userName == userName,
      // Fallback - must provide all required fields, including the new ones
      orElse: () => MarriagePlayerHistory(
        userId: '',
        userName: '',
        maalPoints: 0,
        isSequence: false,
        isDoublee: false,
        pointsEarned: 0,
        currentScore: 0,
        mode: '',
        netPointsChange: 0.0, // Important: provide default
        netAmountChange: 0.0, // Important: provide default
      ),
    );

    if (player.userName == userName) {
      // 1. Total Matches: Total marriage match played by the user.
      totalMatches++;

      // 2. Count Win Properly: ONLY count if the player's mode was explicitly 'Win'.
      if (player.mode.toLowerCase() == 'win') {
        wins++;
      }

      // 3. Update Total Amount: Sum the FINAL NET AMOUNT (gain or loss)
      // This correctly uses the pre-calculated, final net amount.
      totalAmountEarned += player.netAmountChange;

      // 4. Update Total Calculated Point: Sum the FINAL NET POINTS (gain or loss)
      // This correctly uses the pre-calculated, final net points.
      totalMarriagePoints += player.netPointsChange;
    }
  }

  // Final MarriageStats object displays the accumulated Net Profit/Loss
  return MarriageStats(totalMatches: totalMatches, wins: wins, totalAmountEarned: totalAmountEarned, totalMarriagePoints: totalMarriagePoints);
}

// 🛑 CONFIRMED LOGIC FOR CALLBREAK STATS
CallbreakStats _calculateCallbreakStatsIsolate(List<CallBreakGameHistory> games, String userName) {
  int totalMatches = 0;
  int firstPlace = 0;
  int secondPlace = 0;
  int thirdPlace = 0;
  int fourthPlace = 0;

  for (final game in games) {
    // Assuming CallBreakGameHistory has playerNames and totalScores
    final playerIndex = game.playerNames.indexWhere((name) => name == userName);

    if (playerIndex != -1 && playerIndex < game.totalScores.length) {
      // 1. Total Matches: Count every Callbreak game the user participated in.
      totalMatches++;

      final playerScore = game.totalScores[playerIndex];

      // Create a sorted list of scores in descending order
      final sortedScores = List<double>.from(game.totalScores)..sort((a, b) => b.compareTo(a));

      // Find the user's rank (1-based index in the sorted list)
      final position = sortedScores.indexOf(playerScore) + 1;

      // 2. Positions: Count the rank achieved (1st, 2nd, 3rd, 4th).
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
