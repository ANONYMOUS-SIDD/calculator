import 'package:hive/hive.dart';

part 'game_history_models.g.dart';

// ADD THIS NEW CLASS FIRST
@HiveType(typeId: 3) // Using typeId 3
class RoundHistoryData {
  @HiveField(0)
  final int roundNumber;

  @HiveField(1)
  final List<int> bids;

  @HiveField(2)
  final List<int> extras;

  @HiveField(3)
  final List<double> points;

  @HiveField(4)
  final List<bool> bidSuccess;

  RoundHistoryData({required this.roundNumber, required this.bids, required this.extras, required this.points, required this.bidSuccess});
}

@HiveType(typeId: 1)
class CallBreakGameHistory {
  @HiveField(0)
  final String gameId;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final List<String> playerNames;

  @HiveField(3)
  final List<int> totalScores;

  @HiveField(4)
  final int totalRounds;

  @HiveField(5)
  final String gameTag;

  // ADD THIS NEW FIELD - round details
  @HiveField(6)
  final List<RoundHistoryData> roundDetails;

  CallBreakGameHistory({
    required this.gameId,
    required this.timestamp,
    required this.playerNames,
    required this.totalScores,
    required this.totalRounds,
    required this.gameTag,
    required this.roundDetails, // ADD THIS PARAMETER
  });
}

@HiveType(typeId: 2)
class PlayerOverallStats {
  @HiveField(0)
  final String playerName;

  @HiveField(1)
  int totalMatchesPlayed;

  @HiveField(2)
  int totalWins;

  @HiveField(3)
  int currentLevel;

  @HiveField(4)
  DateTime lastPlayed;

  PlayerOverallStats({required this.playerName, this.totalMatchesPlayed = 0, this.totalWins = 0, this.currentLevel = 1, required this.lastPlayed});

  void updateLevel() {
    if (totalWins >= 20) {
      currentLevel = 5;
    } else if (totalWins >= 15) {
      currentLevel = 4;
    } else if (totalWins >= 10) {
      currentLevel = 3;
    } else if (totalWins >= 5) {
      currentLevel = 2;
    } else {
      currentLevel = 1;
    }
  }
}
