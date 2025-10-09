import 'package:hive_flutter/hive_flutter.dart';

import '../model/game_history_models.dart';
import '../model/marriage_game_history.dart';
import '../model/round_data.dart';

// NOTE: Ensure your adapter files (.g.dart) are correctly generated and imported
// if you are using auto-generated adapters and the models are in separate files.

class HistoryRepository {
  static late Box<CallBreakGameHistory> callBreakGameHistoryBox;
  static late Box<MarriageGameHistory> marriageGameHistoryBox;
  static late Box<PlayerOverallStats> playerStatsBox;

  static Future<void> init() async {
    // Standard initialization on the Main Thread (assumes Hive.initFlutter was called in main)
    callBreakGameHistoryBox = await Hive.openBox<CallBreakGameHistory>('callBreakGameHistory');
    marriageGameHistoryBox = await Hive.openBox<MarriageGameHistory>('marriageGameHistory');
    playerStatsBox = await Hive.openBox<PlayerOverallStats>('playerStats');
  }

  // 🛑 FINAL FIX: Initialize for the Isolate and Register Adapters
  static Future<void> initializeIsolate(String hivePath) async {
    // 1. Initialize Hive with the path.
    Hive.init(hivePath);

    // 2. REGISTER ALL ADAPTERS HERE.
    // This resolves the "unknown typeId" HiveError (Error 33).
    // Ensure all model adapters corresponding to the stored data are registered.
    // If typeId 33 is associated with a specific model, make sure its adapter is here.
    Hive.registerAdapter(CallBreakGameHistoryAdapter());
    Hive.registerAdapter(RoundHistoryDataAdapter()); // Nested in CallBreak

    Hive.registerAdapter(MarriageGameHistoryAdapter());
    Hive.registerAdapter(MarriagePlayerHistoryAdapter()); // Nested in MarriageGame

    Hive.registerAdapter(PlayerOverallStatsAdapter());

    // 3. Open or get the boxes
    if (!Hive.isBoxOpen('callBreakGameHistory')) {
      callBreakGameHistoryBox = await Hive.openBox<CallBreakGameHistory>('callBreakGameHistory');
    } else {
      callBreakGameHistoryBox = Hive.box<CallBreakGameHistory>('callBreakGameHistory');
    }

    if (!Hive.isBoxOpen('marriageGameHistory')) {
      marriageGameHistoryBox = await Hive.openBox<MarriageGameHistory>('marriageGameHistory');
    } else {
      marriageGameHistoryBox = Hive.box<MarriageGameHistory>('marriageGameHistory');
    }

    if (!Hive.isBoxOpen('playerStats')) {
      playerStatsBox = await Hive.openBox<PlayerOverallStats>('playerStats');
    } else {
      playerStatsBox = Hive.box<PlayerOverallStats>('playerStats');
    }
  }

  // ========== MARRIAGE GAME METHODS ========== //
  // ... (All other methods remain unchanged)
  static Future<void> saveMarriageGame({required String id, required DateTime playedAt, required int numberOfPlayers, required double pointsPerRupee, required double totalMaalPoints, required List<MarriagePlayerHistory> players}) async {
    final marriageGameHistory = MarriageGameHistory(id: id, playedAt: playedAt, numberOfPlayers: numberOfPlayers, pointsPerRupee: pointsPerRupee, totalMaalPoints: totalMaalPoints, players: players, gameType: "marriage");

    await marriageGameHistoryBox.put(id, marriageGameHistory);

    for (final player in players) {
      await _updatePlayerStatsForMarriage(player.userName, player.pointsEarned);
    }
  }

  static Future<void> _updatePlayerStatsForMarriage(String playerName, double pointsEarned) async {
    var stats = playerStatsBox.get(playerName) ?? PlayerOverallStats(playerName: playerName, lastPlayed: DateTime.now());

    stats.totalMatchesPlayed++;
    stats.lastPlayed = DateTime.now();
    stats.updateLevel();

    await playerStatsBox.put(playerName, stats);
  }

