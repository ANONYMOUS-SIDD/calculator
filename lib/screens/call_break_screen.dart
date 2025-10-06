import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:numberpicker/numberpicker.dart';

import '../model/user_model.dart';
import '../screens/user_app_bar.dart';
import '../widgets/player_selection_dialog.dart';

class CallBreakScreen extends StatefulWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  const CallBreakScreen({super.key, required this.tag, required this.color, required this.iconData});

  @override
  State<CallBreakScreen> createState() => _CallBreakScreenState();
}

class _CallBreakScreenState extends State<CallBreakScreen> {
  List<User> _selectedPlayers = [];
  List<RoundData> _rounds = [];
  int _currentRound = 1;
  bool _gameStarted = false;
  bool _isLoading = true;
  bool _bidPhase = false;
  bool _otPhase = false;
  List<int> _currentBids = [1, 1, 1, 1];
  List<int> _currentExtras = [0, 0, 0, 0];
  List<bool> _bidCompleted = [false, false, false, false];
  List<bool> _otCompleted = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      if (!Hive.isBoxOpen('callBreakGames')) {
        await Hive.openBox('callBreakGames');
      }
      _loadSavedGame();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadSavedGame() {
    try {
      final callBreakBox = Hive.box('callBreakGames');
      final savedGame = callBreakBox.get('currentGame');

      if (savedGame != null) {
        setState(() {
          _selectedPlayers = List<User>.from(savedGame['players'] ?? []);
          _rounds = List<RoundData>.from((savedGame['rounds'] as List).map((e) => RoundData.fromJson(e)) ?? []);
          _currentRound = savedGame['currentRound'] ?? 1;
          _gameStarted = savedGame['gameStarted'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveGame() {
    try {
      final callBreakBox = Hive.box('callBreakGames');
      callBreakBox.put('currentGame', {'players': _selectedPlayers, 'rounds': _rounds.map((round) => round.toJson()).toList(), 'currentRound': _currentRound, 'gameStarted': _gameStarted});
    } catch (e) {
      print('Error saving game: $e');
    }
  }

  void _showPlayerSelectionDialog() {
    Get.dialog(PlayerSelectionDialog(numberOfPlayers: 4, alreadySelectedPlayers: _selectedPlayers.map((user) => user.username).toList()), barrierDismissible: false).then((selectedPlayers) {
      if (selectedPlayers != null && selectedPlayers is List<User>) {
        setState(() {
          _selectedPlayers = selectedPlayers;
          _gameStarted = true;
          _rounds.clear();
          _currentRound = 1;
          _resetCurrentRound();
        });
        _saveGame();
      }
    });
  }

  void _resetCurrentRound() {
    setState(() {
      _currentBids = [1, 1, 1, 1];
      _currentExtras = [0, 0, 0, 0];
      _bidCompleted = [false, false, false, false];
      _otCompleted = [false, false, false, false];
      _bidPhase = false;
      _otPhase = false;
    });
  }

  void _startRound() {
    setState(() {
      _bidPhase = true;
      _otPhase = false;
    });
  }

  void _finishBidPhase() {
    if (_bidCompleted.every((completed) => completed)) {
      setState(() {
        _bidPhase = false;
        _otPhase = true;
      });
    } else {
      _showToast('All players must place their bids first');
    }
  }

  void _finishRound() {
    if (_otCompleted.every((completed) => completed)) {
      final points = List<int>.generate(4, (index) {
        final bid = _currentBids[index];
        final extra = _currentExtras[index];

        if (extra < bid) {
          return -bid;
        } else {
          return bid + (extra - bid);
        }
      });

      final roundData = RoundData(roundNumber: _currentRound, bids: List.from(_currentBids), extras: List.from(_currentExtras), points: points);

      setState(() {
        _rounds.add(roundData);
        _currentRound++;
        _resetCurrentRound();
      });
      _saveGame();
    } else {
      _showToast('All players must complete their OT first');
    }
  }

  void _showBidPicker(int playerIndex) {
    int currentBid = 2; // initial bid

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double dialogWidth = MediaQuery.of(context).size.width * 0.75;

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: dialogWidth,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 6))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Section: Icon + "Bid Selection"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_esports_rounded, color: Colors.blue.shade700, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          'BID SELECTION',
                          style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Player Name Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.shade400, width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.teal.shade100.withOpacity(0.7), blurRadius: 8, spreadRadius: 1)],
                      ),
                      child: Text(
                        _selectedPlayers[playerIndex].username,
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.teal.shade700),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Current Bid Bubble
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.lightBlue.shade300], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        boxShadow: [BoxShadow(color: Colors.blue.shade200.withOpacity(0.6), blurRadius: 12, spreadRadius: 1)],
                        border: Border.all(color: Colors.blue.shade400, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          '$currentBid',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Compact Number Picker
                    Container(
                      width: 60, // reduced width
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade300, width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.blue.shade100.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)],
                      ),
                      child: NumberPicker(
                        value: currentBid,
                        minValue: 1,
                        maxValue: 13,
                        itemHeight: 40,
                        itemWidth: 45,
                        axis: Axis.vertical,
                        textStyle: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[400], fontWeight: FontWeight.w500),
                        selectedTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.blue.shade700),
                        onChanged: (value) {
                          setState(() {
                            currentBid = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Redesigned Responsive Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [Colors.red.shade400, Colors.red.shade600], // danger gradient
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.zero,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [Colors.green.shade400, Colors.green.shade600], // verified gradient
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentBids[playerIndex] = currentBid;
                                  _bidCompleted[playerIndex] = true;
                                });
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.zero,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.verified, size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Confirm',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showOTPicker(int playerIndex) {
    int currentExtra = 0; // initial extra
    final bid = _currentBids[playerIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double dialogWidth = MediaQuery.of(context).size.width * 0.78;

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: dialogWidth,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calculate_rounded, color: Colors.green.shade700, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          'OT SELECTION',
                          style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Player Name Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade400, width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.green.shade100.withOpacity(0.7), blurRadius: 8, spreadRadius: 1)],
                      ),
                      child: Text(
                        _selectedPlayers[playerIndex].username,
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.green.shade700),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Current Extra Bubble
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade300], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        boxShadow: [BoxShadow(color: Colors.green.shade200.withOpacity(0.6), blurRadius: 12, spreadRadius: 1)],
                        border: Border.all(color: Colors.green.shade400, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          '$currentExtra',
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Number Picker Container
                    Container(
                      width: 60, // compact width
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300, width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.green.shade100.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)],
                      ),
                      child: NumberPicker(
                        value: currentExtra,
                        minValue: 0,
                        maxValue: 13,
                        itemHeight: 40,
                        itemWidth: 45,
                        axis: Axis.vertical,
                        textStyle: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[400], fontWeight: FontWeight.w500),
                        selectedTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.green.shade700),
                        onChanged: (value) {
                          setState(() {
                            currentExtra = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.orange.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _currentExtras[playerIndex] = bid;
                                  _otCompleted[playerIndex] = true;
                                });
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.shield_rounded, size: 16, color: Colors.white),
                              label: Text(
                                'Tight',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _currentExtras[playerIndex] = 0;
                                  _otCompleted[playerIndex] = true;
                                });
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.error_outline, size: 16, color: Colors.white),
                              label: Text(
                                'Failed',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Main Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: TextButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.grey),
                              label: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey[700]),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _currentExtras[playerIndex] = currentExtra;
                                  _otCompleted[playerIndex] = true;
                                });
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.verified, size: 16, color: Colors.white),
                              label: Text(
                                'Confirm',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showToast(String message) {
    Get.dialog(
      Container(
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.7), width: 1.2),
              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_rounded, color: Colors.red, size: 22),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    message,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: false,
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (Get.isDialogOpen!) Get.back();
    });
  }

  void _resetGame() {
    setState(() {
      _selectedPlayers.clear();
      _rounds.clear();
      _currentRound = 1;
      _gameStarted = false;
      _resetCurrentRound();
    });
    _saveGame();
  }

  int _getTotalPoints(int playerIndex) {
    return _rounds.fold(0, (total, round) => total + round.points[playerIndex]);
  }

  Widget _buildPlayerCard(int index) {
    final player = _selectedPlayers[index];
    final totalPoints = _getTotalPoints(index);
    final roundPoints = _rounds.isNotEmpty ? _rounds.last.points[index] : 0;
    final currentBid = _currentBids[index];
    final currentExtra = _currentExtras[index];
    final bidCompleted = _bidCompleted[index];
    final otCompleted = _otCompleted[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Player Profile
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.withOpacity(0.2), width: 1.2),
              boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 1))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: player.profileImagePath != null
                  ? Image.asset(
                      player.profileImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: Colors.deepPurple, size: 20),
                    )
                  : Icon(Icons.person, color: Colors.deepPurple, size: 20),
            ),
          ),
          const SizedBox(width: 10),

          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player Name
                Text(
                  player.username,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue.shade900),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Total & Last Section (Single Compact Container)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.cyan.withOpacity(0.6), width: 1),
                    boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.25), blurRadius: 2, spreadRadius: 0.2, offset: const Offset(0, 1))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Total
                      Row(
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 2),
                          Container(
                            width: 1,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(color: Colors.cyan, borderRadius: BorderRadius.circular(0.5)),
                          ),
                          Text(
                            '$totalPoints',
                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: totalPoints >= 0 ? Colors.green : Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),

                      // Last
                      Row(
                        children: [
                          Text(
                            'Last',
                            style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 2),
                          Container(
                            width: 1,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(color: Colors.cyan, borderRadius: BorderRadius.circular(0.5)),
                          ),
                          Text(
                            '$roundPoints',
                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: roundPoints >= 0 ? Colors.cyan : Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Bid & OT Buttons (Compact & Gradient)
          Row(
            children: [
              // Bid Button
              Container(
                width: 56,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: _bidPhase && !bidCompleted ? const LinearGradient(colors: [Color(0xFFFF4081), Color(0xFFF50057)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                ),
                child: ElevatedButton(
                  onPressed: _bidPhase && !bidCompleted ? () => _showBidPicker(index) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flag, size: 14, color: _bidPhase && !bidCompleted ? Colors.white : Colors.grey[400]),
                      const SizedBox(width: 2),
                      Text(
                        'BID',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _bidPhase && !bidCompleted ? Colors.white : Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // OT Button
              Container(
                width: 56,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: _otPhase && !otCompleted ? const LinearGradient(colors: [Color(0xFFFF4081), Color(0xFFF50057)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                ),
                child: ElevatedButton(
                  onPressed: _otPhase && !otCompleted ? () => _showOTPicker(index) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.trending_up, size: 14, color: _otPhase && !otCompleted ? Colors.white : Colors.grey[400]),
                      const SizedBox(width: 2),
                      Text(
                        'OT',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _otPhase && !otCompleted ? Colors.white : Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundHistory() {
    if (_rounds.isEmpty && !_bidCompleted.any((completed) => completed)) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.purple.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Icon(Icons.leaderboard, color: Colors.purple, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                "Round History",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.purple),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Text(
                      "Round",
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.purple),
                    ),
                    const SizedBox(width: 3),
                    Container(width: 1, height: 8, color: Colors.purple.withOpacity(0.4)),
                    const SizedBox(width: 3),
                    Text(
                      '$_currentRound',
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.purple),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.3))),
            ),
            child: Row(
              children: _selectedPlayers.map((player) {
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: player.profileImagePath != null
                              ? Image.asset(
                                  player.profileImagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.person, color: Colors.blueAccent, size: 16);
                                  },
                                )
                              : Icon(Icons.person, color: Colors.blueAccent, size: 16),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        player.username.split(' ').first,
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Current Bids Row (Show even if round not finished)
          if (_bidCompleted.any((completed) => completed)) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
              ),
              child: Row(
                children: _currentBids.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bid = entry.value;
                  final bidCompleted = _bidCompleted[index];

                  return Expanded(
                    child: Center(
                      child: bidCompleted
                          ? Text(
                              '$bid',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange),
                            )
                          : Text(
                              '-',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[400]),
                            ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // Completed Rounds
          ..._rounds.map((round) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
              ),
              child: Row(
                children: round.bids.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bid = entry.value;
                  final extra = round.extras[index];
                  final failed = extra < bid;

                  return Expanded(
                    child: Center(
                      child: failed
                          ? Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.red, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  '$bid',
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red),
                                ),
                              ),
                            )
                          : Text(
                              '$bid${extra > bid
                                  ? '.${extra - bid}'
                                  : extra == bid
                                  ? '.0'
                                  : ''}',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: extra > bid ? Colors.green : Colors.blue),
                            ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),

          // Total Points Section (Separate Container)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: _selectedPlayers.asMap().entries.map((entry) {
                final index = entry.key;
                final totalPoints = _getTotalPoints(index);
                return Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (totalPoints < 0) Icon(Icons.arrow_downward, size: 12, color: Colors.red),
                            Text(
                              '${totalPoints.abs()}',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: totalPoints >= 0 ? Colors.green : Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewGameButton(double height, double fontSize, double iconSize) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [Colors.pinkAccent.shade200, Colors.pinkAccent.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _resetGame,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh_rounded, size: iconSize, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                "NEW GAME",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: fontSize, color: Colors.white, letterSpacing: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundButton(double height, double fontSize, double iconSize) {
    final bool canStartRound = _selectedPlayers.isNotEmpty && _currentRound <= 5 && !_bidPhase && !_otPhase;
    final bool canFinishBid = _bidPhase && _bidCompleted.every((completed) => completed);
    final bool canFinishRound = _otPhase && _otCompleted.every((completed) => completed);

    String buttonText = 'START ROUND $_currentRound';
    VoidCallback? onPressed;
    Color backgroundColor = Colors.blueAccent;
    IconData icon = Icons.play_arrow;

    if (canStartRound) {
      buttonText = 'START ROUND $_currentRound';
      onPressed = _startRound;
      backgroundColor = Colors.blueAccent;
      icon = Icons.play_arrow;
    } else if (canFinishBid) {
      buttonText = 'FINISH BIDDING';
      onPressed = _finishBidPhase;
      backgroundColor = Colors.orange;
      icon = Icons.flag;
    } else if (canFinishRound) {
      buttonText = 'FINISH ROUND $_currentRound';
      onPressed = _finishRound;
      backgroundColor = Colors.green;
      icon = Icons.check;
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: onPressed != null ? LinearGradient(colors: [backgroundColor, Color.alphaBlend(backgroundColor.withOpacity(0.8), backgroundColor)], begin: Alignment.topLeft, end: Alignment.bottomRight) : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: onPressed != null ? [BoxShadow(color: backgroundColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))] : [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                buttonText,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: fontSize, color: Colors.white, letterSpacing: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth < 400 ? 12.0 : 16.0;
    final buttonHeight = screenHeight < 700 ? 40.0 : 42.0;
    final buttonFontSize = screenWidth < 350 ? 11.0 : 13.0;
    final iconSize = screenWidth < 350 ? 16.0 : 18.0;

    if (_isLoading) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFF),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        floatingActionButton: _selectedPlayers.isEmpty
            ? FloatingActionButton(
                onPressed: _showPlayerSelectionDialog,
                backgroundColor: Colors.blueAccent,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0066FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.group_add, color: Colors.white, size: 28),
                ),
              )
            : null,
        body: Column(
          children: [
            const UserAppBar(title: "Call Break"),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    // Top Players Section
                    if (_selectedPlayers.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            // Rectangular Player Icon Container
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.purple.shade300, width: 1.2),
                                boxShadow: [BoxShadow(color: Colors.purple.shade100.withOpacity(0.5), blurRadius: 8, spreadRadius: 0.5, offset: const Offset(0, 3))],
                                color: Colors.white,
                              ),
                              child: const Center(child: Icon(Icons.people_alt_rounded, color: Colors.pink, size: 24)),
                            ),
                            const SizedBox(width: 10),

                            // Players Text as Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange.shade400, width: 1.2),
                                boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.4), blurRadius: 8, spreadRadius: 0.5, offset: const Offset(0, 2))],
                                color: Colors.white,
                              ),
                              child: Text(
                                "PLAYERS",
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue, letterSpacing: 1.2),
                              ),
                            ),
                            const Spacer(),

                            // Round Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.cyan.shade300, width: 1.2),
                                boxShadow: [BoxShadow(color: Colors.cyan.shade100.withOpacity(0.4), blurRadius: 8, spreadRadius: 0.5, offset: const Offset(0, 2))],
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Round",
                                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.cyan.shade600),
                                  ),
                                  const SizedBox(width: 3),
                                  Container(width: 1, height: 10, color: Colors.cyan.shade200.withOpacity(0.5)),
                                  const SizedBox(width: 3),
                                  Text(
                                    '$_currentRound',
                                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.cyan.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Player Cards Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Column(children: [..._selectedPlayers.asMap().entries.map((entry) => _buildPlayerCard(entry.key))]),
                      ),

                      // Round History
                      _buildRoundHistory(),
                    ],

                    // Empty State
                    if (_selectedPlayers.isEmpty) ...[
                      const SizedBox(height: 80),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
                        ),
                        child: Icon(Icons.people_outline, size: 60, color: Colors.blueAccent.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "No Players Selected",
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap the + button to select 4 players",
                        style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            if (_selectedPlayers.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: screenHeight < 700 ? 8.0 : 12.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 25, spreadRadius: 1, offset: const Offset(0, -6))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: screenWidth < 350 ? 8.0 : 12.0, vertical: screenHeight < 700 ? 8.0 : 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(colors: [Colors.grey.shade50, Colors.grey.shade100], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 6))],
                      ),
                      child: screenWidth < 350
                          ? Column(children: [_buildNewGameButton(buttonHeight, buttonFontSize, iconSize), const SizedBox(height: 10), _buildRoundButton(buttonHeight, buttonFontSize, iconSize)])
                          : Row(
                              children: [
                                Expanded(child: _buildNewGameButton(buttonHeight, buttonFontSize, iconSize)),
                                SizedBox(width: screenWidth < 400 ? 10.0 : 14.0),
                                Expanded(child: _buildRoundButton(buttonHeight, buttonFontSize, iconSize)),
                              ],
                            ),
                    ),
                    SizedBox(height: screenHeight < 700 ? 4.0 : 6.0),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RoundData {
  final int roundNumber;
  final List<int> bids;
  final List<int> extras;
  final List<int> points;

  RoundData({required this.roundNumber, required this.bids, required this.extras, required this.points});

  Map<String, dynamic> toJson() => {'roundNumber': roundNumber, 'bids': bids, 'extras': extras, 'points': points};

  factory RoundData.fromJson(Map<String, dynamic> json) => RoundData(roundNumber: json['roundNumber'], bids: List<int>.from(json['bids']), extras: List<int>.from(json['extras']), points: List<int>.from(json['points']));
}
