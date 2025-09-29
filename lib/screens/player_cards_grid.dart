// widgets/player_cards_grid.dart (Updated with White Themed Dialogs & Color Swaps)

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/player_controller.dart';
import '../model/marriage_game.dart';
import '../model/user_model.dart' as PlayerDialog;
import '../widgets/player_selection_dialog.dart' as PlayerDialog;

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
const Color _successGreen = Color(0xFF10B981);
const Color _darkText = Color(0xFF1A1D2B);

// 🔥 CHANGE: Swapped Blind and Seen colors
const LinearGradient _blueGradient = LinearGradient(colors: [_primaryDark, _primaryMedium, _primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight);
const LinearGradient _seenGradient = LinearGradient(colors: [_primaryDark, _primaryMedium, _primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight); // Now uses blue gradient
const LinearGradient _blindGradient = LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)], begin: Alignment.topLeft, end: Alignment.bottomRight); // Now uses purple gradient
const LinearGradient _winGradient = LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)], begin: Alignment.topLeft, end: Alignment.bottomRight);

class PlayerCardsGrid extends StatefulWidget {
  final Function(String, double) onPointsChanged;
  final Function(String) onDoubleeToggle;
  final VoidCallback? onActionButtonPressed;

  const PlayerCardsGrid({super.key, required this.onPointsChanged, required this.onDoubleeToggle, this.onActionButtonPressed});

  @override
  State<PlayerCardsGrid> createState() => _PlayerCardsGridState();
}

class _PlayerCardsGridState extends State<PlayerCardsGrid> {
  final PlayerController _playerController = Get.find<PlayerController>();
  final Map<String, Map<String, dynamic>> _playerStates = {};
  late Worker _playerListListener;
  bool _hasAttemptedInitialLoad = false;
  bool _justConfirmedPlayers = false;
  String? _currentWinnerUserName;

