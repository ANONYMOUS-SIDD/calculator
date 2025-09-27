import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Assuming these models/widgets exist
import '../model/user_model.dart';
import '../screens/add_user_dialog.dart';

// 🎨 GLOBAL COLORS
const Color _primaryDark = Color(0xFF1E3A8A);
const Color _primaryMedium = Color(0xFF2563EB);
const Color _primaryLight = Color(0xFF3B82F6);
const Color _cyanDark = Color(0xFF0E7490);
const Color _cyanLight = Color(0xFF06B6D4);
const Color _borderLightBlue = Color(0xFFBFDBFE);
const Color _textGrey = Color(0xFF6B7280);
const Color _darkText = Color(0xFF1A1D21);
const Color _iosBorder = Color(0xFFD1D5DB);
const Color _errorRed = Color(0xFFEF4444);
const Color _errorDark = Color(0xFFB91C1C); // Darker red for shadow

// --- NEW COLORS FOR ADD PLAYER BUTTON ---
const Color _purple = Color(0xFF8B5CF6);
const Color _pink = Color(0xFFEC4899);
const Color _orange = Color(0xFFF97316); // New color for empty state

// --- GRADIENTS ---
// Gradient for Header icon
const LinearGradient _primaryGradient = LinearGradient(colors: [_primaryDark, _primaryMedium, _primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight);

// Gradient for Confirm Button (Used for filled state)
const LinearGradient _confirmGradient = LinearGradient(
  colors: [Color(0xFF10B981), Color(0xFF06B6D4)], // Emerald to Cyan
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// Gradient for Colorful Add Player Icon
const LinearGradient _addPlayerIconGradient = LinearGradient(colors: [_purple, _pink], begin: Alignment.topLeft, end: Alignment.bottomRight);

// Gradient for Colorful Empty State Icon
const LinearGradient _emptyStateIconGradient = LinearGradient(
  colors: [_pink, _orange], // Pink to Orange
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// --- TYPOGRAPHY & RADIUS ---
// Typography Improvement: Montserrat for titles, clean Inter for body/buttons
final TextStyle _headingStyle = GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: _darkText);
final TextStyle _bodyStyle = GoogleFonts.inter(fontSize: 14, color: _darkText);
final TextStyle _labelStyle = GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14, color: _textGrey);

// Reduced Border Radius
const double _smallRadius = 10.0;
const double _dialogRadius = 16.0;

class PlayerSelectionDialog extends StatefulWidget {
  final int numberOfPlayers;
  final List<String> alreadySelectedPlayers;
  final Function(List<User> finalSelection) onPlayersConfirmed;

  const PlayerSelectionDialog({super.key, required this.numberOfPlayers, required this.alreadySelectedPlayers, required this.onPlayersConfirmed});

  @override
  State<PlayerSelectionDialog> createState() => _PlayerSelectionDialogState();
}

class _PlayerSelectionDialogState extends State<PlayerSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  List<User> _currentSelection = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Reloads all users from Hive and initializes current selection
  void _loadUsers() {
    _allUsers = Hive.box<User>('usersBox').values.toList().cast<User>();
    _currentSelection = _allUsers.where((user) => widget.alreadySelectedPlayers.contains(user.username)).toList();
    _filterUsers();
  }

  // Filters the user list based on the search query
  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) => user.username.toLowerCase().contains(query)).toList();
      }
    });
  }

  // Shows the dialog to add a new user
  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(
        onUserAdded: (username, imagePath) {
          final userBox = Hive.box<User>('usersBox');
          final newUser = User(username: username, profileImagePath: imagePath, wins: 0, rank: userBox.length + 1);
          userBox.add(newUser);
          // Reload users to include the new one
          _loadUsers();
        },
      ),
    );
  }

  // Handles adding/removing a player from the selection
  void _togglePlayerSelection(User user) {
    setState(() {
      final isSelected = _currentSelection.contains(user);
      if (isSelected) {
        _currentSelection.remove(user);
      } else {
        if (_currentSelection.length < widget.numberOfPlayers) {
          _currentSelection.add(user);
        } else {
          // 🔥 Updated to concise message 🔥
          _showToast('Maximum Number Of Player Reached.');
        }
      }
    });
  }

  bool _isPlayerSelected(User user) => _currentSelection.contains(user);

  // 💥 TOAST FONT AND SIZE ADJUSTMENTS 💥
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent, // Set to transparent to show custom container
        elevation: 0,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero, // Remove internal padding
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20), // Margin from screen edges
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white, // White background
            borderRadius: BorderRadius.circular(_smallRadius),
            border: Border.all(color: _iosBorder.withOpacity(0.5), width: 1.0), // Subtle outline
            boxShadow: [
              BoxShadow(
                color: _darkText.withOpacity(0.15), // Dark shadow for lift
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: _errorRed, size: 20), // Warning icon
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  // 🔥 Font size reduced to 12 and using the simpler body style font 🔥
                  style: _bodyStyle.copyWith(color: _darkText, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Final confirmation logic
  void _confirmSelection() {
    if (_currentSelection.length != widget.numberOfPlayers) {
      _showToast('Please select exactly ${widget.numberOfPlayers} players to confirm.');
      return;
    }
    widget.onPlayersConfirmed(_currentSelection);
    Navigator.pop(context);
  }

  // --- UI BUILDERS ---

  Widget _buildHeader(BuildContext context) {
    final selectedCount = _currentSelection.length;
    final totalCount = widget.numberOfPlayers;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_smallRadius), // Reduced border radius
        boxShadow: [BoxShadow(color: _primaryMedium.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: _primaryGradient,
              borderRadius: BorderRadius.circular(_smallRadius), // Reduced border radius
              boxShadow: [BoxShadow(color: _primaryMedium.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.group, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Players',
                style: _headingStyle.copyWith(fontSize: 16), // Improved font
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)]),
                  borderRadius: BorderRadius.circular(6), // Reduced border radius
                  boxShadow: [BoxShadow(color: _primaryMedium.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: Text(
                  '$selectedCount | $totalCount',
                  style: _bodyStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 12, color: _darkText), // Improved font
                ),
              ),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(_smallRadius), // Reduced border radius
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_smallRadius), // Reduced border radius
                border: Border.all(color: _iosBorder, width: 1.2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.close, size: 20, color: _textGrey),
            ),
          ),
        ],
      ),
    );
  }

  // Updated Search Bar: Improved font for search player text
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      style: _bodyStyle.copyWith(fontSize: 14), // Improved font
      decoration: InputDecoration(
        labelText: "Search Player",
        labelStyle: _labelStyle, // Improved font
        prefixIcon: Container(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: const Icon(Icons.search_rounded, color: _primaryMedium, size: 22),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallRadius), // Reduced border radius
          borderSide: const BorderSide(color: _borderLightBlue, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallRadius), // Reduced border radius
          borderSide: const BorderSide(color: _primaryMedium, width: 1.8),
        ),
      ),
    );
  }

  Widget _buildPlayersList() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_smallRadius), // Reduced border radius
        border: Border.all(color: _borderLightBlue, width: 1.0),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 270),
        child: _filteredUsers.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return _PlayerListItem(user: user, isSelected: _isPlayerSelected(user), onTap: () => _togglePlayerSelection(user));
                },
              ),
      ),
    );
  }

  // 🔥 MINIMIZED EMPTY STATE WITH COLORFUL ICON 🔥
  Widget _buildEmptyState() {
    return Center(
      // Padding is reduced to minimize height
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => _emptyStateIconGradient.createShader(bounds),
              child: const Icon(
                Icons.person_search_rounded,
                size: 40,
                color: Colors.white, // Must be white for ShaderMask
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No players found.',
              style: _bodyStyle.copyWith(color: _textGrey, fontWeight: FontWeight.w600),
            ),
            // Combining the second text line to save vertical space
            Text('Try adding a new player below.', style: _bodyStyle.copyWith(color: _textGrey.withOpacity(0.7), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // BUTTON DESIGN (No functional changes here)
  Widget _buildActionsRow() {
    final isConfirmEnabled = _currentSelection.length == widget.numberOfPlayers;
    const double buttonHeight = 44.0;
    const Color outlineColor = _iosBorder;
    const double outlineWidth = 1.5;
    const double innerPadding = 6;

    // Helper Widget for the new Button style
    Widget _buildStyledButton({
      required String text,
      required IconData icon,
      required Color iconColor,
      required Color textColor,
      required Color borderColor,
      required VoidCallback onTap,
      LinearGradient? gradient,
      LinearGradient? iconGradient, // New parameter for colorful icon
      bool isFilled = false,
      bool isEnabled = true,
    }) {
      Widget iconWidget = Icon(icon, size: 20, color: isFilled && isEnabled ? Colors.white : iconColor.withOpacity(isEnabled ? 1.0 : 0.5));

      // Apply gradient to the icon if provided
      if (iconGradient != null && !isFilled) {
        iconWidget = ShaderMask(
          shaderCallback: (bounds) => iconGradient.createShader(bounds),
          child: const Icon(CupertinoIcons.person_add_solid, size: 20, color: Colors.white), // Must be white for ShaderMask
        );
      }

      return Expanded(
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(_smallRadius),
          child: Container(
            height: buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_smallRadius),
              gradient: isFilled && isEnabled ? gradient : null,
              color: isFilled && isEnabled ? null : Colors.white,
              border: Border.all(color: isEnabled ? borderColor : outlineColor.withOpacity(0.5), width: outlineWidth),
              boxShadow: isFilled && isEnabled ? [BoxShadow(color: _cyanDark.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 4))] : null,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  const SizedBox(width: 6),
                  Text(
                    text,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: isFilled && isEnabled ? Colors.white : textColor.withOpacity(isEnabled ? 1.0 : 0.5), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: innerPadding, vertical: innerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_smallRadius),
        border: Border.all(color: _iosBorder, width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // 1. Add Player Button (Purple/Pink Outline + Colorful Icon)
          _buildStyledButton(
            text: 'Add Player',
            icon: CupertinoIcons.person_add_solid,
            iconColor: _purple, // Base color for outline
            textColor: _purple,
            borderColor: _purple.withOpacity(0.4),
            onTap: _showAddUserDialog,
            iconGradient: _addPlayerIconGradient, // Use the new colorful gradient for the icon
            isEnabled: true,
          ),
          const SizedBox(width: 8), // Increased gap for visual separation
          // 2. Confirm Button (Filled/Outline Style)
          _buildStyledButton(
            text: 'Confirm',
            icon: Icons.verified_rounded, // Verified Tick Icon
            iconColor: _primaryMedium,
            textColor: isConfirmEnabled ? Colors.white : _darkText,
            borderColor: isConfirmEnabled ? Colors.transparent : _iosBorder,
            onTap: isConfirmEnabled ? _confirmSelection : () => _showToast('Please select exactly ${widget.numberOfPlayers} players.'),
            gradient: _confirmGradient,
            isFilled: isConfirmEnabled,
            isEnabled: isConfirmEnabled,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_dialogRadius), // Reduced border radius
          boxShadow: [BoxShadow(color: _primaryMedium.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [_buildHeader(context), const SizedBox(height: 20), _buildSearchBar(), const SizedBox(height: 16), _buildPlayersList(), const SizedBox(height: 20), _buildActionsRow()]),
        ),
      ),
    );
  }
}

// --- Player List Item Card (Outline thickness fixed here) ---
class _PlayerListItem extends StatelessWidget {
  final User user;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlayerListItem({required this.user, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 🔥 New reduced border width constant for selected state 🔥
    const double selectedBorderWidth = 1.5;

    return Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_smallRadius), // Reduced border radius
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_smallRadius), // Reduced border radius
              // 🔥 Outline width set to 1.5 for subtle highlight 🔥
              border: Border.all(color: isSelected ? _cyanLight : _borderLightBlue, width: isSelected ? selectedBorderWidth : 1.0),
              boxShadow: [BoxShadow(color: isSelected ? _cyanDark.withOpacity(0.2) : Colors.black.withOpacity(0.06), blurRadius: isSelected ? 8 : 4, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                // Profile Picture/Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? _cyanLight : _primaryMedium.withOpacity(0.3), width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: ClipOval(
                    child: user.profileImagePath != null ? Image.file(File(user.profileImagePath!), fit: BoxFit.cover) : Icon(Icons.person, color: isSelected ? _cyanLight : _primaryMedium.withOpacity(0.6), size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                // Username
                Expanded(
                  child: Text(
                    user.username,
                    style: _bodyStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 14), // Improved font
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Selection Indicator (Verified Badge)
                isSelected ? const Icon(Icons.verified_rounded, color: _cyanLight, size: 22) : const Icon(CupertinoIcons.circle, color: _borderLightBlue, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
