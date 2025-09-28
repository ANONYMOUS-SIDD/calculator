// widgets/player_cards_grid.dart (Final Fix for Confirmation Flicker and Signature Update)

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/player_controller.dart';
import '../model/marriage_game.dart';
import '../model/user_model.dart' as PlayerDialog;
import '../widgets/player_selection_dialog.dart' as PlayerDialog;

// --- Custom Colors and Styles (REMAINS UNCHANGED) ---
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
const Color _darkText = Color(0xFF1A1D2B); // Changed to match common dark text
const LinearGradient _blueGradient = LinearGradient(colors: [_primaryDark, _primaryMedium, _primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight);
const LinearGradient _seenGradient = LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)], begin: Alignment.topLeft, end: Alignment.bottomRight);
const LinearGradient _winGradient = LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)], begin: Alignment.topLeft, end: Alignment.bottomRight);

class PlayerCardsGrid extends StatefulWidget {
  // ✅ FIX: Changed signatures to use String (player identifier) instead of int (index)
  final Function(String, double) onPointsChanged;
  final Function(String) onDoubleeToggle;
  final VoidCallback? onActionButtonPressed;

  const PlayerCardsGrid({super.key, required this.onPointsChanged, required this.onDoubleeToggle, this.onActionButtonPressed});

  @override
  State<PlayerCardsGrid> createState() => _PlayerCardsGridState();
}

class _PlayerCardsGridState extends State<PlayerCardsGrid> {
  final PlayerController _playerController = Get.find<PlayerController>();
  final List<Map<String, dynamic>> _playerStates = [];
  late Worker _playerListListener;
  bool _hasAttemptedInitialLoad = false;

  // 🔥 Flag to prevent the empty state flicker after successful dialog close
  bool _justConfirmedPlayers = false;

