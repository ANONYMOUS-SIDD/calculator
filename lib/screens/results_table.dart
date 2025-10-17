import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/player_controller.dart';
import '../model/marriage_game.dart';

/// Widget that displays the final results table with player breakdown and game statistics
class ResultsTable extends StatelessWidget {
  const ResultsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController controller = Get.find<PlayerController>();

    return Obx(() {
      final List<CalculatedResult> netResults = controller.calculatedResults;
      final double pointsPerRupee = controller.pointsPerRupee.value;

      // Hide widget if no results to display
      if (netResults.isEmpty) return const SizedBox.shrink();

      // Calculate total points of the whole match (sum of all players' display points)
      final double totalMatchPoints = netResults.fold(0.0, (sum, r) {
        if (r.isWinner) {
          // For winners: pointsEarned + (3 or 5 bonus)
          return sum + (r.player.pointsEarned + (r.player.isDoublee ? 5.0 : 3.0));
        } else {
          // For others: just pointsEarned
          return sum + r.player.pointsEarned;
        }
      });

      final int playersCount = netResults.length;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade100.withOpacity(0.8), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.blueGrey.shade100.withOpacity(0.7), blurRadius: 25, spreadRadius: 2, offset: const Offset(0, 10))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildGameTallySection(totalMatchPoints, pointsPerRupee, playersCount), const SizedBox(height: 20), const SizedBox(height: 10), _buildPlayerBreakdownSection(netResults, pointsPerRupee)]),
        ),
      );
    });
  }

  // ==================== GAME TALLY SECTION ====================

  /// Builds the game statistics section showing total points, rate, and player count
  Widget _buildGameTallySection(double totalMatchPoints, double pointsPerRupee, int playersCount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, spreadRadius: 1, offset: const Offset(0, 7))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 0.9),
                  boxShadow: [BoxShadow(color: Colors.grey.shade300.withOpacity(0.6), blurRadius: 8, spreadRadius: 0.5, offset: const Offset(0, 4))],
                ),
                child: Icon(Icons.calculate_rounded, color: Colors.pink.shade500, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                "Calculation",
                // CHANGED: GoogleFonts.raleway to GoogleFonts.poppins
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.blue.shade900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade100, width: 0.8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 0.5, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatContainer(label: "Total Points", value: totalMatchPoints.toStringAsFixed(0), color: Colors.blue.shade600),
                _buildVerticalDivider(height: 24, margin: 8),
                _buildStatContainer(label: "Rate", value: pointsPerRupee.round().toString(), color: Colors.purple.shade600, isRate: true),
                _buildVerticalDivider(height: 24, margin: 8),
                _buildStatContainer(label: "Players", value: playersCount.toString(), color: Colors.orange.shade600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds individual statistic container with label and value
  Widget _buildStatContainer({required String label, required String value, required Color color, bool isRate = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade700),
            ),
            const SizedBox(height: 2),
            Text(
              isRate ? "$value" : value,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PLAYER BREAKDOWN SECTION ====================

  /// Builds the detailed player breakdown section with points and amounts
  Widget _buildPlayerBreakdownSection(List<CalculatedResult> netResults, double pointsPerRupee) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [BoxShadow(color: Colors.blueGrey.shade100.withOpacity(0.6), blurRadius: 15, spreadRadius: 0.5, offset: const Offset(0, 8))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 600;
          final int playerFlex = isWide ? 8 : 6;
          final int pointsFlex = isWide ? 3 : 3;
          final int amountFlex = isWide ? 3 : 4;

          return Column(
            children: [
              Padding(padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10), child: _buildPlayerBreakdownHeader(playerFlex, pointsFlex, amountFlex)),
              Divider(height: 1, thickness: 1, color: Colors.blue.shade50),
              ...netResults.map((result) {
                final player = result.player;
                final netPointChange = result.netPoints;
                final totalAmount = netPointChange * pointsPerRupee;

                final bool isPositive = netPointChange > 0;
                final Color primaryColor = isPositive ? Colors.green.shade600 : (netPointChange < 0 ? Colors.red.shade600 : Colors.blueGrey.shade500);
                final Color secondaryColor = isPositive ? Colors.blue.shade600 : (netPointChange < 0 ? Colors.orange.shade600 : Colors.blueGrey.shade500);

                return _buildPlayerRow(player: player, netPointChange: netPointChange, totalAmount: totalAmount, primaryColor: primaryColor, secondaryColor: secondaryColor, playerFlex: playerFlex, pointsFlex: pointsFlex, amountFlex: amountFlex, isWinner: result.isWinner);
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  /// Builds the header row for player breakdown section
  Widget _buildPlayerBreakdownHeader(int playerFlex, int pointsFlex, int amountFlex) {
    return Row(
      children: [
        Expanded(flex: playerFlex, child: _buildHeaderContainerContent("Player", Icons.person_pin_circle_rounded, Colors.blue.shade600, TextAlign.center)),
        _buildVerticalDivider(height: 20, margin: 6),
        Expanded(flex: pointsFlex, child: _buildHeaderContainerContent("Points", Icons.star_purple500_outlined, Colors.pinkAccent, TextAlign.center)),
        _buildVerticalDivider(height: 20, margin: 6),
        Expanded(flex: amountFlex, child: _buildHeaderContainerContent("Amount", Icons.monetization_on, Colors.purple, TextAlign.center)),
      ],
    );
  }

  /// Builds individual header container with icon and title
  Widget _buildHeaderContainerContent(String title, IconData icon, Color color, TextAlign align) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 11, color: color),
        ),
      ],
    );
  }

  /// Builds individual player row with name, points, and amount
  Widget _buildPlayerRow({required player, required double netPointChange, required double totalAmount, required Color primaryColor, required Color secondaryColor, required int playerFlex, required int pointsFlex, required int amountFlex, required bool isWinner}) {
    final bool isPositive = netPointChange > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.blue.shade50, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: playerFlex,
            child: Row(
              children: [
                _playerAvatar(player),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildPlayerNameText(player.userName), const SizedBox(height: 5), _buildModePointsContainer(player.pointsEarned.toStringAsFixed(0), player.mode, player.isDoublee)]),
                ),
              ],
            ),
          ),
          Expanded(
            flex: pointsFlex,
            child: Align(alignment: Alignment.center, child: _buildPointsContainer(netPointChange.abs().toStringAsFixed(0), primaryColor, isPositive ? Icons.trending_up_rounded : (netPointChange < 0 ? Icons.trending_down_rounded : Icons.remove_rounded))),
          ),
          Expanded(
            flex: amountFlex,
            child: Align(alignment: Alignment.centerRight, child: _buildAmountContainer(totalAmount.abs().toStringAsFixed(0), secondaryColor, isPositive)),
          ),
        ],
      ),
    );
  }

  /// Builds player name text widget
  Widget _buildPlayerNameText(String name) {
    return Text(
      name,
      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.indigo.shade700),
    );
  }

  /// Builds container showing player mode and points with bonus indicator for winners
  Widget _buildModePointsContainer(String points, PlayerMode mode, bool isDoublee) {
    final MaterialColor color = Colors.lightBlue;

    // Calculate display points: for winners, add bonus; for others, use original points
    final double originalPoints = double.parse(points);
    final double displayPoints = mode == PlayerMode.win ? (originalPoints + (isDoublee ? 5.0 : 3.0)) : originalPoints;
    final String displayText = displayPoints.toStringAsFixed(0);

    // Get mode display name
    final String modeName = _getModeDisplayName(mode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.shade200.withOpacity(0.5), width: 1),
        boxShadow: [BoxShadow(color: color.shade100.withOpacity(0.5), blurRadius: 3, spreadRadius: 0.5, offset: const Offset(0, 1))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            modeName, // Shows "Win", "Seen", or "Blind"
            style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w600, color: color.shade700),
          ),
          _buildVerticalDivider(height: 8, margin: 3),
          Text(
            displayText,
            style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w800, color: color.shade700),
          ),
          // Show bonus indicator for winners
          if (mode == PlayerMode.win) ...[
            _buildVerticalDivider(height: 8, margin: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(color: isDoublee ? Colors.cyan.shade100 : Colors.green.shade100, borderRadius: BorderRadius.circular(2)),
              child: Text(
                isDoublee ? "+5" : "+3",
                style: GoogleFonts.poppins(fontSize: 6, fontWeight: FontWeight.w800, color: isDoublee ? Colors.cyan.shade800 : Colors.green.shade800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds points display container with trend icon
  Widget _buildPointsContainer(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  /// Builds amount display container with win/loss indicator
  Widget _buildAmountContainer(String amount, Color color, bool isWin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isWin ? "Win" : "Loss",
            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade700),
          ),
          _buildVerticalDivider(height: 12, margin: 4),
          Text(
            "$amount",
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  /// Converts PlayerMode enum to display name string
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

  /// Builds player avatar container
  Widget _playerAvatar(player) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade300.withOpacity(0.8), width: 1.5),
      ),
      child: ClipOval(child: _buildProfileImage(player)),
    );
  }

  /// Builds profile image widget handling both network and local images
  Widget _buildProfileImage(player) {
    if (player.userImage != null && player.userImage!.isNotEmpty) {
      if (player.userImage!.startsWith('http')) {
        return Image.network(player.userImage!, fit: BoxFit.cover, width: 36, height: 36, errorBuilder: (context, error, stackTrace) => _defaultProfileIcon());
      } else {
        try {
          final file = File(player.userImage!);
          if (file.existsSync()) {
            return Image.file(file, fit: BoxFit.cover, width: 36, height: 36, errorBuilder: (context, error, stackTrace) => _defaultProfileIcon());
          } else {
            return _defaultProfileIcon();
          }
        } catch (e) {
          return _defaultProfileIcon();
        }
      }
    } else {
      return _defaultProfileIcon();
    }
  }

  /// Builds default profile icon when no image is available
  Widget _defaultProfileIcon({double size = 22}) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade100),
      child: Icon(Icons.person_rounded, size: size, color: Colors.blue.shade600),
    );
  }

  /// Builds vertical divider with customizable height and margin
  Widget _buildVerticalDivider({double height = 18, double margin = 8}) {
    return Container(
      height: height,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: margin),
      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(0.5)),
    );
  }
}
