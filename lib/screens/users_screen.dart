// lib/screens/users_screen.dart

import 'dart:io';

import 'package:calculators/model/user_model.dart';
import 'package:calculators/screens/add_user_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';

import '../widgets/moder_app_bar.dart';

class UsersScreen extends StatelessWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  UsersScreen({super.key, required this.tag, required this.color, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(title: "User Detail"),
      backgroundColor: const Color(0xFFF8FAFF),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF8FAFF), Color(0xFFF0F7FF), Color(0xFFE8F4FF)]),
        ),
        child: Column(
          children: [
            // Stats Overview Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.white, const Color(0xFFF0F7FF)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
                    BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 10, offset: const Offset(0, -4)),
                  ],
                ),
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<User>('usersBox').listenable(),
                  builder: (context, Box<User> box, _) {
                    final users = box.values.toList();
                    final totalWins = users.fold(0, (sum, user) => sum + user.wins);
                    final activeUsers = users.length;

                    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStatItem("Total Players", users.length.toString(), Icons.people_alt_rounded), _buildStatItem("Active Games", "12", Icons.sports_esports_rounded), _buildStatItem("Total Wins", totalWins.toString(), Icons.emoji_events_rounded)]);
                  },
                ),
              ),
            ),

            // Reactive list builder using Hive
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<User>('usersBox').listenable(),
                builder: (context, Box<User> box, _) {
                  final users = box.values.toList().cast<User>();

                  if (users.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Text(
                            "Player Rankings • ${users.length} Players",
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D2B), letterSpacing: -0.3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return _UserTile(user: user, rank: index + 1, accentColor: const Color(0xFF0066FF));
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: const Color(0xFF0066FF),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF00B8FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFF0066FF).withOpacity(0.1), const Color(0xFF0066FF).withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.2), width: 1.5),
          ),
          child: Icon(icon, size: 24, color: const Color(0xFF0066FF)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2B)),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF5A6C8A)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Modern Empty State with Glassmorphism
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF).withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.1), width: 2),
                ),
                child: Lottie.asset("assets/lottie/empty.json", fit: BoxFit.contain),
              ),
              const SizedBox(height: 24),
              Text(
                "No Players Yet",
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2B), letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                "Start by adding your first player to\nbegin tracking their progress",
                style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF5A6C8A), height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _showAddUserDialog(navigatorKey.currentContext!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: Text(
                  "Add First Player",
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddUserDialog(
          onUserAdded: (username, imagePath) {
            final userBox = Hive.box<User>('usersBox');
            final newUser = User(username: username, profileImagePath: imagePath, wins: 0, rank: userBox.length + 1);
            userBox.add(newUser);
          },
        );
      },
    );
  }
}

// Modern User Tile with Reduced Height and More Elevation
class _UserTile extends StatelessWidget {
  final User user;
  final int rank;
  final Color accentColor;

  const _UserTile({required this.user, required this.rank, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    IconData rankIcon = Icons.person;
    Color rankColor = const Color(0xFF5A6C8A);

    if (rank == 1) {
      rankIcon = Icons.workspace_premium_rounded;
      rankColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      rankIcon = Icons.emoji_events_rounded;
      rankColor = const Color(0xFFC0C0C0);
    } else if (rank == 3) {
      rankIcon = Icons.emoji_events_rounded;
      rankColor = const Color(0xFFCD7F32);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to user profile
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
              boxShadow: [
                BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 6)),
                BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 8, offset: const Offset(-2, -2)),
              ],
            ),
            child: Row(
              children: [
                // Rank Badge - Removed # symbol
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: rank <= 3 ? rankColor.withOpacity(0.1) : accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: rank <= 3 ? rankColor.withOpacity(0.3) : accentColor.withOpacity(0.2), width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(1, 1))],
                  ),
                  child: Center(
                    child: Text(
                      rank.toString(), // Removed # symbol
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: rank <= 3 ? rankColor : accentColor),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Profile Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withOpacity(0.2), width: 2),
                    boxShadow: [BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: ClipOval(
                    child: user.profileImagePath != null ? Image.file(File(user.profileImagePath!), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholderAvatar()) : _buildPlaceholderAvatar(),
                  ),
                ),

                const SizedBox(width: 12),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D2B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${user.wins} Wins • Level ${(user.wins ~/ 10) + 1}',
                        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF5A6C8A), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                // Rank Icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: rank <= 3 ? rankColor.withOpacity(0.1) : accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: rank <= 3 ? rankColor.withOpacity(0.2) : accentColor.withOpacity(0.1), width: 1),
                  ),
                  child: Icon(rankIcon, color: rank <= 3 ? rankColor : accentColor, size: 18),
                ),

                const SizedBox(width: 8),

                // Chevron
                Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFF5A6C8A).withOpacity(0.5), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accentColor.withOpacity(0.1), accentColor.withOpacity(0.05)]),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person_rounded, color: accentColor.withOpacity(0.6), size: 20),
    );
  }
}
