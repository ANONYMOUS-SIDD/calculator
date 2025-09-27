// widgets/player_cards_grid.dart
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Assuming these models/widgets exist (MUST exist)
import '../model/marriage_game.dart';
import '../model/user_model.dart';
import '../widgets/player_selection_dialog.dart' hide User;

// --- Custom Colors and Styles ---
const Color _primaryDark = Color(0xFF1E3A8A);
const Color _primaryMedium = Color(0xFF2563EB);
const Color _primaryLight = Color(0xFF3B82F6);
const Color _textGrey = Color(0xFF6B7280);
const Color _lightGrey = Color(0xFFF8FAFC);
const Color _borderGrey = Color(0xFFE5E7EB);
const Color _iosBorder = Color(0xFFD1D5DB);
const Color _iosBackground = Color(0xFFF9FAFB);
const Color _doubleeColor = Color(0xFF06B6D4);
const Color _softGreen = Color(0xFF34D399);
const LinearGradient _blueGradient = LinearGradient(colors: [_primaryDark, _primaryMedium, _primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight);
const LinearGradient _seenGradient = LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)], begin: Alignment.topLeft, end: Alignment.bottomRight);
const LinearGradient _winGradient = LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)], begin: Alignment.topLeft, end: Alignment.bottomRight);

class PlayerCardsGrid extends StatefulWidget {
  final List<MarriagePlayer> players;
  final Function(int, double) onPointsChanged;
  final Function(int) onDoubleeToggle;
  final VoidCallback? onActionButtonPressed;
  // Function to handle the player swap/update in the parent component
  final Function(List<User> newPlayers)? onPlayersSwapped;

  const PlayerCardsGrid({super.key, required this.players, required this.onPointsChanged, required this.onDoubleeToggle, this.onActionButtonPressed, this.onPlayersSwapped});

  @override
  State<PlayerCardsGrid> createState() => _PlayerCardsGridState();
}

class _PlayerCardsGridState extends State<PlayerCardsGrid> {
  final List<Map<String, dynamic>> _playerStates = [];

  @override
  void initState() {
    super.initState();
    _initializePlayerStates();
  }

  void _initializePlayerStates() {
    _playerStates.clear();
    for (int i = 0; i < widget.players.length; i++) {
      _playerStates.add({'status': 'Blind', 'points': 0.0});
    }
  }

  @override
  void didUpdateWidget(PlayerCardsGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-initialize internal state if the players list size or identity changes
    if (oldWidget.players.length != widget.players.length || oldWidget.players.map((p) => p.userName).join() != widget.players.map((p) => p.userName).join()) {
      _initializePlayerStates();
    }
  }

  // 🔥 FIXED: Simplified dialog handling for proper UI updates
  // Inside _PlayerCardsGridState class

  // ... (existing code up to _showPlayerSelectionDialog)

