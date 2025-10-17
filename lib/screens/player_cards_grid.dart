import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/player_controller.dart';
import '../model/marriage_game.dart';
import '../model/user_model.dart' as PlayerDialog;
import '../widgets/player_selection_dialog.dart' as PlayerDialog;

// ==================== CUSTOM COLORS AND STYLES ====================

/// Primary dark blue color
const Color _primaryDark = Color(0xFF1E3A8A);

/// Primary medium blue color
const Color _primaryMedium = Color(0xFF2563EB);

/// Primary light blue color
const Color _primaryLight = Color(0xFF3B82F6);

/// Text grey color
const Color _textGrey = Color(0xFF6B7280);

/// Light grey background color
const Color _lightGrey = Color(0xFFF8FAFC);

/// Border grey color
const Color _borderGrey = Color(0xFFE5E7EB);

/// iOS-style border color
const Color _iosBorder = Color(0xFFD1D5DB);

/// iOS-style background color
const Color _iosBackground = Color(0xFFF9FAFB);

/// Doublee mode indicator color
const Color _doubleeColor = Color(0xFF06B6D4);

/// Success green color
const Color _successGreen = Color(0xFF10B981);

/// Dark text color
const Color _darkText = Color(0xFF1A1D2B);

/// Blue gradient for primary elements
const LinearGradient _blueGradient = LinearGradient(colors: [_primaryDark, _primaryMedium, _primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight);

/// Blue gradient for Seen mode (swapped from original)
const LinearGradient _seenGradient = LinearGradient(colors: [_primaryDark, _primaryMedium, _primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight);

/// Purple gradient for Blind mode (swapped from original)
const LinearGradient _blindGradient = LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)], begin: Alignment.topLeft, end: Alignment.bottomRight);

/// Green gradient for Win mode
const LinearGradient _winGradient = LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)], begin: Alignment.topLeft, end: Alignment.bottomRight);

