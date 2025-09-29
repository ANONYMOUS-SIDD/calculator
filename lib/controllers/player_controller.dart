import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/marriage_game.dart';
import '../model/user_model.dart';

class CalculatedResult {
  final MarriagePlayer player;
  final double netPoints;
  final bool isWinner;
  const CalculatedResult({required this.player, required this.netPoints, this.isWinner = false});
}

class PlayerController extends GetxController {
  final RxList<MarriagePlayer> players = <MarriagePlayer>[].obs;
  static const int defaultPlayerCount = 4;

  final RxInt selectedPlayerCount = defaultPlayerCount.obs;
  final RxDouble pointsPerRupee = 1.0.obs;

  final calculatedResults = <CalculatedResult>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  void initializePlayers(List<MarriagePlayer> initialPlayers) {
    players.assignAll(initialPlayers);
    calculatedResults.clear();
  }

  void updatePlayersFromUsers(List<User> newUsers) {
    final Map<String, MarriagePlayer> existingPlayersMap = {for (var player in players) player.userName: player};

    final List<MarriagePlayer> newMarriagePlayers = newUsers.map((user) {
      final String username = user.username;
      final oldPlayer = existingPlayersMap[username];

      return MarriagePlayer(userId: username, userName: username, userImage: user.profileImagePath, isDoublee: oldPlayer?.isDoublee ?? false, currentScore: oldPlayer?.currentScore ?? 0, pointsEarned: oldPlayer?.pointsEarned ?? 0.0);
    }).toList();

    players.assignAll(newMarriagePlayers);
    calculatedResults.clear();
  }

  // --- Game Setup Management Methods ---
  void updatePlayerCount(int newCount) {
    if (newCount >= 3 && newCount <= 6) {
      selectedPlayerCount.value = newCount;
    }
  }

  void updatePointsPerRupee(double value) {
    if (value > 0) {
      pointsPerRupee.value = value;
    }
  }

  void resetGame() {
    final List<MarriagePlayer> resetPlayers = players.map((player) {
      return player.copyWith(currentScore: 0, pointsEarned: 0.0, isDoublee: false);
    }).toList();

    players.assignAll(resetPlayers);
    calculatedResults.clear();
  }

  void updatePlayerScore(String userName, double newPoints) {
    final index = players.indexWhere((p) => p.userName == userName);
    if (index != -1) {
      final updatedPlayer = players[index].copyWith(pointsEarned: newPoints, currentScore: newPoints.toInt());
      players[index] = updatedPlayer;
      if (calculatedResults.isNotEmpty) calculatedResults.clear();
    }
  }

  void toggleDoublee(String userName) {
    final index = players.indexWhere((p) => p.userName == userName);
    if (index != -1) {
      players[index] = players[index].copyWith(isDoublee: !players[index].isDoublee);
      if (calculatedResults.isNotEmpty) calculatedResults.clear();
    }
  }

