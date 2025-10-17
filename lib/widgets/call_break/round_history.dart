import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/call_break_controller.dart';
import '../../model/round_data.dart';
import '../../model/user_model.dart';

/// Widget to display round history, current bids, and player rankings
/// Shows completed rounds, current bids, and final scores with editing capabilities
class RoundHistory extends StatefulWidget {
  final String tag;

  const RoundHistory({super.key, required this.tag});

  @override
  State<RoundHistory> createState() => _RoundHistoryState();
}

class _RoundHistoryState extends State<RoundHistory> {
  MediaQueryData? _mediaQuery;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mediaQuery = MediaQuery.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallBreakController>(tag: widget.tag);
    final screenWidth = _mediaQuery?.size.width ?? MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.rounds.isEmpty && !controller.bidCompleted.any((completed) => completed)) {
        return const SizedBox();
      }

      final bool isSmallScreen = screenWidth < 350;
      final double valueFontSize = isSmallScreen ? 11 : 13;
      final double playerNameFontSize = isSmallScreen ? 9 : 11;

      return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 15, left: 8, right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 25, spreadRadius: 3, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: Colors.grey.shade50, width: 2),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.blue.shade50, Colors.purple.shade50]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlayersSection(controller, isSmallScreen, playerNameFontSize),
            const SizedBox(height: 12),
            _buildScoreSection(controller, isSmallScreen, valueFontSize),
            if (controller.rounds.isNotEmpty) ...[const SizedBox(height: 16), _buildFinalScoreSection(controller, isSmallScreen, playerNameFontSize)],
          ],
        ),
      );
    });
  }

  /// Builds players section with avatars and names
  Widget _buildPlayersSection(CallBreakController controller, bool isSmallScreen, double playerNameFontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.purple.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: controller.selectedPlayers.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;

          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _getPlayerColor(index).withOpacity(0.8), width: 2.5),
                    boxShadow: [BoxShadow(color: _getPlayerColor(index).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: ClipOval(child: _buildPlayerAvatar(player)),
                ),
                const SizedBox(height: 8),
                Text(
                  _getShortName(player.username),
                  style: GoogleFonts.quicksand(fontSize: playerNameFontSize, fontWeight: FontWeight.w900, color: Colors.blue.shade900),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds score section with completed rounds and current bids
  Widget _buildScoreSection(CallBreakController controller, bool isSmallScreen, double valueFontSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(children: [_buildCompletedRounds(controller, isSmallScreen, valueFontSize), _buildCurrentBids(controller, isSmallScreen, valueFontSize)]),
    );
  }

  /// Builds completed rounds display
  Widget _buildCompletedRounds(CallBreakController controller, bool isSmallScreen, double valueFontSize) {
    return Column(
      children: [
        ...controller.rounds.asMap().entries.map((roundEntry) {
          final roundIndex = roundEntry.key;
          final round = roundEntry.value;
          final isLastRound = roundIndex == controller.rounds.length - 1;

          return Column(
            children: [
              GestureDetector(
                key: ValueKey('round_${roundIndex}_${round.hashCode}'),
                onLongPress: () {
                  _showEditRoundDialog(context, roundIndex, round);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      ...round.bids.asMap().entries.map((entry) {
                        final index = entry.key;
                        final bid = entry.value;
                        final extra = round.extras[index];
                        final totalTricks = bid + extra;
                        final failed = totalTricks < bid;

                        return Expanded(
                          key: ValueKey('round_result_${roundIndex}_$index'),
                          child: Center(child: _buildRoundResult(bid, extra, failed, valueFontSize)),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              if (!isLastRound) Container(height: 1, color: Colors.grey.withOpacity(0.2)),
            ],
          );
        }).toList(),
      ],
    );
  }

  /// Builds current bids display
  Widget _buildCurrentBids(CallBreakController controller, bool isSmallScreen, double valueFontSize) {
    if (controller.bidCompleted.any((completed) => completed) || controller.currentBids.any((bid) => bid > 0)) {
      return Column(
        children: [
          if (controller.rounds.isNotEmpty) Container(height: 1, color: Colors.pink.withOpacity(0.3)),
          GestureDetector(
            key: const ValueKey('current_bids_container'),
            onLongPress: () {
              _showEditCurrentBidDialog(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
              child: Row(
                children: [
                  ...controller.currentBids.asMap().entries.map((entry) {
                    final index = entry.key;
                    final bid = entry.value;
                    final extra = controller.currentExtras[index];
                    final bidCompleted = controller.bidCompleted[index];
                    final hasExtra = extra > 0;

                    return Expanded(
                      key: ValueKey('current_bid_$index'),
                      child: Center(
                        child: bidCompleted || bid > 0 || hasExtra
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasExtra && !bidCompleted)
                                    Text(
                                      '${(bid + (extra * 0.1)).toStringAsFixed(1)}',
                                      style: GoogleFonts.poppins(fontSize: valueFontSize, fontWeight: FontWeight.w700, color: Colors.pink.shade700),
                                    )
                                  else if (bidCompleted)
                                    _buildCurrentBidCircle(bid, valueFontSize, Colors.purple)
                                  else
                                    _buildCurrentBidCircle(bid, valueFontSize, Colors.pink),
                                ],
                              )
                            : Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.pink.withOpacity(0.3), width: 1.5),
                                ),
                              ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  /// Builds final score section with player rankings and points
  Widget _buildFinalScoreSection(CallBreakController controller, bool isSmallScreen, double playerNameFontSize) {
    return Container(
      key: const ValueKey('final_score_container'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Column(children: [_buildPlayerRankings(controller, isSmallScreen, playerNameFontSize), const SizedBox(height: 10), _buildPointsDisplay(controller, isSmallScreen)]),
    );
  }

  /// Builds player rankings with badges and avatars
  Widget _buildPlayerRankings(CallBreakController controller, bool isSmallScreen, double playerNameFontSize) {
    return Row(
      children: controller.selectedPlayers.asMap().entries.map((entry) {
        final index = entry.key;
        final player = entry.value;
        final rank = _getPlayerRank(controller, index);

        return Expanded(
          key: ValueKey('player_rank_$index'),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  gradient: _getRankGradient(rank),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                  boxShadow: [BoxShadow(color: _getRankColor(rank).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getRankIcon(rank), color: Colors.white, size: 10),
                    const SizedBox(width: 3),
                    Text(
                      _getRankText(rank),
                      style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _getRankBorderColor(rank), width: 2.0),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: ClipOval(child: _buildPlayerAvatar(player)),
              ),
              const SizedBox(height: 6),
              Text(
                _getShortName(player.username),
                style: GoogleFonts.quicksand(fontSize: playerNameFontSize, fontWeight: FontWeight.w900, color: Colors.blue.shade900),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Builds points display for all players
  Widget _buildPointsDisplay(CallBreakController controller, bool isSmallScreen) {
    return Container(
      key: const ValueKey('points_container'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.cyan.withOpacity(0.6), width: 0.8),
        boxShadow: [
          BoxShadow(color: Colors.cyan.withOpacity(0.2), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: controller.selectedPlayers.asMap().entries.map((entry) {
          final index = entry.key;
          final totalPoints = controller.getTotalPoints(index);
          final isNegative = totalPoints < 0;
          final isLast = index == controller.selectedPlayers.length - 1;

          return Expanded(
            key: ValueKey('player_points_$index'),
            child: Container(
              height: 32,
              child: Stack(
                children: [
                  Center(
                    child: isNegative
                        ? Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.red, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                totalPoints.abs().toStringAsFixed(1),
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.red),
                              ),
                            ),
                          )
                        : Text(
                            totalPoints.toStringAsFixed(1),
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.purple.shade600),
                          ),
                  ),
                  if (!isLast) Positioned(right: 0, top: 4, bottom: 4, child: Container(width: 0.8, color: Colors.blueAccent.withOpacity(0.4))),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds current bid circle widget
  Widget _buildCurrentBidCircle(int bid, double fontSize, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.4),
      ),
      child: Center(
        child: Text(
          '$bid',
          style: GoogleFonts.poppins(fontSize: fontSize - 1, fontWeight: FontWeight.w800, color: Colors.cyan),
        ),
      ),
    );
  }

  /// Builds round result display
  Widget _buildRoundResult(int bid, int extra, bool failed, double fontSize) {
    if (failed) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.red, width: 1.8),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Text(
            '$bid',
            style: GoogleFonts.poppins(fontSize: fontSize - 1, fontWeight: FontWeight.w800, color: Colors.red),
          ),
        ),
      );
    } else {
      final decimalValue = bid + (extra * 0.1);

      return Container(
        height: 32,
        child: Center(
          child: Text(
            decimalValue.toStringAsFixed(1),
            style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w700, color: extra > 0 ? Colors.green.shade600 : Colors.blue.shade600),
          ),
        ),
      );
    }
  }

  /// Shows edit dialog for completed rounds
  void _showEditRoundDialog(BuildContext context, int roundIndex, RoundData round) {
    showDialog(
      context: context,
      builder: (context) => _EditRoundDialog(tag: widget.tag, roundIndex: roundIndex, round: round),
    );
  }

  /// Shows edit dialog for current bids
  void _showEditCurrentBidDialog(BuildContext context) {
    final controller = Get.find<CallBreakController>(tag: widget.tag);
    final currentRound = RoundData(roundNumber: -1, bids: List.from(controller.currentBids), extras: List.from(controller.currentExtras), points: List.filled(4, 0.0));

    showDialog(
      context: context,
      builder: (context) => _EditRoundDialog(tag: widget.tag, roundIndex: -1, round: currentRound),
    );
  }

  // Helper Methods

  /// Gets color for player based on index
  Color _getPlayerColor(int index) {
    final colors = [Colors.blue.shade700, Colors.purple.shade700, Colors.green.shade700, Colors.orange.shade700, Colors.red.shade700];
    return colors[index % colors.length];
  }

  /// Calculates player rank based on total points
  int _getPlayerRank(CallBreakController controller, int playerIndex) {
    List<Map<String, dynamic>> playersWithPoints = [];

    for (int i = 0; i < controller.selectedPlayers.length; i++) {
      playersWithPoints.add({'index': i, 'points': controller.getTotalPoints(i)});
    }

    playersWithPoints.sort((a, b) => b['points'].compareTo(a['points']));

    for (int i = 0; i < playersWithPoints.length; i++) {
      if (playersWithPoints[i]['index'] == playerIndex) {
        return i;
      }
    }

    return playersWithPoints.length - 1;
  }

  /// Gets gradient for rank badge
  Gradient _getRankGradient(int rank) {
    switch (rank) {
      case 0:
        return LinearGradient(colors: [Colors.amber.shade600, Colors.orange.shade800]);
      case 1:
        return LinearGradient(colors: [Colors.grey.shade500, Colors.grey.shade700]);
      case 2:
        return LinearGradient(colors: [Colors.orange.shade700, Colors.deepOrange.shade800]);
      default:
        return LinearGradient(colors: [Colors.blue.shade500, Colors.blue.shade700]);
    }
  }

  /// Gets color for rank
  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  /// Gets border color for rank
  Color _getRankBorderColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber.shade400;
      case 1:
        return Colors.grey.shade400;
      case 2:
        return Colors.orange.shade400;
      default:
        return Colors.blue.shade400;
    }
  }

  /// Gets icon for rank
  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 0:
        return Icons.emoji_events_rounded;
      case 1:
        return Icons.workspace_premium_rounded;
      case 2:
        return Icons.military_tech_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  /// Gets text for rank
  String _getRankText(int rank) {
    switch (rank) {
      case 0:
        return '1st';
      case 1:
        return '2nd';
      case 2:
        return '3rd';
      default:
        return '${rank + 1}th';
    }
  }

  /// Builds player avatar with profile image or fallback
  Widget _buildPlayerAvatar(User player) {
    if (player.profileImagePath != null && player.profileImagePath!.isNotEmpty) {
      return _buildFileImage(player.profileImagePath!);
    } else {
      return _buildDefaultAvatar(player.username);
    }
  }

  /// Builds file image with error handling
  Widget _buildFileImage(String filePath) {
    final file = File(filePath);

    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar("Error");
        },
      );
    } else {
      return _buildDefaultAvatar("No File");
    }
  }

  /// Builds default avatar with initials
  Widget _buildDefaultAvatar(String username) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: Text(
          _getInitials(username),
          style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  /// Extracts initials from name
  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  /// Gets short name (first name) for display
  String _getShortName(String name) {
    final names = name.split(' ');
    return names.first;
  }
}

/// Dialog for editing round data or current bids
class _EditRoundDialog extends StatefulWidget {
  final String tag;
  final int roundIndex;
  final RoundData round;

  const _EditRoundDialog({required this.tag, required this.roundIndex, required this.round});

  @override
  State<_EditRoundDialog> createState() => _EditRoundDialogState();
}

class _EditRoundDialogState extends State<_EditRoundDialog> {
  late List<TextEditingController> bidControllers;
  late List<TextEditingController> extraControllers;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    bidControllers = [];
    extraControllers = [];

    for (int i = 0; i < 4; i++) {
      bidControllers.add(TextEditingController(text: widget.round.bids[i].toString()));
      extraControllers.add(TextEditingController(text: widget.round.extras[i].toString()));
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (var controller in bidControllers) {
      controller.dispose();
    }
    for (var controller in extraControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Saves round data with validation
  void _saveRoundData(CallBreakController controller) {
    List<int> newBids = [];
    List<int> newExtras = [];
    bool hasError = false;

    for (int i = 0; i < 4; i++) {
      String bidText = bidControllers[i].text;
      String extraText = extraControllers[i].text;

      if (bidText.isEmpty) {
        Get.snackbar('Error', 'Please enter bid for all players', snackPosition: SnackPosition.BOTTOM);
        hasError = true;
        break;
      }

      int? bid = int.tryParse(bidText);
      int? extra = int.tryParse(extraText.isEmpty ? '0' : extraText);

      if (bid == null || extra == null) {
        Get.snackbar('Error', 'Invalid number format', snackPosition: SnackPosition.BOTTOM);
        hasError = true;
        break;
      }

      if (bid < 0 || bid > 13) {
        Get.snackbar('Error', 'Bid must be between 0-13', snackPosition: SnackPosition.BOTTOM);
        hasError = true;
        break;
      }

      if (extra < -13 || extra > 13) {
        Get.snackbar('Error', 'Extra must be between -13 to 13', snackPosition: SnackPosition.BOTTOM);
        hasError = true;
        break;
      }

      newBids.add(bid);
      newExtras.add(extra);
    }

    if (!hasError) {
      if (widget.roundIndex == -1) {
        for (int i = 0; i < 4; i++) {
          controller.currentBids[i] = newBids[i];
          controller.currentExtras[i] = newExtras[i];
        }
        controller.refresh();
      } else {
        controller.updateRound(widget.roundIndex, newBids, newExtras);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallBreakController>(tag: widget.tag);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [_buildHeader(), const SizedBox(height: 12), _buildPlayerInputs(controller), const SizedBox(height: 16), _buildActionButtons(controller)]),
        ),
      ),
    );
  }

  /// Builds dialog header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.edit_rounded, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.roundIndex == -1 ? 'Edit Current Bid' : 'Edit Round ${widget.roundIndex + 1}',
                  style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D21)),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFD1D5DB), width: 0.8),
                  ),
                  child: Text(
                    'Update Scores',
                    style: GoogleFonts.quicksand(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD1D5DB), width: 1.0),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.close, size: 18, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds player inputs section
  Widget _buildPlayerInputs(CallBreakController controller) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
      ),
      child: Column(
        children: [
          ...controller.selectedPlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;

            return Container(
              key: ValueKey('edit_player_$index'),
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD1D5DB), width: 0.8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3, offset: const Offset(0, 1))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD1D5DB).withOpacity(0.8), width: 1.2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 3, offset: const Offset(0, 1))],
                        ),
                        child: ClipOval(child: _buildPlayerAvatar(player)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _getShortName(player.username),
                          style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D21)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildBidInput(index),
                      const SizedBox(width: 6),
                      _buildExtraInput(index),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Builds bid input field
  Widget _buildBidInput(int index) {
    return Expanded(
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.6), width: 1.0),
        ),
        child: TextField(
          controller: bidControllers[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Bid',
            hintStyle: GoogleFonts.poppins(color: const Color(0xFF6B7280).withOpacity(0.6), fontSize: 11),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            isDense: true,
          ),
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1E3A8A)),
          onChanged: (value) {
            if (value.isNotEmpty) {
              int? bidValue = int.tryParse(value);
              if (bidValue != null && (bidValue < 0 || bidValue > 13)) {
                bidControllers[index].text = bidValue < 0 ? '0' : '13';
                bidControllers[index].selection = TextSelection.collapsed(offset: bidControllers[index].text.length);
              }
            }
          },
        ),
      ),
    );
  }

  /// Builds extra input field
  Widget _buildExtraInput(int index) {
    return Expanded(
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.6), width: 1.0),
        ),
        child: TextField(
          controller: extraControllers[index],
          keyboardType: TextInputType.numberWithOptions(signed: true),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'OT',
            hintStyle: GoogleFonts.poppins(color: const Color(0xFF6B7280).withOpacity(0.6), fontSize: 11),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            isDense: true,
          ),
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0E7490)),
          onChanged: (value) {
            if (value.isNotEmpty) {
              int? extraValue = int.tryParse(value);
              if (extraValue != null && (extraValue < -13 || extraValue > 13)) {
                extraControllers[index].text = extraValue < -13 ? '-13' : '13';
                extraControllers[index].selection = TextSelection.collapsed(offset: extraControllers[index].text.length);
              }
            }
          },
        ),
      ),
    );
  }

  /// Builds action buttons
  Widget _buildActionButtons(CallBreakController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFDB2777)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: const Color(0xFFBE185D).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cancel_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Cancel',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: InkWell(
              onTap: () => _saveRoundData(controller),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: const Color(0xFF1E40AF).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Save',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods for _EditRoundDialog

  /// Gets short name for display
  String _getShortName(String name) {
    final names = name.split(' ');
    return names.first;
  }

  /// Builds player avatar
  Widget _buildPlayerAvatar(User player) {
    if (player.profileImagePath != null && player.profileImagePath!.isNotEmpty) {
      return _buildFileImage(player.profileImagePath!);
    } else {
      return _buildDefaultAvatar(player.username);
    }
  }

  /// Builds file image with error handling
  Widget _buildFileImage(String filePath) {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar("Error");
          },
        );
      } else {
        return _buildDefaultAvatar("No File");
      }
    } catch (e) {
      return _buildDefaultAvatar("Error");
    }
  }

  /// Builds default avatar with initials
  Widget _buildDefaultAvatar(String username) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: Text(
          _getInitials(username),
          style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  /// Extracts initials from name
  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return '?';
  }
}
