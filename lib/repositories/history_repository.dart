import 'package:hive_flutter/hive_flutter.dart';

import '../model/game_history_models.dart';
import '../model/round_data.dart'; // ADD THIS IMPORT

class HistoryRepository {
  static late Box<CallBreakGameHistory> gameHistoryBox;
  static late Box<PlayerOverallStats> playerStatsBox;

  static Future<void> init() async {
    gameHistoryBox = await Hive.openBox<CallBreakGameHistory>('callBreakGameHistory');
    playerStatsBox = await Hive.openBox<PlayerOverallStats>('playerStats');
  }

  // Calculate position based on scores (1st, 2nd, 3rd, etc.)
  static int _calculatePosition(List<int> totalScores, int playerIndex) {
    final playerScore = totalScores[playerIndex];
    final sortedScores = List<int>.from(totalScores)..sort((a, b) => b.compareTo(a));
    return sortedScores.indexOf(playerScore) + 1;
  }

  // Check if player is winner (has highest score)
  static bool _isWinner(List<int> totalScores, int playerIndex) {
    final playerScore = totalScores[playerIndex];
    final maxScore = totalScores.reduce((a, b) => a > b ? a : b);
    return playerScore == maxScore;
  }

  // UPDATED: Save completed game with round details
  static Future<void> saveCompletedGame({
    required List<String> playerNames,
    required List<int> totalScores,
    required int totalRounds,
    required String gameTag,
    required List<RoundData> rounds, // ADD THIS PARAMETER
  }) async {
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
      totalScores: totalScores,
      totalRounds: totalRounds,
      gameTag: gameTag,
      roundDetails: roundDetails, // ADD THIS
    );

    // Save the game
    await gameHistoryBox.put(gameId, gameHistory);

    // Update all players' statistics
    for (int i = 0; i < playerNames.length; i++) {
      await _updatePlayerStats(playerNames[i], totalScores[i], _isWinner(totalScores, i), _calculatePosition(totalScores, i));
    }
  }

  // Update player statistics
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
