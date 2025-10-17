import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/user_model.dart';
import '../screens/add_user_dialog.dart';

// Color constants for consistent theming
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
const Color _errorDark = Color(0xFFB91C1C);
const Color _purple = Color(0xFF8B5CF6);
const Color _pink = Color(0xFFEC4899);
const Color _orange = Color(0xFFF97316);

// Gradient definitions for visual elements
const LinearGradient _primaryGradient = LinearGradient(colors: [_primaryDark, _primaryMedium, _primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight);
const LinearGradient _confirmGradient = LinearGradient(colors: [Color(0xFF10B981), Color(0xFF06B6D4)], begin: Alignment.centerLeft, end: Alignment.centerRight);
const LinearGradient _addPlayerIconGradient = LinearGradient(colors: [_purple, _pink], begin: Alignment.topLeft, end: Alignment.bottomRight);
const LinearGradient _emptyStateIconGradient = LinearGradient(colors: [_pink, _orange], begin: Alignment.topLeft, end: Alignment.bottomRight);

// Typography and styling constants
// CHANGED: GoogleFonts.montserrat to GoogleFonts.poppins
final TextStyle _headingStyle = GoogleFonts.poppins(fontWeight: FontWeight.w700, color: _darkText);
final TextStyle _bodyStyle = GoogleFonts.poppins(fontSize: 14, color: _darkText);
final TextStyle _labelStyle = GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14, color: _textGrey);

const double _smallRadius = 10.0;
const double _dialogRadius = 16.0;

/// Dialog for selecting players from available users
/// Handles player selection with search functionality and validation
class PlayerSelectionDialog extends StatefulWidget {
  final int numberOfPlayers;
  final List<String> alreadySelectedPlayers;

  const PlayerSelectionDialog({super.key, required this.numberOfPlayers, required this.alreadySelectedPlayers});

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

  /// Loads all users from Hive storage and initializes current selection
  void _loadUsers() {
    final userBox = Hive.box<User>('usersBox');
    _allUsers = userBox.values.toList().cast<User>();
    _currentSelection.clear();

    // Re-select users based on names passed in, ignoring placeholders
    for (final playerName in widget.alreadySelectedPlayers) {
      final User? matchingUser = _allUsers.firstWhereOrNull((user) => user.username == playerName);

      if (matchingUser != null) {
        _currentSelection.add(matchingUser);
      }
    }

    _filterUsers();
  }

  /// Filters user list based on search query
  void _filterUsers() {
    final query = _searchController.text.toLowerCase();

    List<User> searchableUsers;

    if (query.isEmpty) {
      searchableUsers = _allUsers;
    } else {
      searchableUsers = _allUsers.where((user) => user.username.toLowerCase().contains(query)).toList();
    }

    setState(() {
      _filteredUsers = searchableUsers;
    });
  }

  /// Shows dialog to add new user to the system
  void _showAddUserDialog() {
    Get.dialog(
      AddUserDialog(
        onUserAdded: (username, imagePath) {
          final userBox = Hive.box<User>('usersBox');
          final newUser = User(username: username, profileImagePath: imagePath, wins: 0, rank: userBox.length + 1);
          userBox.add(newUser);
          _loadUsers();
        },
      ),
      barrierDismissible: true,
    );
  }

  /// Toggles player selection with validation for maximum players
  void _togglePlayerSelection(User user) {
    if (user.username.startsWith('Player ')) return; // Cannot select placeholder users

    setState(() {
      final isSelected = _currentSelection.contains(user);

      if (isSelected) {
        _currentSelection.remove(user);
      } else {
        if (_currentSelection.length < widget.numberOfPlayers) {
          _currentSelection.add(user);
        } else {
          _showToast('Cannot Select More Than ${widget.numberOfPlayers} Players.');
        }
      }
    });
    _filterUsers();
  }

  /// Checks if a user is currently selected
  bool _isPlayerSelected(User user) => _currentSelection.contains(user);

