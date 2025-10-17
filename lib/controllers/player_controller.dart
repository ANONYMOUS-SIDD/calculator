import 'package:get/get.dart';

import '../model/marriage_game.dart';
import '../model/user_model.dart';

/// Represents the calculated result for a player in Marriage game
class CalculatedResult {
  final MarriagePlayer player;
  final double netPoints;
  final bool isWinner;
  final double totalPointForDisplay;

  const CalculatedResult({required this.player, required this.netPoints, this.isWinner = false, required this.totalPointForDisplay});
}

/// Controller for managing Marriage game players and calculations
class PlayerController extends GetxController {
  final RxList<MarriagePlayer> players = <MarriagePlayer>[].obs;
  static const int defaultPlayerCount = 4;

  final RxInt selectedPlayerCount = defaultPlayerCount.obs;
  final RxDouble pointsPerRupee = 1.0.obs;
  final calculatedResults = <CalculatedResult>[].obs;
  final RxBool _hasWinnerSelected = false.obs;

  /// Determines if calculation can proceed (requires at least one winner)
  bool get canCalculate => _hasWinnerSelected.value;

  @override
  void onInit() {
    super.onInit();
    ever(players, (_) => _updateWinnerSelectionStatus());
  }

  /// Initializes players with provided list
  void initializePlayers(List<MarriagePlayer> initialPlayers) {
    players.assignAll(initialPlayers);
    calculatedResults.clear();
    _updateWinnerSelectionStatus();
  }

  /// Updates players list from User objects
  void updatePlayersFromUsers(List<User> newUsers) {
    final Map<String, MarriagePlayer> existingPlayersMap = {for (var player in players) player.userName: player};

    final List<MarriagePlayer> newMarriagePlayers = newUsers.map((user) {
      final String username = user.username;
      final oldPlayer = existingPlayersMap[username];

      return MarriagePlayer(userId: username, userName: username, userImage: user.profileImagePath, isDoublee: oldPlayer?.isDoublee ?? false, currentScore: oldPlayer?.currentScore ?? 0, pointsEarned: oldPlayer?.pointsEarned ?? 0.0, mode: oldPlayer?.mode ?? PlayerMode.seen);
    }).toList();

    players.assignAll(newMarriagePlayers);
    calculatedResults.clear();
    _updateWinnerSelectionStatus();
  }

  /// Updates the number of players in the game
  void updatePlayerCount(int newCount) {
    if (newCount >= 3 && newCount <= 6) {
      selectedPlayerCount.value = newCount;
    }
  }

  /// Updates points per rupee conversion rate
  void updatePointsPerRupee(double value) {
    if (value > 0) {
      pointsPerRupee.value = value;
    }
  }

  /// Resets the game to initial state
  void resetGame() {
    final List<MarriagePlayer> resetPlayers = players.map((player) {
      return player.copyWith(currentScore: 0, pointsEarned: 0.0, isDoublee: false, mode: PlayerMode.seen);
    }).toList();

    players.assignAll(resetPlayers);
    calculatedResults.clear();
    _updateWinnerSelectionStatus();
  }

  /// Updates player score and recalculates if needed
  void updatePlayerScore(String userName, double newPoints) {
    final index = players.indexWhere((p) => p.userName == userName);
    if (index != -1) {
      final updatedPlayer = players[index].copyWith(pointsEarned: newPoints, currentScore: newPoints.toInt());
      players[index] = updatedPlayer;
      if (calculatedResults.isNotEmpty) calculatedResults.clear();
      _updateWinnerSelectionStatus();
    }
  }

  /// Updates player mode and handles mode-specific logic
  void updatePlayerMode(String userName, PlayerMode newMode) {
    final index = players.indexWhere((p) => p.userName == userName);
    if (index != -1) {
      final double newPoints = newMode == PlayerMode.blind ? 0.0 : players[index].pointsEarned;
      final updatedPlayer = players[index].copyWith(mode: newMode, pointsEarned: newPoints, currentScore: newPoints.toInt());
      players[index] = updatedPlayer;
      if (calculatedResults.isNotEmpty) calculatedResults.clear();
      _updateWinnerSelectionStatus();
    }
  }

