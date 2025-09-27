// models/marriage_game.dart
class MarriageGame {
  final String id;
  final DateTime createdAt;
  final int numberOfPlayers;
  final double pointsPerRupee;
  final List<MarriagePlayer> players;
  final bool isCompleted;

  MarriageGame({required this.id, required this.createdAt, required this.numberOfPlayers, required this.pointsPerRupee, required this.players, this.isCompleted = false});

  double get totalMaalPoints {
    return players.fold(0.0, (sum, player) => sum + player.maalPoints);
  }

  Map<String, double> calculateResults() {
    // Marriage game calculation logic
    final results = <String, double>{};
    // Add your game calculation logic here
    return results;
  }
}

class MarriagePlayer {
  final String userId;
  final String userName;
  final String? userImage;
  double maalPoints;
  bool isSequence;
  bool isDoublee;
  double pointsEarned;

  MarriagePlayer({required this.userId, required this.userName, this.userImage, this.maalPoints = 0, this.isSequence = false, this.isDoublee = false, this.pointsEarned = 0});
}
