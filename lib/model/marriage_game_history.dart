// lib/model/marriage_game_history.dart

import 'package:hive/hive.dart';

part 'marriage_game_history.g.dart'; // This will be generated later

@HiveType(typeId: 4) // Important: Use typeId 4
class MarriageGameHistory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime playedAt;

  @HiveField(2)
  final int numberOfPlayers;

  @HiveField(3)
  final double pointsPerRupee;

  @HiveField(4)
  final double totalMaalPoints;

  @HiveField(5)
  final List<MarriagePlayerHistory> players;

  @HiveField(6)
  final String gameType;

  MarriageGameHistory({required this.id, required this.playedAt, required this.numberOfPlayers, required this.pointsPerRupee, required this.totalMaalPoints, required this.players, this.gameType = "marriage"});
}

@HiveType(typeId: 5) // Important: Use typeId 5
class MarriagePlayerHistory {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String userName;

  @HiveField(2)
  final String? userImage;

  @HiveField(3)
  final double maalPoints;

  @HiveField(4)
  final bool isSequence;

  @HiveField(5)
  final bool isDoublee;

  @HiveField(6)
  final double pointsEarned;

  @HiveField(7)
  final int currentScore;

  @HiveField(8)
  final String mode; // Store as String for simplicity

  MarriagePlayerHistory({required this.userId, required this.userName, this.userImage, required this.maalPoints, required this.isSequence, required this.isDoublee, required this.pointsEarned, required this.currentScore, required this.mode});
}