/// Widget that displays a grid of player cards with status, points, and mode controls
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

    // Listen for player list changes and update local state accordingly
    _playerListListener = ever(_playerController.players, (List<MarriagePlayer> players) {
      setState(() {
        _justConfirmedPlayers = false;
        _initializePlayerStates(players);
        _updateCurrentWinner();
      });
    });

    // Check initial players after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialPlayers();
    });
  }

  /// Initializes local player states from the controller's player list
  void _initializePlayerStates(List<MarriagePlayer> players) {
    for (final player in players) {
      if (!_playerStates.containsKey(player.userName)) {
        // Convert PlayerMode enum to string for UI state
        String status = 'Seen';
        switch (player.mode) {
          case PlayerMode.blind:
            status = 'Blind';
            break;
          case PlayerMode.seen:
            status = 'Seen';
            break;
          case PlayerMode.win:
            status = 'Win';
            break;
        }
        _playerStates[player.userName] = {'status': status, 'points': player.pointsEarned};
      }
    }

    // Remove any players that are no longer in the list
    final currentPlayerNames = players.map((p) => p.userName).toSet();
    _playerStates.removeWhere((userName, _) => !currentPlayerNames.contains(userName));

    _updateCurrentWinner();
  }

  /// Updates the current winner tracking based on player modes
  void _updateCurrentWinner() {
    final players = _playerController.players;
    for (final player in players) {
      if (player.mode == PlayerMode.win) {
        _currentWinnerUserName = player.userName;
        return;
      }
    }
    _currentWinnerUserName = null;
  }

  /// Gets the current state for a specific player
  Map<String, dynamic> _getPlayerState(String userName) {
    return _playerStates[userName] ?? {'status': 'Seen', 'points': 0.0};
  }

  /// Updates the local state for a specific player
  void _updatePlayerState(String userName, String status, double points) {
    setState(() {
      _playerStates[userName] = {'status': status, 'points': points};
    });
  }

  /// Checks if a player can be set as winner
  bool _canSetWinner(String currentPlayerUserName) {
    if (_currentWinnerUserName == null) return true;
    if (_currentWinnerUserName == currentPlayerUserName) return true;
    return false;
  }

  /// Checks if initial players need to be loaded
  void _checkInitialPlayers() {
    if (!_hasAttemptedInitialLoad && _playerController.players.isEmpty) {
      _hasAttemptedInitialLoad = true;
    }
  }

  @override
  void dispose() {
    _playerListListener.dispose();
    super.dispose();
  }

  /// Shows the player selection dialog for adding/editing players
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

  /// Shows confirmation dialog for enabling/disabling doublee mode with updated design
  void _showDoubleeDialog(BuildContext context, MarriagePlayer player) {
    final isCurrentlyDoublee = player.isDoublee;
    final actionText = isCurrentlyDoublee ? 'Disable' : 'Enable';
    final confirmationText = isCurrentlyDoublee ? 'Are you sure you want to disable Doublee mode for ${player.userName}' : 'Are you sure you want to enable Doublee mode for ${player.userName}?';

    Get.defaultDialog(
      // --- DIALOG STYLING ---
      backgroundColor: Colors.white,
      radius: 14.0,
      title: "",
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,

      // --- CUSTOM CONTENT SECTION ---
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Title (Top padding set for spacing)
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 5.0, left: 15.0, right: 15.0),
            child: Text(
              "Doublee Mode",
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black),
            ),
          ),

          // 2. Confirmation Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    confirmationText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // --- CUSTOM ACTIONS SECTION (Single Row with Divider) ---
      actions: [
        Column(
          children: [
            const Divider(color: Colors.black12, height: 1.0, thickness: 0.8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. Cancel Action (Left Button)
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const RoundedRectangleBorder()),
                    onPressed: () {
                      Get.back(); // Simply close the dialog
                    },
                    child: Text(
                      "Cancel",
                      // CHANGED: GoogleFonts.quicksand to GoogleFonts.poppins
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.blue.shade700),
                    ),
                  ),
                ),

                // Vertical Divider
                Container(height: 45, width: 0.8, color: Colors.black12),

                // 2. Action Button (Enable/Disable)
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const RoundedRectangleBorder()),
                    onPressed: () {
                      Get.back();
                      widget.onDoubleeToggle(player.userName);
                    },
                    child: Text(
                      actionText,
                      // CHANGED: GoogleFonts.quicksand to GoogleFonts.poppins
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w800, fontSize: 16, color: isCurrentlyDoublee ? Colors.red.shade700 : Colors.green.shade700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Determines grid cross axis count based on player count
  int _getCrossAxisCount(int playerCount) {
    return 2;
  }

  /// Determines grid child aspect ratio based on player count
  double _getChildAspectRatio(int playerCount) {
    return 0.65;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final players = _playerController.players;

      // Show empty state if no players are selected
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
                  // CHANGED: GoogleFonts.inter to GoogleFonts.poppins
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: _textGrey),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _showPlayerSelectionDialog(context),
                  icon: const Icon(Icons.group_add, color: Colors.white),
                  // CHANGED: GoogleFonts.inter to GoogleFonts.poppins
                  label: Text('Select Players', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
                    // CHANGED: GoogleFonts.inter to GoogleFonts.poppins
                    style: GoogleFonts.poppins(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2B)),
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
                          // CHANGED: GoogleFonts.inter to GoogleFonts.poppins
                          style: GoogleFonts.poppins(fontSize: screenWidth * 0.03, color: _textGrey, fontWeight: FontWeight.w600),
                        ),
                        Container(width: 1.5, height: 14, margin: const EdgeInsets.symmetric(horizontal: 4), color: _borderGrey),
                        Text(
                          '${players.length}',
                          // CHANGED: GoogleFonts.inter to GoogleFonts.poppins
                          style: GoogleFonts.poppins(fontSize: screenWidth * 0.03, color: _textGrey, fontWeight: FontWeight.w600),
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
                final isBlind = player.mode == PlayerMode.blind;

                return _PlayerCard(
                  player: player,
                  index: index,
                  status: playerState['status'],
                  points: playerState['points'],
                  isDoublee: player.isDoublee,
                  isInputEnabled: !isBlind,
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

/// Individual player card widget displaying player info, status, and controls
class _PlayerCard extends StatefulWidget {
  final MarriagePlayer player;
  final int index;
  final String status;
  final double points;
  final bool isDoublee;
  final bool isInputEnabled;
  final bool isDoubleeEnabled;
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

  /// Gets the color for a specific player status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Win':
        return _successGreen;
      case 'Seen':
        return _primaryLight;
      case 'Blind':
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  /// Builds a status option button (Blind, Seen, Win)
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
        gradient = _seenGradient;
      } else if (option == 'Blind') {
        gradient = _blindGradient;
      }
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isWinDisabled
              ? null
              : () {
                  // Convert string option to PlayerMode enum
                  PlayerMode mode;
                  switch (option) {
                    case 'Blind':
                      mode = PlayerMode.blind;
                      break;
                    case 'Seen':
                      mode = PlayerMode.seen;
                      break;
                    case 'Win':
                      mode = PlayerMode.win;
                      break;
                    default:
                      mode = PlayerMode.seen;
                  }

                  // Get the PlayerController and update the mode
                  final playerController = Get.find<PlayerController>();
                  playerController.updatePlayerMode(widget.player.userName, mode);

                  // Also call the local callback to update UI state
                  widget.onStatusChanged(option);
                },
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
                // CHANGED: GoogleFonts.inter to GoogleFonts.poppins
                style: GoogleFonts.quicksand(fontSize: fontSize < 9.0 ? 9.0 : fontSize, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : (isWinDisabled ? _textGrey.withOpacity(0.5) : const Color(0xFF374151))),
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
                            Icon(Icons.person, size: screenWidth * 0.035, color: _primaryDark),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.player.userName,
                                textAlign: TextAlign.center,
                                // CHANGED: GoogleFonts.inter to GoogleFonts.poppins
                                style: GoogleFonts.quicksand(fontSize: screenWidth * 0.035, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2B)),
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
                                        // CHANGED: GoogleFonts.inter to GoogleFonts.poppins
                                        style: GoogleFonts.poppins(fontSize: screenWidth * 0.03, fontWeight: FontWeight.w600, color: widget.isInputEnabled ? _primaryDark : _textGrey.withOpacity(0.4)),
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
                                child: CupertinoSwitch(value: widget.isDoublee, onChanged: widget.isDoubleeEnabled ? (_) => widget.onDoubleeToggle() : null, activeColor: _doubleeColor, trackColor: _iosBorder, thumbColor: widget.isDoublee ? CupertinoColors.white : _textGrey, key: ValueKey('${widget.player.userName}_${widget.isDoublee}')),
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
          // Doublee mode indicator badge
          if (widget.isDoublee && widget.isDoubleeEnabled)
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
                  // CHANGED: GoogleFonts.inter to GoogleFonts.poppins
                  style: GoogleFonts.poppins(fontSize: screenWidth * 0.025, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
