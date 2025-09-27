// widgets/player_selection_dialog.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/user_model.dart';
import '../screens/add_user_dialog.dart';

class PlayerSelectionDialog extends StatefulWidget {
  final int numberOfPlayers;
  final List<String> alreadySelectedPlayers;
  final Function(User user) onPlayerSelected;

  const PlayerSelectionDialog({super.key, required this.numberOfPlayers, required this.alreadySelectedPlayers, required this.onPlayerSelected});

  @override
  State<PlayerSelectionDialog> createState() => _PlayerSelectionDialogState();
}

class _PlayerSelectionDialogState extends State<PlayerSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  void _loadUsers() {
    final users = Hive.box<User>('usersBox').values.toList().cast<User>();
    setState(() {
      _filteredUsers = users;
    });
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    final allUsers = Hive.box<User>('usersBox').values.toList().cast<User>();

    setState(() {
      if (query.isEmpty) {
        _filteredUsers = allUsers;
      } else {
        _filteredUsers = allUsers.where((user) => user.username.toLowerCase().contains(query)).toList();
      }
    });
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(
        onUserAdded: (username, imagePath) {
          final userBox = Hive.box<User>('usersBox');
          final newUser = User(username: username, profileImagePath: imagePath, wins: 0, rank: userBox.length + 1);
          userBox.add(newUser);
          _loadUsers();
        },
      ),
    );
  }

  bool _isPlayerSelected(String userId) {
    return widget.alreadySelectedPlayers.contains(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.12), blurRadius: 30, offset: const Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.people, size: 18, color: Color(0xFF0066FF)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Players (${widget.numberOfPlayers})',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D2B)),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF5A6C8A)),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search Bar
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE1E8F5)),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search players...',
                    hintStyle: GoogleFonts.poppins(color: const Color(0xFF5A6C8A)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF0066FF), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Players List
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: _filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _PlayerListItem(user: user, isSelected: _isPlayerSelected(user.username), onTap: () => widget.onPlayerSelected(user));
                        },
                      ),
              ),

              const SizedBox(height: 16),

              // Add New Player Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _showAddUserDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0066FF),
                    side: BorderSide(color: const Color(0xFF0066FF).withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Add New Player', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: const Color(0xFF5A6C8A).withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No players found', style: GoogleFonts.poppins(color: const Color(0xFF5A6C8A))),
        ],
      ),
    );
  }
}

class _PlayerListItem extends StatelessWidget {
  final User user;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlayerListItem({required this.user, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0066FF).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? const Color(0xFF0066FF) : const Color(0xFFE1E8F5), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.2)),
                  ),
                  child: ClipOval(
                    child: user.profileImagePath != null ? Image.file(File(user.profileImagePath!), fit: BoxFit.cover) : Icon(Icons.person, color: const Color(0xFF0066FF).withOpacity(0.6)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.username,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: const Color(0xFF1A1D2B)),
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF0066FF), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