  void _showPlayerSelectionDialog(BuildContext context) async {
    // Assuming 'widget.players' is the list of players passed to the current Widget.
    final List<String> currentSelectedNames = widget.players.map((p) => p.userName).toList();
    final int requiredPlayerCount = widget.players.length;

    print('LOG 1: Opening Player Selection Dialog. Required: $requiredPlayerCount. Current: ${currentSelectedNames.length}'); // NEW LOG

    // Show dialog and wait for result
    final List<User>? result = await showDialog<List<User>>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return PlayerSelectionDialog(
          numberOfPlayers: requiredPlayerCount,
          alreadySelectedPlayers: currentSelectedNames,
          // The callback is left empty to avoid double-popping.
          onPlayersConfirmed: (List<User> finalSelection) {},
        );
      },
    );

    print('LOG 2: Dialog returned. Result is null: ${result == null}.'); // NEW LOG

    // If we got a valid result (users confirmed their selection), update the parent and local state
    if (result != null && result.isNotEmpty) {
      print('LOG 3: Successfully received ${result.length} players. Player 1 Name: ${result.first.username}'); // NEW LOG

      // 1. Call the callback function to update the list in the GRANDPARENT widget
      if (widget.onPlayersSwapped != null) {
        // This MUST trigger a setState in the parent!
        widget.onPlayersSwapped!(result);
        print('LOG 5: widget.onPlayersSwapped (Parent/Grandparent callback) called.'); // NEW LOG
      }

      // 🔥 CRITICAL FIX: Add a local setState to force PlayerCardsGrid to rebuild
      // This schedules a rebuild on the next frame, which then triggers didUpdateWidget()
      // to correctly reset _playerStates based on the new widget.players list received from the parent.
      setState(() {
        print('LOG 4: Local setState called in PlayerCardsGrid to trigger rebuild.');
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Players updated successfully!'), duration: Duration(milliseconds: 1500), backgroundColor: Colors.green));
    } else {
      print('LOG 6: Result was null or empty. Selection cancelled.'); // NEW LOG
      // Dialog was dismissed without confirmation
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Player selection cancelled'), duration: Duration(milliseconds: 1000), backgroundColor: Colors.orange));
    }
  }

  // ... (rest of the class remains the same)

  // Updated CupertinoAlertDialog
  void _showDoubleeDialog(int index) {
    final player = widget.players[index];
    final isCurrentlyDoublee = player.isDoublee;
    final actionText = isCurrentlyDoublee ? 'Disable' : 'Enable';
    final confirmationText = isCurrentlyDoublee ? 'Are you sure you want to disable Doublee mode for ${player.userName}?' : 'Are you sure you want to enable Doublee mode for ${player.userName}?';

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Doublee Mode',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18),
        ),
        content: Text(
          confirmationText,
          style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 14),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: CupertinoColors.lightBackgroundGray, fontWeight: FontWeight.w500),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: isCurrentlyDoublee,
            child: Text(
              actionText,
              style: GoogleFonts.poppins(color: isCurrentlyDoublee ? _doubleeColor : _softGreen, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              widget.onDoubleeToggle(index);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(int playerCount) {
    return 2;
  }

  double _getChildAspectRatio(int playerCount) {
    return 0.65;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.players.isEmpty) return const SizedBox();

    final screenWidth = MediaQuery.of(context).size.width;
    final contentPadding = screenWidth > 600 ? 24.0 : 16.0;

    return Container(
      margin: EdgeInsets.all(contentPadding),
      child: Column(
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(gradient: _blueGradient, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.people, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  'Current Players',
                  style: GoogleFonts.inter(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2B)),
                ),
                const Spacer(),

                // Total Count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _iosBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderGrey, width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.inter(fontSize: screenWidth * 0.03, color: _textGrey, fontWeight: FontWeight.w600),
                      ),
                      Container(width: 1.5, height: 14, margin: const EdgeInsets.symmetric(horizontal: 4), color: _borderGrey),
                      Text(
                        '${widget.players.length}',
                        style: GoogleFonts.inter(fontSize: screenWidth * 0.03, color: _textGrey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                // ACTION BUTTON: Swap/Edit Players
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _iosBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderGrey, width: 1.0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      // Calls the method that shows player selection dialog
                      onTap: () => _showPlayerSelectionDialog(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(Icons.swap_horiz, color: _primaryMedium, size: screenWidth * 0.05),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: contentPadding),

          // Players Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _getCrossAxisCount(widget.players.length), crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: _getChildAspectRatio(widget.players.length)),
            itemCount: widget.players.length,
            itemBuilder: (context, index) => _PlayerCard(
              player: widget.players[index],
              index: index,
              status: _playerStates[index]['status'],
              points: _playerStates[index]['points'],
              isDoublee: widget.players[index].isDoublee,
              onStatusChanged: (status) {
                setState(() {
                  _playerStates[index]['status'] = status;
                });
              },
              onPointsChanged: (points) {
                setState(() {
                  _playerStates[index]['points'] = points;
                });
                widget.onPointsChanged(index, points);
              },
              onDoubleeToggle: () => _showDoubleeDialog(index),
            ),
          ),
        ],
      ),
    );
  }
}

// Player Card Widget
class _PlayerCard extends StatefulWidget {
  final MarriagePlayer player;
  final int index;
  final String status;
  final double points;
  final bool isDoublee;
  final Function(String) onStatusChanged;
  final Function(double) onPointsChanged;
  final VoidCallback onDoubleeToggle;

