import 'package:hive_flutter/hive_flutter.dart';

import '../model/game_history_models.dart';
import '../model/marriage_game_history.dart'; // Add this import
import '../model/round_data.dart';

class HistoryRepository {
  static late Box<CallBreakGameHistory> callBreakGameHistoryBox;
  static late Box<MarriageGameHistory> marriageGameHistoryBox; // NEW: Add Marriage box
  static late Box<PlayerOverallStats> playerStatsBox;

  static Future<void> init() async {
    callBreakGameHistoryBox = await Hive.openBox<CallBreakGameHistory>('callBreakGameHistory');
    marriageGameHistoryBox = await Hive.openBox<MarriageGameHistory>('marriageGameHistory'); // NEW: Initialize Marriage box
    playerStatsBox = await Hive.openBox<PlayerOverallStats>('playerStats');
  }

  // ========== MARRIAGE GAME METHODS ========== //

  // NEW: Save completed Marriage game
  static Future<void> saveMarriageGame({required String id, required DateTime playedAt, required int numberOfPlayers, required double pointsPerRupee, required double totalMaalPoints, required List<MarriagePlayerHistory> players}) async {
    final marriageGameHistory = MarriageGameHistory(id: id, playedAt: playedAt, numberOfPlayers: numberOfPlayers, pointsPerRupee: pointsPerRupee, totalMaalPoints: totalMaalPoints, players: players, gameType: "marriage");

    await marriageGameHistoryBox.put(id, marriageGameHistory);

    // Update player stats for Marriage game
    for (final player in players) {
      await _updatePlayerStatsForMarriage(player.userName, player.pointsEarned);
    }
  }

  // NEW: Update player stats for Marriage game
  static Future<void> _updatePlayerStatsForMarriage(String playerName, double pointsEarned) async {
    var stats = playerStatsBox.get(playerName) ?? PlayerOverallStats(playerName: playerName, lastPlayed: DateTime.now());

    // Update stats specific to Marriage game
    stats.totalMatchesPlayed++;
    // Add more Marriage-specific stats if needed
    stats.lastPlayed = DateTime.now();
    stats.updateLevel();

    await playerStatsBox.put(playerName, stats);
  }

  // NEW: Get all Marriage games
  static List<MarriageGameHistory> getAllMarriageGames() {
    final allGames = marriageGameHistoryBox.values.toList();
    // Sort by latest first
    allGames.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return allGames;
  }

  // NEW: Get today's Marriage games
  static List<MarriageGameHistory> getTodaysMarriageGames() {
    final today = DateTime.now();
    final allGames = marriageGameHistoryBox.values.toList();

    return allGames.where((game) => game.playedAt.year == today.year && game.playedAt.month == today.month && game.playedAt.day == today.day).toList();
  }

  // ========== CALL BREAK METHODS (KEEP EXISTING) ========== //

  // Keep all your existing Call Break methods exactly as they are...
  static Future<void> saveCompletedGame({required List<String> playerNames, required List<double> totalScores, required int totalRounds, required String gameTag, required List<RoundData> rounds}) async {
    // Your existing Call Break code remains unchanged
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

  // Keep all other existing Call Break methods...
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

  // Keep all other existing methods...
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
    await marriageGameHistoryBox.clear(); // NEW: Clear Marriage history too
    await playerStatsBox.clear();
  }
}
