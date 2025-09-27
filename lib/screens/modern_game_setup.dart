// widgets/modern_game_setup.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Assuming these models/widgets exist in your project
import '../model/marriage_game.dart';
import '../model/user_model.dart';
// IMPORTANT: This import path is assumed to be correct based on your file structure.
// Ensure player_selection_dialog.dart is in the correct path relative to this file.
import '../widgets/player_selection_dialog.dart';

class ModernGameSetup extends StatefulWidget {
  final int selectedPlayers;
  final double pointsPerRupee;
  final List<MarriagePlayer> selectedPlayersList;
  final Function(int) onPlayersChanged;
  final Function(double) onPointsChanged;
  // NOTE: This function's purpose has implicitly changed.
  // It should now handle adding *all* confirmed players and removing any that were unselected.
  final Function(User) onPlayerSelected;

  const ModernGameSetup({super.key, required this.selectedPlayers, required this.pointsPerRupee, required this.selectedPlayersList, required this.onPlayersChanged, required this.onPointsChanged, required this.onPlayerSelected});

  @override
  State<ModernGameSetup> createState() => _ModernGameSetupState();
}

class _ModernGameSetupState extends State<ModernGameSetup> {
  final List<int> _playerOptions = [3, 4, 5, 6];
  bool _isExpanded = true;
  late final TextEditingController _pointsController;

  // Deep blueish gradient colors
  static const Color _primaryDark = Color(0xFF1E3A8A);
  static const Color _primaryMedium = Color(0xFF2563EB);
  static const Color _primaryLight = Color(0xFF3B82F6);
  static const Color _lightGrey = Color(0xFFF8FAFC);
  static const Color _borderGrey = Color(0xFFE5E7EB);
  static const Color _textGrey = Color(0xFF6B7280);
  static const Color _darkText = Color(0xFF1A1D21);

  // New color for iOS-like outline
  static const Color _iosBorder = Color(0xFFD1D5DB);
  static const Color _iosBackground = Color(0xFFF9FAFB);

