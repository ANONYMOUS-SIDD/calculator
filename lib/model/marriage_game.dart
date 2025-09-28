// lib/model/marriage_game.dart (Updated)

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
    return results;
  }
}

class MarriagePlayer {
  final String userId;
  final String userName;
  final String? userImage;
  final double maalPoints;
  final bool isSequence;
  final bool isDoublee;
  final double pointsEarned;

  // ✅ FIX: Added the missing 'currentScore' property
  final int currentScore;

  MarriagePlayer({
    required this.userId,
    required this.userName,
    this.userImage,
    this.maalPoints = 0,
    this.isSequence = false,
    this.isDoublee = false,
    this.pointsEarned = 0,
    // ✅ FIX: Added 'currentScore' to the constructor
    this.currentScore = 0,
  });

  /// Creates a copy of the MarriagePlayer with optional new values.
  MarriagePlayer copyWith({
    String? userId,
    String? userName,
    String? userImage,
    double? maalPoints,
    bool? isSequence,
    bool? isDoublee,
    double? pointsEarned,
    // ✅ FIX: Added 'currentScore' to copyWith
    int? currentScore,
  }) {
    return MarriagePlayer(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      maalPoints: maalPoints ?? this.maalPoints,
      isSequence: isSequence ?? this.isSequence,
      isDoublee: isDoublee ?? this.isDoublee,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      currentScore: currentScore ?? this.currentScore, // Use it
    );
  }
}