  @override
  void initState() {
    super.initState();

    _initializePlayerStates(_playerController.players.length);

    _playerListListener = ever(_playerController.players, (_) {
      setState(() {
        final newCount = _playerController.players.length;
        debugPrint('PlayerCardsGrid: Listener triggered. Resetting local _playerStates to count: $newCount');

        // Reset the flag only when the Obx fires, indicating the players list has updated
        _justConfirmedPlayers = false;

        // Reset local state (status/points) when the player list changes
        _playerStates.clear();
        for (int i = 0; i < newCount; i++) {
          _playerStates.add({'status': 'Blind', 'points': 0.0});
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialPlayers();
    });
  }

  void _initializePlayerStates(int playerCount) {
    if (_playerStates.isEmpty) {
      debugPrint('PlayerCardsGrid: Initializing local _playerStates with count: $playerCount');
      _playerStates.clear();
      for (int i = 0; i < playerCount; i++) {
        _playerStates.add({'status': 'Blind', 'points': 0.0});
      }
    }
  }

  void _checkInitialPlayers() {
    if (!_hasAttemptedInitialLoad && _playerController.players.isEmpty) {
      _hasAttemptedInitialLoad = true;
      debugPrint('PlayerCardsGrid: Initial player list is empty. Prompting user to select players.');
    }
  }

  @override
  void dispose() {
    _playerListListener.dispose();
    super.dispose();
  }

  // Method to open the player selection dialog
  void _showPlayerSelectionDialog(BuildContext context) async {
    final List<MarriagePlayer> currentPlayers = _playerController.players.toList();

    // Use the *target* number of players set in ModernGameSetup. Since we don't have that
    // property here, we'll use the current list length (if non-empty) or default to 4.
    // This logic relies on the parent component (`MarriageScreen` via `ModernGameSetup`)
    // setting the player count in the PlayerController first.
    final int requiredPlayerCount = currentPlayers.isNotEmpty ? currentPlayers.length : 4;

    // Use the player's userId/userName as the stable identifier
    final List<String> currentSelectedNames = currentPlayers.map((p) => p.userName).toList();

    final List<PlayerDialog.User>? result = await showDialog<List<PlayerDialog.User>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return PlayerDialog.PlayerSelectionDialog(
          numberOfPlayers: requiredPlayerCount,
          alreadySelectedPlayers: currentSelectedNames,
          // ❌ FIX: Removed the redundant 'onPlayersConfirmed' callback here.
          // The result is returned via Navigator.pop/Get.back.
          // onPlayersConfirmed: (List<PlayerDialog.User> finalSelection) { ... }
        );
      },
    );

    // 🔥 FIX: Set the flag on successful confirmation and update the controller.
    if (result != null && result.isNotEmpty) {
      // 1. Update the controller with the confirmed user list
      _playerController.updatePlayersFromUsers(result);

      // 2. Set flag immediately to bypass empty state check in the next build
      setState(() {
        _justConfirmedPlayers = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Players updated successfully!'), duration: Duration(milliseconds: 1500), backgroundColor: _softGreen));
    } else if (result == null) {
      // Only show cancellation snackbar if the list was already populated
      if (currentPlayers.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Player selection cancelled'), duration: Duration(milliseconds: 1000), backgroundColor: Colors.orange));
      }
    }
  }

  void _showDoubleeDialog(MarriagePlayer player) {
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
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: CupertinoColors.white, fontWeight: FontWeight.w500),
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
              // ✅ FIX: Use the player's stable identifier (userName)
              widget.onDoubleeToggle(player.userName);
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
    return Obx(() {
      final players = _playerController.players;

      // 🔥 FIX: Only show the empty state if the list is empty AND we didn't just confirm a selection.
      if (players.isEmpty && !_justConfirmedPlayers) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search, size: 60, color: _textGrey.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'Please select ${players.isEmpty ? 'players' : players.length} to start the game.',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: _textGrey),
                ),
                const SizedBox(height: 20),
                // Button to explicitly open the dialog
                ElevatedButton.icon(
                  onPressed: () => _showPlayerSelectionDialog(context),
                  icon: const Icon(Icons.group_add, color: Colors.white),
                  label: Text('Select Players', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryMedium,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // --- Grid Content (when players are selected or just confirmed) ---
      final screenWidth = MediaQuery.of(context).size.width;
      final contentPadding = screenWidth > 600 ? 24.0 : 16.0;

      return Container(
        margin: EdgeInsets.all(contentPadding),
        child: Column(
          children: [
            // Section Header (omitted for brevity, remains unchanged)
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
                          '${players.length}',
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _getCrossAxisCount(players.length), crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: _getChildAspectRatio(players.length)),
              itemCount: players.length,
              itemBuilder: (context, index) {
                if (index >= _playerStates.length) return const SizedBox();

                final player = players[index];

                return _PlayerCard(
                  player: player,
                  index: index,
                  status: _playerStates[index]['status'],
                  points: _playerStates[index]['points'],
                  isDoublee: player.isDoublee,
                  onStatusChanged: (status) {
                    setState(() {
                      _playerStates[index]['status'] = status;
                    });
                  },
                  onPointsChanged: (points) {
                    setState(() {
                      _playerStates[index]['points'] = points;
                    });
                    // ✅ FIX: Pass the player's stable identifier (userName)
                    widget.onPointsChanged(player.userName, points);
                  },
                  onDoubleeToggle: () => _showDoubleeDialog(player),
                );
              },
            ),
          ],
        ),
      );
    });
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

  const _PlayerCard({super.key, required this.player, required this.index, required this.status, required this.points, required this.isDoublee, required this.onStatusChanged, required this.onPointsChanged, required this.onDoubleeToggle});

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
    if (oldWidget.points != widget.points || oldWidget.player.userName != widget.player.userName) {
      // Only update the text field if the underlying point value has changed.
      final newPointsText = widget.points == 0.0 ? '' : widget.points.toInt().toString();
      if (_pointsController.text != newPointsText) {
        _pointsController.text = newPointsText;
      }
    }
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  // ... (Rest of _PlayerCardState methods and build function remain unchanged) ...

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
    const double cardRadius = 12.0;

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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(cardRadius - 1)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(cardRadius - 1)),
                    child: widget.player.userImage != null && File(widget.player.userImage!).existsSync()
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
                              child: CupertinoSwitch(value: widget.isDoublee, onChanged: (_) => widget.onDoubleeToggle(), activeColor: _doubleeColor, trackColor: _iosBorder, thumbColor: widget.isDoublee ? CupertinoColors.white : _textGrey, key: ValueKey('${widget.player.userName}_${widget.isDoublee}')),
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [_doubleeColor, Color(0xFF22D3EE)]),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
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