  const _PlayerCard({required this.player, required this.index, required this.status, required this.points, required this.isDoublee, required this.onStatusChanged, required this.onPointsChanged, required this.onDoubleeToggle});

  @override
  State<_PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<_PlayerCard> {
  late TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _pointsController = TextEditingController(text: widget.points == 0.0 ? '' : widget.points.toInt().toString());
  }

  @override
  void didUpdateWidget(covariant _PlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _pointsController.text = widget.points == 0.0 ? '' : widget.points.toInt().toString();
    }
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Win':
        return const Color(0xFF10B981);
      case 'Seen':
        return const Color(0xFF8B5CF6);
      case 'Blind':
      default:
        return _primaryLight;
    }
  }

  Widget _buildStatusOption(BuildContext context, String option) {
    final isSelected = widget.status == option;
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.023;

    LinearGradient? gradient;
    if (isSelected) {
      if (option == 'Win') {
        gradient = _winGradient;
      } else if (option == 'Seen') {
        gradient = _seenGradient;
      } else if (option == 'Blind') {
        gradient = _blueGradient;
      }
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onStatusChanged(option),
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              gradient: gradient,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isSelected ? Colors.transparent : _iosBorder, width: 1.0),
              boxShadow: isSelected ? [BoxShadow(color: _getStatusColor(option).withOpacity(0.3), blurRadius: 3, offset: const Offset(0, 2))] : null,
            ),
            child: Center(
              child: Text(
                option,
                style: GoogleFonts.inter(fontSize: fontSize < 9.0 ? 9.0 : fontSize, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF374151)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardRadius = 12.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(color: _primaryMedium.withOpacity(0.1), spreadRadius: 1, blurRadius: 2, offset: const Offset(0, 0)),
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: _borderGrey.withOpacity(0.5), width: 0.5),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Profile Photo Section
              Flexible(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: _lightGrey,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius - 1)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius - 1)),
                    child: widget.player.userImage != null
                        ? Image.file(File(widget.player.userImage!), fit: BoxFit.cover, alignment: Alignment.center)
                        : Center(
                            child: Icon(Icons.person_rounded, size: screenWidth * 0.15, color: _primaryDark.withOpacity(0.7)),
                          ),
                  ),
                ),
              ),

              // Content Area
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 2. User Name
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: _iosBackground,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _borderGrey, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline, size: screenWidth * 0.035, color: _primaryDark),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.player.userName,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontSize: screenWidth * 0.035, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D2B)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. Status Selector
                      Container(
                        height: 32,
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: _iosBackground,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _iosBorder, width: 1.0),
                        ),
                        child: Row(children: ['Blind', 'Seen', 'Win'].map((option) => _buildStatusOption(context, option)).toList()),
                      ),

                      const SizedBox(height: 5),

                      // 4 & 5. Points Input and Doublee Switch
                      Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _iosBorder, width: 1),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1))],
                        ),
                        child: Row(
                          children: [
                            // Points Input
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.monetization_on_outlined, size: 16, color: _textGrey),
                                  Container(height: 20, width: 1, margin: const EdgeInsets.symmetric(horizontal: 6), color: _borderGrey),
                                  Expanded(
                                    child: TextField(
                                      controller: _pointsController,
                                      textAlign: TextAlign.right,
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.inter(fontSize: screenWidth * 0.03, fontWeight: FontWeight.w600, color: _primaryDark),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        hintText: '0',
                                        hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
                                      ),
                                      onChanged: (value) {
                                        widget.onPointsChanged(int.tryParse(value)?.toDouble() ?? 0.0);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8), // Spacer to push switch to right
                            // Doublee Switch - Pushed to the far right
                            Transform.scale(
                              scale: 0.65,
                              child: CupertinoSwitch(value: widget.isDoublee, onChanged: (_) => widget.onDoubleeToggle(), activeColor: _doubleeColor, trackColor: _iosBorder, thumbColor: widget.isDoublee ? CupertinoColors.white : _textGrey, key: ValueKey(widget.isDoublee)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Doublee Badge
          if (widget.isDoublee)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_doubleeColor, Color(0xFF22D3EE)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '2x',
                  style: GoogleFonts.inter(fontSize: screenWidth * 0.025, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