  /// Shows temporary toast message for user feedback
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
              border: Border.all(color: _errorRed.withOpacity(0.7), width: 1.2),
              boxShadow: [BoxShadow(color: _errorDark.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_rounded, color: _errorDark, size: 22),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    message,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _darkText),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      useSafeArea: true,
    );

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Get.isDialogOpen!) {
        Get.back();
      }
    });
  }

  /// Validates and confirms player selection
  void _confirmSelection() {
    if (_currentSelection.length != widget.numberOfPlayers) {
      _showToast('Please select exactly ${widget.numberOfPlayers} players to confirm.');
      return;
    }

    Get.back(result: _currentSelection);
  }

  /// Cancels selection and closes dialog
  void _cancelSelection() {
    Get.back(result: null);
  }

  // UI Builder Methods

  /// Builds dialog header with selection count and close button
  Widget _buildHeader(BuildContext context) {
    final selectedCount = _currentSelection.length;
    final totalCount = widget.numberOfPlayers;
    final isComplete = selectedCount == totalCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_smallRadius),
        boxShadow: [BoxShadow(color: _primaryMedium.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: _primaryGradient,
              borderRadius: BorderRadius.circular(_smallRadius),
              boxShadow: [BoxShadow(color: _primaryMedium.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: const Icon(Icons.group, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Players', style: _headingStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isComplete ? _cyanLight.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isComplete ? _cyanLight.withOpacity(0.8) : _iosBorder, width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$selectedCount',
                      style: _bodyStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 11, color: isComplete ? _cyanDark : _textGrey),
                    ),
                    const SizedBox(width: 4),
                    Container(height: 10, width: 1.0, color: isComplete ? _cyanDark.withOpacity(0.6) : _iosBorder),
                    const SizedBox(width: 4),
                    Text(
                      '$totalCount',
                      style: _bodyStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 11, color: _textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: _cancelSelection,
            borderRadius: BorderRadius.circular(_smallRadius),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_smallRadius),
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

  /// Builds search bar for filtering players
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      style: _bodyStyle.copyWith(fontSize: 14),
      decoration: InputDecoration(
        labelText: "Search Player",
        labelStyle: _labelStyle,
        prefixIcon: Container(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: const Icon(Icons.search_rounded, color: _primaryMedium, size: 22),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
          borderSide: const BorderSide(color: _borderLightBlue, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
          borderSide: const BorderSide(color: _primaryMedium, width: 1.8),
        ),
      ),
    );
  }

  /// Builds scrollable list of available players
  Widget _buildPlayersList() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_smallRadius),
        border: Border.all(color: _borderLightBlue, width: 1.0),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 270),
        child: _filteredUsers.isEmpty && _searchController.text.isNotEmpty
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

  /// Builds empty state when no players match search
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => _emptyStateIconGradient.createShader(bounds),
              child: const Icon(Icons.person_search_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'No players found.',
              style: _bodyStyle.copyWith(color: _textGrey, fontWeight: FontWeight.w600),
            ),
            Text('Try adding a new player below.', style: _bodyStyle.copyWith(color: _textGrey.withOpacity(0.7), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// Builds action buttons row (Add Player and Confirm)
  Widget _buildActionsRow() {
    final isConfirmEnabled = _currentSelection.length == widget.numberOfPlayers;
    const double buttonHeight = 44.0;
    const Color outlineColor = _iosBorder;
    const double outlineWidth = 1.5;
    const double innerPadding = 6;

    Widget _buildStyledButton({required String text, required IconData icon, required Color iconColor, required Color textColor, required Color borderColor, required VoidCallback onTap, LinearGradient? gradient, LinearGradient? iconGradient, bool isFilled = false, bool isEnabled = true}) {
      Widget iconWidget = Icon(icon, size: 20, color: isFilled && isEnabled ? Colors.white : iconColor.withOpacity(isEnabled ? 1.0 : 0.5));

      if (iconGradient != null && !isFilled) {
        iconWidget = ShaderMask(
          shaderCallback: (bounds) => iconGradient.createShader(bounds),
          child: const Icon(CupertinoIcons.person_add_solid, size: 20, color: Colors.white),
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
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isFilled && isEnabled ? Colors.white : textColor.withOpacity(isEnabled ? 1.0 : 0.5), fontSize: 14),
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
          _buildStyledButton(text: 'Add Player', icon: CupertinoIcons.person_add_solid, iconColor: _purple, textColor: _purple, borderColor: _purple.withOpacity(0.4), onTap: _showAddUserDialog, iconGradient: _addPlayerIconGradient, isEnabled: true),
          const SizedBox(width: 8),
          _buildStyledButton(text: 'Confirm', icon: Icons.verified_rounded, iconColor: _primaryMedium, textColor: isConfirmEnabled ? Colors.white : _darkText, borderColor: isConfirmEnabled ? Colors.transparent : _iosBorder, onTap: isConfirmEnabled ? _confirmSelection : () => _showToast('Please select ${widget.numberOfPlayers - _currentSelection.length} more players.'), gradient: _confirmGradient, isFilled: isConfirmEnabled, isEnabled: isConfirmEnabled),
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
          borderRadius: BorderRadius.circular(_dialogRadius),
          boxShadow: [BoxShadow(color: _primaryMedium.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [_buildHeader(context), const SizedBox(height: 20), _buildSearchBar(), const SizedBox(height: 16), _buildPlayersList(), const SizedBox(height: 20), _buildActionsRow()]),
        ),
      ),
    );
  }
}

/// Individual player list item widget
/// Displays user information and selection state
class _PlayerListItem extends StatelessWidget {
  final User user;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlayerListItem({required this.user, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const double selectedBorderWidth = 1.8;
    const double normalBorderWidth = 1.0;

    final isPlaceholder = user.username.startsWith('Player ');

    return Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isPlaceholder ? null : onTap,
          borderRadius: BorderRadius.circular(_smallRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_smallRadius),
              border: Border.all(color: isSelected ? _cyanLight : _iosBorder, width: isSelected ? selectedBorderWidth : normalBorderWidth),
              boxShadow: [BoxShadow(color: isSelected ? _cyanDark.withOpacity(0.2) : Colors.black.withOpacity(0.03), blurRadius: isSelected ? 8 : 4, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? _cyanLight : _iosBorder.withOpacity(0.8), width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: ClipOval(
                    child: user.profileImagePath != null ? Image.file(File(user.profileImagePath!), fit: BoxFit.cover) : Icon(isPlaceholder ? Icons.person_outline : Icons.person, color: isSelected ? _cyanLight : _primaryMedium.withOpacity(0.6), size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.username,
                    style: _bodyStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 14, color: isPlaceholder ? _textGrey : _darkText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) const Icon(Icons.verified_rounded, color: _cyanDark, size: 22) else if (!isPlaceholder) const Icon(CupertinoIcons.circle, color: _borderLightBlue, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
