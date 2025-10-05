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

// Enum to represent the three player modes
enum PlayerMode {
  blind, // Score automatically 0 (UI validation)
  seen, // Score can be 0 or > 0, but not winner
  win, // Score can be 0 or > 0, and is winner
}

class MarriagePlayer {
  final String userId;
  final String userName;
  final String? userImage;
  final double maalPoints;
  final bool isSequence;
  final bool isDoublee;
  final double pointsEarned;
  final int currentScore;
  final PlayerMode mode; // NEW: Track the player's mode (Blind, Seen, Win)

  MarriagePlayer({
    required this.userId,
    required this.userName,
    this.userImage,
    this.maalPoints = 0,
    this.isSequence = false,
    this.isDoublee = false,
    this.pointsEarned = 0,
    this.currentScore = 0,
    required this.mode, // NEW: Required mode selection
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
    int? currentScore,
    PlayerMode? mode, // NEW: Added mode to copyWith
  }) {
    return MarriagePlayer(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      maalPoints: maalPoints ?? this.maalPoints,
      isSequence: isSequence ?? this.isSequence,
      isDoublee: isDoublee ?? this.isDoublee,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      currentScore: currentScore ?? this.currentScore,
      mode: mode ?? this.mode, // NEW: Use it
    );
  }

  // Helper getters for convenience
  bool get isBlind => mode == PlayerMode.blind;
  bool get isSeen => mode == PlayerMode.seen;
  bool get isWin => mode == PlayerMode.win;
}
