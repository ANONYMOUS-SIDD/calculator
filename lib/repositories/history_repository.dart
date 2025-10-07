import 'package:hive_flutter/hive_flutter.dart';

import '../model/game_history_models.dart';
import '../model/round_data.dart';

class HistoryRepository {
  static late Box<CallBreakGameHistory> gameHistoryBox;
  static late Box<PlayerOverallStats> playerStatsBox;

  static Future<void> init() async {
    gameHistoryBox = await Hive.openBox<CallBreakGameHistory>('callBreakGameHistory');
    playerStatsBox = await Hive.openBox<PlayerOverallStats>('playerStats');
  }

  // Calculate position based on scores (1st, 2nd, 3rd, etc.)
  // *** UPDATED: Now uses List<double> ***
  static int _calculatePosition(List<double> totalScores, int playerIndex) {
    final playerScore = totalScores[playerIndex];
    // Sort scores from highest to lowest (b.compareTo(a))
    final sortedScores = List<double>.from(totalScores)..sort((a, b) => b.compareTo(a));
    return sortedScores.indexOf(playerScore) + 1;
  }

  // Check if player is winner (has highest score)
  // *** UPDATED: Now uses List<double> ***
  static bool _isWinner(List<double> totalScores, int playerIndex) {
    final playerScore = totalScores[playerIndex];
    final maxScore = totalScores.reduce((a, b) => a > b ? a : b);
    return playerScore == maxScore;
  }

  // UPDATED: Save completed game with round details
  // *** UPDATED: totalScores parameter is now List<double> ***
  static Future<void> saveCompletedGame({required List<String> playerNames, required List<double> totalScores, required int totalRounds, required String gameTag, required List<RoundData> rounds}) async {
    final gameId = DateTime.now().millisecondsSinceEpoch.toString();

    // Convert RoundData to RoundHistoryData
    final roundDetails = rounds.map((round) {
      // Calculate bid success for each player
      List<bool> bidSuccess = [];
      for (int i = 0; i < round.bids.length; i++) {
        final totalTricks = round.bids[i] + round.extras[i];
        bidSuccess.add(totalTricks >= round.bids[i]);
      }

      return RoundHistoryData(roundNumber: round.roundNumber, bids: round.bids, extras: round.extras, points: round.points, bidSuccess: bidSuccess);
    }).toList();

    final gameHistory = CallBreakGameHistory(
      gameId: gameId,
      timestamp: DateTime.now(),
      playerNames: playerNames,
      totalScores: totalScores, // Now passing List<double>
      totalRounds: totalRounds,
      gameTag: gameTag,
      roundDetails: roundDetails,
    );

    // Save the game
    await gameHistoryBox.put(gameId, gameHistory);

    // Update all players' statistics
    // *** UPDATED: Passing double score to _updatePlayerStats (will be rounded there for stats) ***
    for (int i = 0; i < playerNames.length; i++) {
      // Use round() for stats storage to maintain consistency with previous logic
      await _updatePlayerStats(playerNames[i], totalScores[i].round(), _isWinner(totalScores, i), _calculatePosition(totalScores, i));
    }
  }

  // Update player statistics
  // NOTE: score parameter is kept as int to align with typical 'points' total for stats display,
  // but the decimal precision is saved in the CallBreakGameHistory object.
  static Future<void> _updatePlayerStats(String playerName, int score, bool isWinner, int position) async {
    var stats = playerStatsBox.get(playerName) ?? PlayerOverallStats(playerName: playerName, lastPlayed: DateTime.now());

    // Update stats
    stats.totalMatchesPlayed++;
    if (isWinner) {
      stats.totalWins++;
    }

    stats.lastPlayed = DateTime.now();
    stats.updateLevel();

    await playerStatsBox.put(playerName, stats);
  }

  // Get today's games
  static List<CallBreakGameHistory> getTodaysGames() {
    final today = DateTime.now();
    final allGames = gameHistoryBox.values.toList();

    return allGames.where((game) => game.timestamp.year == today.year && game.timestamp.month == today.month && game.timestamp.day == today.day).toList();
  }

  // Get games by specific player
  static List<CallBreakGameHistory> getGamesByPlayer(String playerName) {
    final allGames = gameHistoryBox.values.toList();

    return allGames.where((game) => game.playerNames.contains(playerName)).toList();
  }

  // Get player statistics
  static PlayerOverallStats? getPlayerStats(String playerName) {
    return playerStatsBox.get(playerName);
  }

  // Get all unique players who have played
  static List<String> getAllPlayers() {
    return playerStatsBox.keys.cast<String>().toList();
  }

  // Get all games (for debugging)
  static List<CallBreakGameHistory> getAllGames() {
    return gameHistoryBox.values.toList();
  }

  // Clear all history (for testing)
  static Future<void> clearAllHistory() async {
    await gameHistoryBox.clear();
    await playerStatsBox.clear();
  }
}