  // --- CORE CALCULATION (updated as you requested) ---
  void _calculateGameResults() {
    if (players.isEmpty) {
      calculatedResults.clear();
      return;
    }

    final int totalPlayers = players.length;

    // Determine the "winningPlayer" by highest input (used to determine the winnerBonus for totals)
    final winningPlayer = players.reduce((a, b) => a.pointsEarned > b.pointsEarned ? a : b);
    final double winnerBonus = winningPlayer.isDoublee ? 5.0 : 3.0;

    // Base total is sum of inputs (no bonus)
    final double baseTotal = players.fold(0.0, (sum, p) => sum + p.pointsEarned);

    // First pass: compute preliminary net for every player (blind & seen)
    // and detect who *qualifies* as a winner candidate (multiplied >= their totalPoint)
    final List<_TempResult> temp = [];
    final Set<String> winnerCandidates = {};

    for (var player in players) {
      final double input = player.pointsEarned;

      if (input == 0) {
        // Blind user: always loses baseTotal + 10
        final double net = -(baseTotal + 10.0);
        temp.add(_TempResult(player: player, net: net, isCandidate: false));
        continue;
      }

      // Seen user:
      // If this seen player has doublee (isDoublee), their personal totalPoint should NOT include the winner bonus.
      final double totalPointForThisPlayer = player.isDoublee ? baseTotal : (baseTotal + winnerBonus);

      final double multiplied = input * totalPlayers;
      final double net = multiplied - totalPointForThisPlayer; // positive => exceeds totalPoint (win), negative => loss

      final bool isCandidate = multiplied >= totalPointForThisPlayer;
      if (isCandidate) winnerCandidates.add(player.userId);

      temp.add(_TempResult(player: player, net: net, isCandidate: isCandidate));
    }

    // If there are winners, winners must take the opposite of sum(others nets)
    final List<CalculatedResult> finalResults = [];

    if (winnerCandidates.isNotEmpty) {
      // Sum nets of non-winners (these include blind users and seen losers)
      double sumNonWinners = 0.0;
      for (final t in temp) {
        if (!winnerCandidates.contains(t.player.userId)) {
          sumNonWinners += t.net;
        }
      }

      // Distribute the opposite of sumNonWinners among winners equally
      final List<_TempResult> winnersTemp = temp.where((t) => winnerCandidates.contains(t.player.userId)).toList();
      final int winnersCount = winnersTemp.length;

      // If sumNonWinners is negative (loss total), then -sumNonWinners is positive (money to winners)
      final double perWinnerShare = winnersCount > 0 ? (-sumNonWinners / winnersCount) : 0.0;

      // Build final results: winners get perWinnerShare, non-winners keep their net
      for (final t in temp) {
        if (winnerCandidates.contains(t.player.userId)) {
          finalResults.add(CalculatedResult(player: t.player, netPoints: perWinnerShare, isWinner: true));
        } else {
          finalResults.add(CalculatedResult(player: t.player, netPoints: t.net, isWinner: false));
        }
      }
    } else {
      // No winners -> keep preliminary nets as final results (no balancing to winners)
      for (final t in temp) {
        finalResults.add(CalculatedResult(player: t.player, netPoints: t.net, isWinner: false));
      }
    }

    // Sort so winners (usually positive) come first
    finalResults.sort((a, b) => b.netPoints.compareTo(a.netPoints));
    calculatedResults.value = finalResults;

    // Snackbar feedback
    final bool anyWinner = finalResults.any((r) => r.isWinner);
    Get.snackbar('Results Ready', anyWinner ? 'Winner(s) determined!' : 'No winner this round.', backgroundColor: anyWinner ? const Color(0xFF10B981) : const Color(0xFFEF4444), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  void calculateGame() {
    _calculateGameResults();
  }

  // --- Helpers for UI / Display ---

  /// Summary text. For winners, displayed points = input + bonus (3 or 5 per their own mode).
  String getResultSummary() {
    if (calculatedResults.isEmpty) return 'No results calculated';

    final buffer = StringBuffer();
    buffer.writeln('🎮 Game Results Summary');
    buffer.writeln('${'=' * 30}');

    for (final result in calculatedResults) {
      final p = result.player;
      final net = result.netPoints;
      final sign = net >= 0 ? '+' : '';
      final status = result.isWinner ? '🏆 Winner' : (net < 0 ? '🔴 Loss' : '🟢 Profit');

      // For display: if player is winner (final), show input + own bonus; otherwise show input (blind => 0)
      final double displayPoints = result.isWinner ? (p.pointsEarned + (p.isDoublee ? 5.0 : 3.0)) : (p.pointsEarned == 0 ? 0.0 : p.pointsEarned);

      final bonusText = result.isWinner ? ' (${p.pointsEarned.toStringAsFixed(0)} + ${p.isDoublee ? 5 : 3})' : '';
      buffer.writeln('${p.userName}: $sign${net.toStringAsFixed(1)} pts → $status');
      buffer.writeln('   → Display Points: ${displayPoints.toStringAsFixed(1)}$bonusText');
      buffer.writeln('   → Mode: ${p.pointsEarned == 0 ? 'Blind' : (p.isDoublee ? 'Seen (Doublee)' : 'Seen')}');
      buffer.writeln('---');
    }

    return buffer.toString();
  }

  String get winnerInfo {
    if (calculatedResults.isEmpty) return 'No result yet';
    final winners = calculatedResults.where((r) => r.isWinner).toList();
    if (winners.isEmpty) return 'No winner this round';
    if (winners.length == 1) {
      final w = winners.first.player;
      return '${w.userName} is the winner (display ${w.pointsEarned + (w.isDoublee ? 5 : 3)} points)!';
    }
    return 'Winners: ${winners.map((w) => w.player.userName).join(', ')}';
  }

  String get potInfo {
    if (players.isEmpty) return 'No players';
    final totalBasePoints = players.fold(0.0, (sum, player) => sum + player.pointsEarned);
    final winningPlayer = players.reduce((a, b) => a.pointsEarned > b.pointsEarned ? a : b);
    final winnerBonus = winningPlayer.isDoublee ? 5.0 : 3.0;
    return 'Base Pot: ${totalBasePoints.toStringAsFixed(1)} | With Bonus (winner): ${(totalBasePoints + winnerBonus).toStringAsFixed(1)}';
  }

  double getMonetaryValue(double points) {
    return points / (pointsPerRupee.value == 0 ? 1 : pointsPerRupee.value);
  }

  String getFormattedMonetaryResult(double points) {
    final monetaryValue = getMonetaryValue(points.abs());
    return '₹${monetaryValue.toStringAsFixed(2)}';
  }

  bool get isGameReadyToCalculate {
    return players.isNotEmpty && players.every((player) => player.pointsEarned >= 0);
  }
}

/// Internal temp holder used during calculation
class _TempResult {
  final MarriagePlayer player;
  final double net;
  final bool isCandidate;
  _TempResult({required this.player, required this.net, required this.isCandidate});
}
