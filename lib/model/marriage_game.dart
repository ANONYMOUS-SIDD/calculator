// lib/model/marriage_game.dart

/// Represents a complete Marriage card game session
class MarriageGame {
  final String id;
  final DateTime createdAt;
  final int numberOfPlayers;
  final double pointsPerRupee;
  final List<MarriagePlayer> players;
  final bool isCompleted;

  MarriageGame({required this.id, required this.createdAt, required this.numberOfPlayers, required this.pointsPerRupee, required this.players, this.isCompleted = false});

  /// Calculates total maal points from all players
  double get totalMaalPoints {
    return players.fold(0.0, (sum, player) => sum + player.maalPoints);
  }

  /// Calculates game results and returns player-wise points
  Map<String, double> calculateResults() {
    final results = <String, double>{};
    // Marriage game calculation logic
    return results;
  }
}

/// Represents the three possible player modes in Marriage game
enum PlayerMode {
  blind, // Score automatically 0 (UI validation)
  seen, // Score can be 0 or > 0, but not winner
  win, // Score can be 0 or > 0, and is winner
}

/// Represents an individual player in a Marriage game
class MarriagePlayer {
  final String userId;
  final String userName;
  final String? userImage;
  final double maalPoints;
  final bool isSequence;
  final bool isDoublee;
  final double pointsEarned;
  final int currentScore;
  final PlayerMode mode;

  MarriagePlayer({required this.userId, required this.userName, this.userImage, this.maalPoints = 0, this.isSequence = false, this.isDoublee = false, this.pointsEarned = 0, this.currentScore = 0, required this.mode});

  /// Creates a copy of the MarriagePlayer with optional new values
  MarriagePlayer copyWith({String? userId, String? userName, String? userImage, double? maalPoints, bool? isSequence, bool? isDoublee, double? pointsEarned, int? currentScore, PlayerMode? mode}) {
    return MarriagePlayer(userId: userId ?? this.userId, userName: userName ?? this.userName, userImage: userImage ?? this.userImage, maalPoints: maalPoints ?? this.maalPoints, isSequence: isSequence ?? this.isSequence, isDoublee: isDoublee ?? this.isDoublee, pointsEarned: pointsEarned ?? this.pointsEarned, currentScore: currentScore ?? this.currentScore, mode: mode ?? this.mode);
  }

  /// Convenience getter for blind mode check
  bool get isBlind => mode == PlayerMode.blind;

  /// Convenience getter for seen mode check
  bool get isSeen => mode == PlayerMode.seen;

  /// Convenience getter for win mode check
  bool get isWin => mode == PlayerMode.win;
}