  static List<MarriageGameHistory> getAllMarriageGames() {
    final allGames = marriageGameHistoryBox.values.toList();
    allGames.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return allGames;
  }

  static List<MarriageGameHistory> getTodaysMarriageGames() {
    final today = DateTime.now();
    final allGames = marriageGameHistoryBox.values.toList();

    return allGames.where((game) => game.playedAt.year == today.year && game.playedAt.month == today.month && game.playedAt.day == today.day).toList();
  }

  // ========== CALL BREAK METHODS (UNCHANGED) ========== //

  static Future<void> saveCompletedGame({required List<String> playerNames, required List<double> totalScores, required int totalRounds, required String gameTag, required List<RoundData> rounds}) async {
    final gameId = DateTime.now().millisecondsSinceEpoch.toString();

    final roundDetails = rounds.map((round) {
      List<bool> bidSuccess = [];
      for (int i = 0; i < round.bids.length; i++) {
        final totalTricks = round.bids[i] + round.extras[i];
        bidSuccess.add(totalTricks >= round.bids[i]);
      }

      return RoundHistoryData(roundNumber: round.roundNumber, bids: round.bids, extras: round.extras, points: round.points, bidSuccess: bidSuccess);
    }).toList();

    final gameHistory = CallBreakGameHistory(gameId: gameId, timestamp: DateTime.now(), playerNames: playerNames, totalScores: totalScores, totalRounds: totalRounds, gameTag: gameTag, roundDetails: roundDetails);

    await callBreakGameHistoryBox.put(gameId, gameHistory);

    for (int i = 0; i < playerNames.length; i++) {
      await _updatePlayerStats(playerNames[i], totalScores[i].round(), _isWinner(totalScores, i), _calculatePosition(totalScores, i));
    }
  }

  static int _calculatePosition(List<double> totalScores, int playerIndex) {
    final playerScore = totalScores[playerIndex];
    final sortedScores = List<double>.from(totalScores)..sort((a, b) => b.compareTo(a));
    return sortedScores.indexOf(playerScore) + 1;
  }

  static bool _isWinner(List<double> totalScores, int playerIndex) {
    final playerScore = totalScores[playerIndex];
    final maxScore = totalScores.reduce((a, b) => a > b ? a : b);
    return playerScore == maxScore;
  }

  static Future<void> _updatePlayerStats(String playerName, int score, bool isWinner, int position) async {
    var stats = playerStatsBox.get(playerName) ?? PlayerOverallStats(playerName: playerName, lastPlayed: DateTime.now());

    stats.totalMatchesPlayed++;
    if (isWinner) {
      stats.totalWins++;
    }

    stats.lastPlayed = DateTime.now();
    stats.updateLevel();

    await playerStatsBox.put(playerName, stats);
  }

  static List<CallBreakGameHistory> getTodaysGames() {
    final today = DateTime.now();
    final allGames = callBreakGameHistoryBox.values.toList();

    return allGames.where((game) => game.timestamp.year == today.year && game.timestamp.month == today.month && game.timestamp.day == today.day).toList();
  }

  static List<CallBreakGameHistory> getGamesByPlayer(String playerName) {
    final allGames = callBreakGameHistoryBox.values.toList();
    return allGames.where((game) => game.playerNames.contains(playerName)).toList();
  }

  static PlayerOverallStats? getPlayerStats(String playerName) {
    return playerStatsBox.get(playerName);
  }

  static List<String> getAllPlayers() {
    return playerStatsBox.keys.cast<String>().toList();
  }

  static List<CallBreakGameHistory> getAllCallBreakGames() {
    return callBreakGameHistoryBox.values.toList();
  }

  static Future<void> clearAllHistory() async {
    await callBreakGameHistoryBox.clear();
    await marriageGameHistoryBox.clear();
    await playerStatsBox.clear();
  }
}