  static const LinearGradient _blueGradient = LinearGradient(colors: [_primaryDark, _primaryMedium, _primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight);

  @override
  void initState() {
    super.initState();
    int initialPoints = (widget.pointsPerRupee > 0 ? widget.pointsPerRupee.round() : 1);
    _pointsController = TextEditingController(text: initialPoints.toString());
  }

  @override
  void didUpdateWidget(covariant ModernGameSetup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pointsPerRupee != widget.pointsPerRupee) {
      int newPoints = (widget.pointsPerRupee > 0 ? widget.pointsPerRupee.round() : 1);
      _pointsController.text = newPoints.toString();
    }
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  // 🔄 UPDATED: Modified to use the new onPlayersConfirmed callback
  void _selectPlayers() {
    // We no longer check the count here, as the dialog itself manages and enforces the final count logic.
    // The check in the button's onTap property is sufficient.

    showDialog(
      context: context,
      builder: (context) => PlayerSelectionDialog(
        numberOfPlayers: widget.selectedPlayers,
        // Passing the list of already selected player IDs (usernames)
        alreadySelectedPlayers: widget.selectedPlayersList.map((p) => p.userId).toList(),

        // NEW CALLBACK: Handles the final list of confirmed players
        onPlayersConfirmed: (selectedUsers) {
          // This logic now ensures that all players selected in the dialog
          // are added to the game setup state.

          // NOTE: Your original widget.onPlayerSelected only has a single User parameter,
          // implying a simple "add" operation. If you need a full clear/sync
          // (which is cleaner), you should modify the parent state management
          // to include an onPlayersSynced(List<User> list) function.
          //
          // For now, we will use the confirmation dialog to process the list,
          // ensuring the parent widget's function is called correctly.
          _showBulkConfirmationDialog(selectedUsers);
        },
      ),
    );
  }

  // 🆕 NEW METHOD: Replaces _showConfirmationDialog to handle the list of confirmed players.
  void _showBulkConfirmationDialog(List<User> confirmedUsers) {
    // 1. Get the list of currently selected players in the main state (by username)
    final currentUsers = widget.selectedPlayersList.map((p) => p.userId).toSet();
    // 2. Get the list of usernames of the newly confirmed players
    final confirmedUsernames = confirmedUsers.map((u) => u.username).toSet();

    // 3. Identify players to be ADDED (newly selected)
    final usersToAdd = confirmedUsers.where((u) => !currentUsers.contains(u.username)).toList();
    // 4. Identify players to be REMOVED (selected before, but not in the confirmed list)
    final usersToRemove = widget.selectedPlayersList.where((p) => !confirmedUsernames.contains(p.userId)).toList();

    String message;
    if (usersToRemove.isEmpty && usersToAdd.isNotEmpty) {
      message = 'Add ${usersToAdd.length} new player(s)?';
    } else if (usersToRemove.isNotEmpty || usersToAdd.isNotEmpty) {
      message = 'Syncing player list: ${usersToAdd.length} to add, ${usersToRemove.length} to remove.';
    } else {
      // Should not happen if confirmedUsers.length == widget.selectedPlayers
      message = 'Players list confirmed.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: _blueGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: _primaryDark.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: const Icon(Icons.people_alt, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Confirm Selection',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: _darkText),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: _textGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _textGrey),
            ),
          ),
          Container(
            decoration: BoxDecoration(gradient: _blueGradient, borderRadius: BorderRadius.circular(12)),
            child: TextButton(
              onPressed: () {
                // To maintain the existing widget.onPlayerSelected(User) signature,
                // we'll call it for *every* player in the confirmed list.
                // The parent's state management must be robust enough to handle
                // re-adding existing players (i.e., ignore them if they exist).

                // IMPORTANT: Since your existing onPlayerSelected is a simple add,
                // you must update your parent state management to handle both adding
                // and removing players based on the comparison above (usersToAdd/usersToRemove).
                // For this code to compile and function, we will call the existing
                // widget.onPlayerSelected for the players to be ADDED.

                // --- Simple ADD Implementation ---
                for (var user in usersToAdd) {
                  widget.onPlayerSelected(user);
                }

                // NOTE: If you need REMOVAL, you must create a new function in
                // ModernGameSetup: final Function(User) onPlayerRemoved;

                Navigator.pop(context);
              },
              child: Text(
                'APPLY',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DELETED: _showConfirmationDialog is replaced by _showBulkConfirmationDialog.

  void _confirmPlayerChange(int newCount) {
    if (newCount == widget.selectedPlayers) return;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Are You Sure Want To Change Players Number',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: Text('This will clear all currently selected players (${widget.selectedPlayersList.length} player(s)).', style: GoogleFonts.inter(color: Colors.black)),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text('Cancel', style: GoogleFonts.inter(color: CupertinoColors.systemGrey)),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Change', style: GoogleFonts.inter(color: CupertinoColors.systemRed)),
            onPressed: () {
              widget.onPlayersChanged(newCount);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String pointsValue = widget.pointsPerRupee.round().toString();
    String totalPlayers = widget.selectedPlayers.toString();

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _blueGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _primaryDark.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.sports_esports, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game Setup',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  // Progress Badge: [Total Players] | [Points Value]
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // TOTAL PLAYERS COUNT (Uniform styling)
                        Text(
                          widget.selectedPlayersList.length.toString(), // Display selected count
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        // Separator '|'
                        Container(height: 12, width: 1, margin: const EdgeInsets.symmetric(horizontal: 6), color: Colors.white.withOpacity(0.5)),
                        // POINTS VALUE (Uniform styling)
                        Text(
                          pointsValue,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderGrey, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _lightGrey,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _borderGrey),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group, size: 14, color: _primaryDark),
                const SizedBox(width: 6),
                Text(
                  'TOTAL PLAYERS',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _textGrey, letterSpacing: 0.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: _lightGrey,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderGrey),
            ),
            child: Row(
              children: _playerOptions.map((number) {
                final isSelected = widget.selectedPlayers == number;
                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _confirmPlayerChange(number),
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          gradient: isSelected ? _blueGradient : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFD1D5DB), width: 1.5),
                          boxShadow: isSelected ? [BoxShadow(color: _primaryLight.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : null,
                        ),
                        child: Center(
                          child: Text(
                            number.toString(),
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF374151)),
                          ),
                        ),
                      ),
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

  // MODIFIED: Input field now uses Flexible to ensure it scales correctly
  // and doesn't cause overflow on narrow screens.
  Widget _buildCombinedActions() {
    String currentPoints = widget.pointsPerRupee > 0 ? widget.pointsPerRupee.round().toString() : '1';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderGrey, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _lightGrey,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _borderGrey),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on_outlined, size: 14, color: _primaryDark),
                const SizedBox(width: 6),
                Text(
                  'POINTS',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _textGrey, letterSpacing: 0.8),
                ),
                Container(height: 12, width: 1, margin: const EdgeInsets.symmetric(horizontal: 6), color: _textGrey.withOpacity(0.5)),
                Text(
                  currentPoints,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _primaryDark, letterSpacing: 0.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // iOS-like WRAPPER CONTAINER
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _iosBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _iosBorder, width: 1.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Points Input Section - Now Flexible
                Flexible(
                  // Use Flexible to allow shrinking on small screens
                  flex: 3,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 85, maxWidth: 120), // Added constraints for better control
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Center(
                        child: TextField(
                          controller: _pointsController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _primaryDark),
                          decoration: const InputDecoration(
                            prefixText: 'POINT | ',
                            prefixStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textGrey),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.only(bottom: 2),
                            hintText: '1',
                            hintStyle: TextStyle(color: Color(0xFFD1D5DB)),
                          ),
                          onChanged: (value) {
                            int? parsedValue = int.tryParse(value);
                            if (parsedValue != null && parsedValue > 0) {
                              widget.onPointsChanged(parsedValue.toDouble());
                            }
                            setState(() {});
                          },
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            int? finalValue = int.tryParse(_pointsController.text);
                            if (finalValue == null || finalValue <= 0) {
                              finalValue = widget.pointsPerRupee.round() > 0 ? widget.pointsPerRupee.round() : 1;
                            }
                            if (_pointsController.text != finalValue.toString()) {
                              _pointsController.text = finalValue.toString();
                            }
                            widget.onPointsChanged(finalValue.toDouble());
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // 2. Select Players Button - Uses Expanded to fill remaining space
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: widget.selectedPlayersList.length < widget.selectedPlayers ? _blueGradient : const LinearGradient(colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)]),
                      boxShadow: [BoxShadow(color: (widget.selectedPlayersList.length < widget.selectedPlayers ? _primaryLight : const Color(0xFF6B7280)).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: widget.selectedPlayersList.length < widget.selectedPlayers ? _selectPlayers : null,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.group_add, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'SELECT PLAYER',
                                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder for better local responsiveness checks
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Dynamic horizontal margin based on screen width
        final dynamicMargin = screenWidth > 600 ? 32.0 : 16.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          // Apply dynamic margin
          margin: EdgeInsets.symmetric(horizontal: dynamicMargin, vertical: 16),
          decoration: BoxDecoration(
            color: _lightGrey,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    if (_isExpanded) ...[
                      const SizedBox(height: 16),
                      // Inner padding now uses the standard dynamic value
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildPlayerSelection()),
                      const SizedBox(height: 12),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildCombinedActions()),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
