import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/call_break_controller.dart';
import '../../model/round_data.dart';
import '../../model/user_model.dart';

class RoundHistory extends StatefulWidget {
  final String tag;

  const RoundHistory({super.key, required this.tag});

  @override
  State<RoundHistory> createState() => _RoundHistoryState();
}

class _RoundHistoryState extends State<RoundHistory> {
  // Store MediaQuery to avoid looking up deactivated widgets
  MediaQueryData? _mediaQuery;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache MediaQuery in didChangeDependencies to safely access it later
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
        margin: const EdgeInsets.only(top: 8, bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 25, spreadRadius: 3, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 2),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.blue.shade50, Colors.purple.shade50]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Players Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.purple.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14),
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
                        // Circular Player Avatar
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

                        // Player Name with Deep Blue Color
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
            ),

            // Completed Rounds with Long Press to Edit
            ...controller.rounds.asMap().entries.map((roundEntry) {
              final roundIndex = roundEntry.key;
              final round = roundEntry.value;

              return GestureDetector(
                key: ValueKey('round_${roundIndex}_${round.hashCode}'), // Unique key for each round
                onLongPress: () {
                  _showEditRoundDialog(context, roundIndex, round);
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      // Round Results
                      ...round.bids.asMap().entries.map((entry) {
                        final index = entry.key;
                        final bid = entry.value;
                        final extra = round.extras[index];
                        final totalTricks = bid + extra;
                        final failed = totalTricks < bid;

                        return Expanded(
                          key: ValueKey('round_result_${roundIndex}_$index'), // Unique key for each result
                          child: Center(child: _buildRoundResult(bid, extra, failed, valueFontSize)),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),

            // Current Bids with OT Values Display
            if (controller.bidCompleted.any((completed) => completed) || controller.currentBids.any((bid) => bid > 0)) ...[
              const SizedBox(height: 8),
              Container(
                key: const ValueKey('current_bids_container'), // Unique key
                margin: const EdgeInsets.only(top: 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink.withOpacity(0.3), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    ...controller.currentBids.asMap().entries.map((entry) {
                      final index = entry.key;
                      final bid = entry.value;
                      final extra = controller.currentExtras[index];
                      final bidCompleted = controller.bidCompleted[index];
                      final hasExtra = extra > 0;

                      return Expanded(
                        key: ValueKey('current_bid_$index'), // Unique key
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
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.purple, width: 2.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$bid',
                                            style: GoogleFonts.poppins(fontSize: valueFontSize, fontWeight: FontWeight.w800, color: Colors.purple.shade700),
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.pink.withOpacity(0.6), width: 2.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$bid',
                                            style: GoogleFonts.poppins(fontSize: valueFontSize, fontWeight: FontWeight.w800, color: Colors.pink.shade700),
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              : Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.pink.withOpacity(0.6), width: 2.0),
                                  ),
                                  child: const SizedBox(),
                                ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],

            // Updated Final Score Section
            if (controller.rounds.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                key: const ValueKey('final_score_container'), // Unique key
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                  border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                ),
                child: Column(
                  children: [
                    // Player Profiles and Names Row
                    Row(
                      children: controller.selectedPlayers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final player = entry.value;
                        final rank = _getPlayerRank(controller, index);

                        return Expanded(
                          key: ValueKey('player_rank_$index'), // Unique key
                          child: Column(
                            children: [
                              // Ranking Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: _getRankGradient(rank),
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                                  boxShadow: [BoxShadow(color: _getRankColor(rank).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_getRankIcon(rank), color: Colors.white, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getRankText(rank),
                                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),

                              // Player Avatar
                              Container(
                                width: 56,
                                height: 56,
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _getRankBorderColor(rank), width: 2.5),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
                                ),
                                child: ClipOval(child: _buildPlayerAvatar(player)),
                              ),
                              const SizedBox(height: 8),

                              // Player Name
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

                    const SizedBox(height: 12),

                    // Points Container
                    Container(
                      key: const ValueKey('points_container'), // Unique key
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
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
                            key: ValueKey('player_points_$index'), // Unique key
                            child: Container(
                              height: 28,
                              child: Stack(
                                children: [
                                  Center(
                                    child: isNegative
                                        ? Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.red, width: 1.5),
                                            ),
                                            child: Center(
                                              child: Text(
                                                totalPoints.abs().toStringAsFixed(1),
                                                style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.red),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            totalPoints.toStringAsFixed(1),
                                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green.shade600),
                                          ),
                                  ),
                                  if (!isLast) Positioned(right: 0, top: 6, bottom: 6, child: Container(width: 0.8, color: Colors.blueAccent.withOpacity(0.4))),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // Updated Edit Round Dialog Method with proper controller management
  void _showEditRoundDialog(BuildContext context, int roundIndex, RoundData round) {
    final controller = Get.find<CallBreakController>(tag: widget.tag);

    showDialog(
      context: context,
      builder: (context) => _EditRoundDialog(tag: widget.tag, roundIndex: roundIndex, round: round),
    );
  }

  // ... (rest of your helper methods remain the same)
  Color _getPlayerColor(int index) {
    final colors = [Colors.blue.shade700, Colors.purple.shade700, Colors.green.shade700, Colors.orange.shade700, Colors.red.shade700];
    return colors[index % colors.length];
  }

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

  Widget _buildPlayerAvatar(User player) {
    if (player.profileImagePath != null && player.profileImagePath!.isNotEmpty) {
      return _buildFileImage(player.profileImagePath!);
    } else {
      return _buildDefaultAvatar(player.username);
    }
  }

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

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  String _getShortName(String name) {
    final names = name.split(' ');
    return names.first;
  }

  Widget _buildRoundResult(int bid, int extra, bool failed, double fontSize) {
    if (failed) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.red, width: 2.0),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Text(
            '$bid',
            style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w800, color: Colors.red),
          ),
        ),
      );
    } else {
      final decimalValue = bid + (extra * 0.1);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            decimalValue.toStringAsFixed(1),
            style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w700, color: extra > 0 ? Colors.green.shade600 : Colors.blue.shade600),
          ),
        ],
      );
    }
  }
}

// Separate StatefulWidget for the dialog to manage controllers properly
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
    // Initialize controllers
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
    // Dispose all controllers
    for (var controller in bidControllers) {
      controller.dispose();
    }
    for (var controller in extraControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Safe method to check if still mounted
  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallBreakController>(tag: widget.tag);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Round ${widget.roundIndex + 1}',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.blue.shade800),
            ),
            const SizedBox(height: 16),

            // Player inputs
            ...controller.selectedPlayers.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;

              return Padding(
                key: ValueKey('edit_player_$index'), // Unique key
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    // Player name
                    Expanded(
                      flex: 2,
                      child: Text(
                        _getShortName(player.username),
                        style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.blue.shade900),
                      ),
                    ),

                    // Bid input
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: TextField(
                          controller: bidControllers[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Bid', contentPadding: EdgeInsets.only(bottom: 12)),
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue.shade800),
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
                    ),

                    const SizedBox(width: 8),

                    // Extra input
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: TextField(
                          controller: extraControllers[index],
                          keyboardType: TextInputType.numberWithOptions(signed: true),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Extra', contentPadding: EdgeInsets.only(bottom: 12)),
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade800),
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
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 12),

            // Instructions
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Text(
                    'Bid: 0-13 | Extra: -13 to 13',
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Negative extra = failed bid',
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.red.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _saveRoundData(controller);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Save',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
      controller.updateRound(widget.roundIndex, newBids, newExtras);
      Navigator.of(context).pop();
    }
  }

  String _getShortName(String name) {
    final names = name.split(' ');
    return names.first;
  }
}