  /// Toggles doublee status for a player
  void toggleDoublee(String userName) {
    final index = players.indexWhere((p) => p.userName == userName);
    if (index != -1) {
      players[index] = players[index].copyWith(isDoublee: !players[index].isDoublee);
      if (calculatedResults.isNotEmpty) calculatedResults.clear();
      _updateWinnerSelectionStatus();
    }
  }

  /// Updates winner selection status based on current players
  void _updateWinnerSelectionStatus() {
    if (players.isEmpty) {
      _hasWinnerSelected.value = false;
      return;
    }
    final hasWinner = players.any((player) => player.mode == PlayerMode.win);
    _hasWinnerSelected.value = hasWinner;
  }

  /// Core calculation logic for Marriage game results
  void _calculateGameResults() {
    if (players.isEmpty) {
      calculatedResults.clear();
      return;
    }

    final int totalPlayers = players.length;
    final List<MarriagePlayer> winners = players.where((player) => player.mode == PlayerMode.win).toList();

    if (winners.isEmpty) {
      calculatedResults.clear();
      return;
    }

    // Calculate base total from all player points
    final double baseTotal = players.fold(0.0, (sum, p) => sum + p.pointsEarned);

    final List<_PlayerCalculation> nonWinnerCalculations = [];
    final List<_PlayerCalculation> winnerCalculations = [];

    // Calculate non-winner results (Blind and Seen players)
    for (var player in players) {
      if (player.mode == PlayerMode.blind) {
        // Blind player loses baseTotal + 10
        final double totalPoint = baseTotal + 10.0;
        final double netPoints = -totalPoint;

        nonWinnerCalculations.add(_PlayerCalculation(player: player, totalPoint: totalPoint, netPoints: netPoints, displayPoints: player.pointsEarned));
      } else if (player.mode == PlayerMode.seen) {
        // Seen player calculation
        double totalPoint = baseTotal;

        // Add bonuses from winners (except for doublee seen players)
        if (!player.isDoublee) {
          for (var winner in winners) {
            totalPoint += winner.isDoublee ? 5.0 : 3.0;
          }
        }

        // Calculate net: (player points * total players) - total point
        final double netPoints = (player.pointsEarned * totalPlayers) - totalPoint;

        nonWinnerCalculations.add(_PlayerCalculation(player: player, totalPoint: totalPoint, netPoints: netPoints, displayPoints: player.pointsEarned));
      } else if (player.mode == PlayerMode.win) {
        // Win player calculation (net determined later)
        final double displayPoints = player.pointsEarned + (player.isDoublee ? 5.0 : 3.0);

        winnerCalculations.add(_PlayerCalculation(player: player, totalPoint: 0.0, netPoints: 0.0, displayPoints: displayPoints));
      }
    }

    // Calculate win players' nets based on other players' results
    final List<CalculatedResult> finalResults = [];

    if (winners.isNotEmpty) {
      // Sum nets of all non-winners
      double sumNonWinnerNets = 0.0;
      for (final calc in nonWinnerCalculations) {
        sumNonWinnerNets += calc.netPoints;
      }

      // Each winner gets equal share of the negative sum
      final double perWinnerShare = -sumNonWinnerNets / winners.length;
      final double winTotalPoint = baseTotal + (winners.first.isDoublee ? 5.0 : 3.0);

      // Build final results for win players
      for (final calc in winnerCalculations) {
        finalResults.add(CalculatedResult(player: calc.player, netPoints: perWinnerShare, isWinner: true, totalPointForDisplay: winTotalPoint));
      }
    }

    // Add non-winner results
    for (final calc in nonWinnerCalculations) {
      finalResults.add(CalculatedResult(player: calc.player, netPoints: calc.netPoints, isWinner: false, totalPointForDisplay: calc.totalPoint));
    }

    // Sort by net points (winners first)
    finalResults.sort((a, b) => b.netPoints.compareTo(a.netPoints));
    calculatedResults.value = finalResults;
  }