  @override
  void initState() {
    super.initState();

    _initializePlayerStates(_playerController.players);

    _playerListListener = ever(_playerController.players, (List<MarriagePlayer> players) {
      setState(() {
        debugPrint('PlayerCardsGrid: Listener triggered. Resetting local _playerStates');
        _justConfirmedPlayers = false;
        _initializePlayerStates(players);
        _updateCurrentWinner();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialPlayers();
    });
  }

  void _initializePlayerStates(List<MarriagePlayer> players) {
    for (final player in players) {
      if (!_playerStates.containsKey(player.userName)) {
        _playerStates[player.userName] = {'status': 'Seen', 'points': 0.0};
        debugPrint('PlayerCardsGrid: Initialized state for ${player.userName}');
      }
    }

    final currentPlayerNames = players.map((p) => p.userName).toSet();
    _playerStates.removeWhere((userName, _) => !currentPlayerNames.contains(userName));

    _updateCurrentWinner();
  }

  void _updateCurrentWinner() {
    final players = _playerController.players;
    for (final player in players) {
      final state = _playerStates[player.userName];
      if (state != null && state['status'] == 'Win') {
        _currentWinnerUserName = player.userName;
        return;
      }
    }
    _currentWinnerUserName = null;
  }

  Map<String, dynamic> _getPlayerState(String userName) {
    return _playerStates[userName] ?? {'status': 'Seen', 'points': 0.0};
  }

  void _updatePlayerState(String userName, String status, double points) {
    setState(() {
      _playerStates[userName] = {'status': status, 'points': points};
    });
  }

  bool _canSetWinner(String currentPlayerUserName) {
    if (_currentWinnerUserName == null) return true;
    if (_currentWinnerUserName == currentPlayerUserName) return true;
    return false;
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

  void _showPlayerSelectionDialog(BuildContext context) async {
    final List<MarriagePlayer> currentPlayers = _playerController.players.toList();
    final int requiredPlayerCount = currentPlayers.isNotEmpty ? currentPlayers.length : 4;
    final List<String> currentSelectedNames = currentPlayers.map((p) => p.userName).toList();

    final List<PlayerDialog.User>? result = await showDialog<List<PlayerDialog.User>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return PlayerDialog.PlayerSelectionDialog(numberOfPlayers: requiredPlayerCount, alreadySelectedPlayers: currentSelectedNames);
      },
    );

    if (result != null && result.isNotEmpty) {
      _playerController.updatePlayersFromUsers(result);
      setState(() {
        _justConfirmedPlayers = true;
        _currentWinnerUserName = null;
      });
    }
  }

  // 🔥 UPDATED: White themed iOS-like dialog
  // NOTE: This function assumes it is part of a StatefulWidget where 'widget'

  // This function needs the context of a StatefulWidget/StatelessWidget to be defined.

  void _showDoubleeDialog(BuildContext context, MarriagePlayer player) {
    final isCurrentlyDoublee = player.isDoublee;
    final actionText = isCurrentlyDoublee ? 'Disable' : 'Enable';
    final confirmationText = isCurrentlyDoublee ? 'Are you sure you want to disable Doublee mode for ${player.userName}?' : 'Are you sure you want to enable Doublee mode for ${player.userName}?';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  // Adjusted padding after removing the icon
                  padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
                  ),
                  child: Column(
                    children: [
                      // Title
                      Text(
                        "Doublee Mode",
                        style: GoogleFonts.poppins(
                          // Changed to Poppins
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Subtitle
                      Text(
                        confirmationText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          // Changed to Poppins
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666668),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Buttons Section
                Container(
                  height: 44,
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14)),
                            child: Center(
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.poppins(
                                  // Changed to Poppins
                                  // Size 15 and weight w500 retained from previous step
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF007AFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Vertical Divider
                      Container(width: 0.5, height: 44, color: const Color(0xFFE5E5EA)),
                      // Action Button (Enable/Disable)
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              // NOTE: Assumes widget.onDoubleeToggle is available from the StatefulWidget context
                              widget.onDoubleeToggle(player.userName);
                            },
                            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(14)),
                            child: Center(
                              child: Text(
                                actionText,
                                style: GoogleFonts.poppins(
                                  // Changed to Poppins
                                  // Size 15 and weight w500 retained from previous step
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isCurrentlyDoublee
                                      ? const Color(0xFFFF3B30) // System Red (Disable)
                                      : const Color(0xFF34C759), // System Green (Enable)
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                final player = players[index];
                final playerState = _getPlayerState(player.userName);
                final isBlind = playerState['status'] == 'Blind';

                return _PlayerCard(
                  player: player,
                  index: index,
                  status: playerState['status'],
                  points: playerState['points'],
                  isDoublee: player.isDoublee,
                  isInputEnabled: !isBlind,
                  // 🔥 NEW: Disable doublee toggle for blind users
                  isDoubleeEnabled: !isBlind,
                  currentWinnerUserName: _currentWinnerUserName,
                  onStatusChanged: (status) {
                    // Check if winner already exists
                    if (status == 'Win' && !_canSetWinner(player.userName)) {
                      return;
                    }

                    final oldStatus = playerState['status'];
                    double newPoints = playerState['points'];

                    // Reset points to 0 when switching to Blind
                    if (status == 'Blind') {
                      newPoints = 0.0;
                      widget.onPointsChanged(player.userName, 0.0);
                    }

                    _updatePlayerState(player.userName, status, newPoints);

                    // Update current winner tracking
                    if (status == 'Win') {
                      _currentWinnerUserName = player.userName;
                    } else if (oldStatus == 'Win') {
                      _currentWinnerUserName = null;
                    }
                  },
                  onPointsChanged: (points) {
                    _updatePlayerState(player.userName, playerState['status'], points);
                    widget.onPointsChanged(player.userName, points);
                  },
                  onDoubleeToggle: () => _showDoubleeDialog(context, player),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _PlayerCard extends StatefulWidget {
  final MarriagePlayer player;
  final int index;
  final String status;
  final double points;
  final bool isDoublee;
  final bool isInputEnabled;
  final bool isDoubleeEnabled; // 🔥 NEW: Control doublee switch enable/disable
  final String? currentWinnerUserName;
  final Function(String) onStatusChanged;
  final Function(double) onPointsChanged;
  final VoidCallback onDoubleeToggle;

  const _PlayerCard({super.key, required this.player, required this.index, required this.status, required this.points, required this.isDoublee, required this.isInputEnabled, required this.isDoubleeEnabled, required this.currentWinnerUserName, required this.onStatusChanged, required this.onPointsChanged, required this.onDoubleeToggle});

  @override
  State<_PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<_PlayerCard> {
  late TextEditingController _pointsController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _pointsController = TextEditingController(text: widget.points == 0.0 ? '' : widget.points.toInt().toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _PlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update points controller when points change
    if (oldWidget.points != widget.points || oldWidget.player.userName != widget.player.userName) {
      final newPointsText = widget.points == 0.0 ? '' : widget.points.toInt().toString();
      if (_pointsController.text != newPointsText) {
        _pointsController.text = newPointsText;
      }
    }

    // Remove focus when input is disabled
    if (oldWidget.isInputEnabled && !widget.isInputEnabled) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Win':
        return _successGreen;
      case 'Seen':
        return _primaryLight; // 🔥 CHANGE: Seen now uses blue color
      case 'Blind':
      default:
        return const Color(0xFF8B5CF6); // 🔥 CHANGE: Blind now uses purple color
    }
  }

  Widget _buildStatusOption(BuildContext context, String option) {
    final isSelected = widget.status == option;
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.023;

    // Disable Win option if another player is already winner
    final isWinDisabled = option == 'Win' && widget.currentWinnerUserName != null && widget.currentWinnerUserName != widget.player.userName;

    LinearGradient? gradient;
    if (isSelected) {
      if (option == 'Win') {
        gradient = _winGradient;
      } else if (option == 'Seen') {
        gradient = _seenGradient; // 🔥 CHANGE: Seen uses blue gradient
      } else if (option == 'Blind') {
        gradient = _blindGradient; // 🔥 CHANGE: Blind uses purple gradient
      }
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isWinDisabled ? null : () => widget.onStatusChanged(option),
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              gradient: gradient,
              color: isSelected ? null : (isWinDisabled ? _lightGrey : Colors.white),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isSelected ? Colors.transparent : (isWinDisabled ? _borderGrey : _iosBorder), width: 1.0),
              boxShadow: isSelected ? [BoxShadow(color: _getStatusColor(option).withOpacity(0.3), blurRadius: 3, offset: const Offset(0, 2))] : null,
            ),
            child: Center(
              child: Text(
                option,
                style: GoogleFonts.inter(fontSize: fontSize < 9.0 ? 9.0 : fontSize, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : (isWinDisabled ? _textGrey.withOpacity(0.5) : const Color(0xFF374151))),
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
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      GestureDetector(
                        onTap: widget.isInputEnabled
                            ? () {
                                FocusScope.of(context).requestFocus(_focusNode);
                              }
                            : null,
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          decoration: BoxDecoration(
                            color: widget.isInputEnabled ? Colors.white : _lightGrey,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: widget.isInputEnabled ? _iosBorder : _borderGrey, width: 1),
                            boxShadow: widget.isInputEnabled ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1))] : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.monetization_on_outlined, size: 16, color: widget.isInputEnabled ? _textGrey : _textGrey.withOpacity(0.4)),
                                    Container(height: 20, width: 1, margin: const EdgeInsets.symmetric(horizontal: 6), color: widget.isInputEnabled ? _borderGrey : _borderGrey.withOpacity(0.4)),
                                    Expanded(
                                      child: TextField(
                                        controller: _pointsController,
                                        focusNode: _focusNode,
                                        enabled: widget.isInputEnabled,
                                        textAlign: TextAlign.right,
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.inter(fontSize: screenWidth * 0.03, fontWeight: FontWeight.w600, color: widget.isInputEnabled ? _primaryDark : _textGrey.withOpacity(0.4)),
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
                              const SizedBox(width: 8),
                              Transform.scale(
                                scale: 0.65,
                                child: CupertinoSwitch(
                                  value: widget.isDoublee,
                                  onChanged: widget.isDoubleeEnabled ? (_) => widget.onDoubleeToggle() : null, // 🔥 CHANGE: Disabled for blind
                                  activeColor: _doubleeColor,
                                  trackColor: _iosBorder,
                                  thumbColor: widget.isDoublee ? CupertinoColors.white : _textGrey,
                                  key: ValueKey('${widget.player.userName}_${widget.isDoublee}'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (widget.isDoublee && widget.isDoubleeEnabled) // 🔥 CHANGE: Only show doublee badge if enabled
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