  /// Triggers game calculation if conditions are met
  void calculateGame() {
    if (!canCalculate) return;
    _calculateGameResults();
  }

  /// Generates formatted result summary for display
  String getResultSummary() {
    if (calculatedResults.isEmpty) return 'No results calculated';

    final buffer = StringBuffer();
    buffer.writeln('Game Results Summary');
    buffer.writeln('${'=' * 30}');

    for (final result in calculatedResults) {
      final p = result.player;
      final net = result.netPoints;
      final sign = net >= 0 ? '+' : '';
      final status = result.isWinner ? 'Winner' : (net < 0 ? 'Loss' : 'Profit');

      final double displayPlayerPoints = result.isWinner ? (p.pointsEarned + (p.isDoublee ? 5.0 : 3.0)) : p.pointsEarned;

      buffer.writeln('${p.userName}: $sign${net.toStringAsFixed(1)} pts → $status');
      buffer.writeln('   → Player Points: ${displayPlayerPoints.toStringAsFixed(1)}');
      buffer.writeln('   → Total Point: ${result.totalPointForDisplay.toStringAsFixed(1)}');
      buffer.writeln('   → Mode: ${_getModeDisplayName(p.mode)}${p.isDoublee ? ' (Doublee)' : ''}');
      buffer.writeln('---');
    }

    return buffer.toString();
  }

  /// Gets winner information for display
  String get winnerInfo {
    if (calculatedResults.isEmpty) return 'No result yet';
    final winners = calculatedResults.where((r) => r.isWinner).toList();
    if (winners.isEmpty) return 'No winners this round';
    if (winners.length == 1) {
      final w = winners.first.player;
      final displayPoints = w.pointsEarned + (w.isDoublee ? 5.0 : 3.0);
      return '${w.userName} is the winner (${displayPoints.toStringAsFixed(1)} points)!';
    }
    return 'Winners: ${winners.map((w) => w.player.userName).join(', ')}';
  }

  /// Gets pot information for display
  String get potInfo {
    if (players.isEmpty) return 'No players';
    final totalBasePoints = players.fold(0.0, (sum, player) => sum + player.pointsEarned);

    final winners = players.where((player) => player.mode == PlayerMode.win).toList();
    if (winners.isEmpty) {
      return 'Base Total: ${totalBasePoints.toStringAsFixed(1)} | No winner selected';
    }

    double displayTotal = totalBasePoints;
    for (var winner in winners) {
      displayTotal += winner.isDoublee ? 5.0 : 3.0;
    }

    return 'Base Total: ${totalBasePoints.toStringAsFixed(1)} | Display Total: ${displayTotal.toStringAsFixed(1)}';
  }

  /// Converts points to monetary value
  double getMonetaryValue(double points) {
    return points / (pointsPerRupee.value == 0 ? 1 : pointsPerRupee.value);
  }

  /// Formats monetary result for display
  String getFormattedMonetaryResult(double points) {
    final monetaryValue = getMonetaryValue(points.abs());
    return '₹${monetaryValue.toStringAsFixed(2)}';
  }

  /// Checks if game is ready for calculation
  bool get isGameReadyToCalculate {
    return players.isNotEmpty && players.every((player) => player.pointsEarned >= 0);
  }

  /// Gets display name for player mode
  String _getModeDisplayName(PlayerMode mode) {
    switch (mode) {
      case PlayerMode.blind:
        return 'Blind';
      case PlayerMode.seen:
        return 'Seen';
      case PlayerMode.win:
        return 'Win';
    }
  }

  /// Gets list of selected winners
  List<MarriagePlayer> get selectedWinners {
    return players.where((player) => player.mode == PlayerMode.win).toList();
  }
}

/// Internal class for temporary calculation storage
class _PlayerCalculation {
  final MarriagePlayer player;
  final double totalPoint;
  final double netPoints;
  final double displayPoints;

  _PlayerCalculation({required this.player, required this.totalPoint, required this.netPoints, required this.displayPoints});
}
