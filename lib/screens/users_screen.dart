// lib/screens/users_screen.dart

import 'dart:async';
import 'dart:io';

import 'package:calculators/model/user_model.dart';
import 'package:calculators/screens/add_user_dialog.dart';
import 'package:calculators/widgets/user_stats_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';

import '../controllers/user_list_controller.dart';
import '../widgets/moder_app_bar.dart';

/// Users management screen with leaderboard and player statistics
/// Features a 3D carousel for top players and comprehensive user management
class UsersScreen extends StatefulWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  UsersScreen({super.key, required this.tag, required this.color, required this.iconData});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  // Constant for continuous scrolling (a large number)
  static const int _kInfinitePageCount = 999999;

  @override
  void initState() {
    super.initState();
    final initialPage = _kInfinitePageCount ~/ 2;
    _currentPage = initialPage;
    // viewportFraction remains 0.90 for a long center card with minimal adjacent visibility
    _pageController = PageController(viewportFraction: 0.90, initialPage: initialPage);
    _startAutoPlay();
  }

  /// Starts automatic carousel scrolling for top users
  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final int topUserCount = _getTopUsersCount();
        if (topUserCount > 0) {
          _currentPage++;
          _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
        }
      }
    });
  }

  /// Gets the count of top users for carousel display
  int _getTopUsersCount() {
    final box = Hive.box<User>('usersBox');
    final users = box.values.toList().cast<User>();
    final sortedUsers = _sortUsersByWins(users, Get.find<UserListController>());
    return sortedUsers.length > 3 ? 3 : sortedUsers.length;
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserListController controller = Get.put(UserListController());

    return Scaffold(
      appBar: ModernAppBar(title: "Player Management"),
      backgroundColor: const Color(0xFFF8FAFF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          final bool isSmall = constraints.maxWidth < 350;

          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF8FAFF), Color(0xFFF0F7FF), Color(0xFFE8F4FF)]),
            ),
            child: ValueListenableBuilder(
              valueListenable: Hive.box<User>('usersBox').listenable(),
              builder: (context, Box<User> box, _) {
                final users = box.values.toList().cast<User>();
                final sortedUsers = _sortUsersByWins(users, controller);
                final top3Users = sortedUsers.take(3).toList();

                if (users.isEmpty) {
                  return _buildEmptyState(isTablet, isSmall);
                }

                return Column(
                  children: [
                    // Leaderboard Title Section
                    Padding(
                      // Standard horizontal padding, slightly reduced top padding for compactness
                      padding: EdgeInsets.fromLTRB(isTablet ? 20 : 16, isTablet ? 20 : 16, isTablet ? 20 : 16, isTablet ? 10 : 8),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isTablet ? 12 : 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.15), width: 1.5),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.08), blurRadius: 12, spreadRadius: 0, offset: const Offset(0, 4)),
                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, spreadRadius: 0, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Icon(Icons.emoji_events_rounded, color: const Color(0xFFFF6B35), size: isTablet ? 28 : 24),
                          ),
                          SizedBox(width: isTablet ? 14 : 12),
                          Text(
                            "Leaderboard",
                            style: GoogleFonts.quicksand(
                              fontSize: isTablet
                                  ? 20
                                  : isSmall
                                  ? 16
                                  : 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3D STACKED CAROUSEL
                    Padding(
                      // FURTHER REDUCED VERTICAL MARGIN for maximum compactness
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12, vertical: isTablet ? 4 : 2),
                      child: _build3DLeaderboardCarousel(top3Users, controller, isTablet, isSmall),
                    ),

                    // REDUCED SPACE BETWEEN DOTS AND LIST
                    SizedBox(height: isTablet ? 8 : 4),

                    // Player List
                    Expanded(
                      child: Padding(
                        // Applied horizontal padding for margin consistency
                        padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, spreadRadius: 0, offset: const Offset(0, 4)),
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, spreadRadius: 0, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12, horizontal: isTablet ? 16 : 12),
                            itemCount: sortedUsers.length,
                            itemBuilder: (context, index) {
                              final user = sortedUsers[index];
                              return _CleanUserTile(user: user, rank: index + 1, isTablet: isTablet, isSmall: isSmall, onEdit: () => _showEditUserDialog(context, user));
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isTablet ? 20 : 16),
                  ],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          return Container(
            width: isTablet ? 60 : 56,
            height: isTablet ? 60 : 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF00B8FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
              boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: FloatingActionButton(
              onPressed: () => _showAddUserDialog(context),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [
                    // iOS-like glow effect
                    BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.5), blurRadius: 20, spreadRadius: 3, offset: const Offset(0, 8)),
                    // Subtle shadow for depth
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                ),
                child: const Icon(Icons.supervisor_account_rounded, color: Colors.white, size: 28),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the 3D leaderboard carousel with animated page transitions
  Widget _build3DLeaderboardCarousel(List<User> top3Users, UserListController controller, bool isTablet, bool isSmall) {
    if (top3Users.isEmpty) return const SizedBox.shrink();

    // REDUCED HEIGHT for a compact look
    final double carouselHeight = isTablet
        ? 95
        : isSmall
        ? 75
        : 85;

    return Column(
      children: [
        Container(
          height: carouselHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: top3Users.length < 2 ? top3Users.length : _kInfinitePageCount,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final userIndex = index % top3Users.length;
              final user = top3Users[userIndex];
              final rank = userIndex + 1;

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  double pagePosition = (_pageController.page ?? _currentPage).toDouble();
                  double pageDiff = pagePosition - index;

                  // Scale effect (value gets smaller as it moves away from the center)
                  value = (1 - (pageDiff.abs() * 0.2)).clamp(0.8, 1.0);

                  // 3D tilt effect on the y-axis for inactive cards
                  double rotation = (pageDiff * 0.1).clamp(-0.1, 0.1);

                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateY(rotation), // 3D Y-axis rotation
                    alignment: Alignment.center,
                    // Apply scale and use the _buildCleanUserTileForCarousel
                    child: Transform.scale(scale: value, child: _buildCleanUserTileForCarousel(user, rank, isTablet, isSmall)),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: isTablet ? 8 : 6),
        // Carousel Indicator (Small Blue Indicator)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(top3Users.length, (dotIndex) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              height: isTablet ? 5 : 4,
              // Modulo operator to get the visible current index
              width: (_currentPage % top3Users.length) == dotIndex ? (isTablet ? 14 : 12) : (isTablet ? 5 : 4),
              decoration: BoxDecoration(color: (_currentPage % top3Users.length) == dotIndex ? const Color(0xFF0066FF) : Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
            );
          }),
        ),
      ],
    );
  }

  /// Builds individual carousel item with scaling and transformation
  Widget _buildCleanUserTileForCarousel(User user, int rank, bool isTablet, bool isSmall) {
    return Container(
      // REDUCED VERTICAL MARGIN for compactness
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 4 : 2, vertical: isTablet ? 2 : 1),
      decoration: BoxDecoration(
        color: Colors.transparent, // Transparent as _CleanUserTile has its own styling
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        // Shadows are now handled by _CleanUserTile itself
      ),
      child: _CleanUserTile(user: user, rank: rank, isTablet: isTablet, isSmall: isSmall, onEdit: () => _showEditUserDialog(context, user)),
    );
  }

  /// Sorts users by wins in descending order
  List<User> _sortUsersByWins(List<User> users, UserListController controller) {
    users.sort((a, b) {
      final aWins = controller.userStats[a.username]?.totalWins ?? 0;
      final bWins = controller.userStats[b.username]?.totalWins ?? 0;
      return bWins.compareTo(aWins);
    });
    return users;
  }

  /// Builds empty state when no users are available
  Widget _buildEmptyState(bool isTablet, bool isSmall) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet
                ? 200
                : isSmall
                ? 140
                : 160,
            height: isTablet
                ? 200
                : isSmall
                ? 140
                : 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.1), width: 2),
            ),
            child: Lottie.asset("assets/lottie/intro2.json", fit: BoxFit.contain),
          ),
          SizedBox(
            height: isTablet
                ? 28
                : isSmall
                ? 16
                : 20,
          ),
          Text(
            "No Players Yet",
            style: GoogleFonts.quicksand(
              fontSize: isTablet
                  ? 24
                  : isSmall
                  ? 18
                  : 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(
            height: isTablet
                ? 8
                : isSmall
                ? 4
                : 6,
          ),
          Text(
            "Tap + to add your first player",
            style: GoogleFonts.poppins(
              fontSize: isTablet
                  ? 15
                  : isSmall
                  ? 12
                  : 13,
              color: const Color(0xFF5A6C8A),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Shows dialog to add a new user
  void _showAddUserDialog(BuildContext context) {
    final UserListController controller = Get.find<UserListController>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddUserDialog(
          onUserAdded: (username, imagePath) {
            final userBox = Hive.box<User>('usersBox');
            final newUser = User(username: username, profileImagePath: imagePath, wins: 0, rank: userBox.length + 1);
            userBox.add(newUser);
            controller.refreshStats();
          },
        );
      },
    );
  }

  /// Shows dialog to edit an existing user
  void _showEditUserDialog(BuildContext context, User user) {
    final UserListController controller = Get.find<UserListController>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddUserDialog(
          userToEdit: user, // Pass the user to edit
          onUserAdded: (username, imagePath) {
            // This won't be called in edit mode
          },
          onUserUpdated: (username, imagePath) {
            // Store the old username before updating
            final String oldUsername = user.username;

            // Update the user in Hive
            final userBox = Hive.box<User>('usersBox');
            final userIndex = userBox.values.toList().indexWhere((u) => u.username == oldUsername);
            if (userIndex != -1) {
              final updatedUser = User(
                username: username,
                profileImagePath: imagePath,
                wins: user.wins, // Keep existing wins
                rank: user.rank, // Keep existing rank
              );
              userBox.putAt(userIndex, updatedUser);

              // Update user stats with new username if username changed
              if (oldUsername != username) {
                _updateUserStatsReferences(oldUsername, username, controller);
              }

              controller.refreshStats();
            }
          },
        );
      },
    );
  }

  /// Updates all user stats references when username changes
  void _updateUserStatsReferences(String oldUsername, String newUsername, UserListController controller) {
    // Update userStats in controller
    if (controller.userStats.containsKey(oldUsername)) {
      final userStat = controller.userStats[oldUsername];
      controller.userStats[newUsername] = userStat!;
      controller.userStats.remove(oldUsername);
      controller.update(); // Notify listeners about the change
    }

    // Update Hive storage for game history
    _updateGameHistoryReferences(oldUsername, newUsername);

    // Update any other references
    _updateOtherReferences(oldUsername, newUsername);
  }

  /// Updates game history references when username changes
  void _updateGameHistoryReferences(String oldUsername, String newUsername) {
    try {
      // If you have a game history box
      final gameHistoryBox = Hive.box('gameHistory');
      final gameHistory = gameHistoryBox.values.toList();

      for (int i = 0; i < gameHistory.length; i++) {
        final game = gameHistory[i];
        // Update based on your game history structure
        if (game is Map && game['playerName'] == oldUsername) {
          game['playerName'] = newUsername;
          gameHistoryBox.putAt(i, game);
        }
        // Add more conditions based on your data structure
      }
    } catch (e) {
      // Error handled silently in production
    }
  }

  /// Updates other references like achievements and sessions
  void _updateOtherReferences(String oldUsername, String newUsername) {
    try {
      // Update achievements if you have them
      final achievementsBox = Hive.box('achievements');
      final achievements = achievementsBox.values.toList();

      for (int i = 0; i < achievements.length; i++) {
        final achievement = achievements[i];
        if (achievement is Map && achievement['playerName'] == oldUsername) {
          achievement['playerName'] = newUsername;
          achievementsBox.putAt(i, achievement);
        }
      }
    } catch (e) {
      // Error handled silently in production
    }

    try {
      // Update sessions if you have them
      final sessionsBox = Hive.box('sessions');
      final sessions = sessionsBox.values.toList();

      for (int i = 0; i < sessions.length; i++) {
        final session = sessions[i];
        if (session is Map && session['playerName'] == oldUsername) {
          session['playerName'] = newUsername;
          sessionsBox.putAt(i, session);
        }
      }
    } catch (e) {
      // Error handled silently in production
    }
  }
}

/// Clean user tile widget for displaying individual player information
/// Used in both carousel and list views with consistent styling
class _CleanUserTile extends StatelessWidget {
  final User user;
  final int rank;
  final bool isTablet;
  final bool isSmall;
  final VoidCallback? onEdit;

  const _CleanUserTile({super.key, required this.user, required this.rank, required this.isTablet, required this.isSmall, this.onEdit});

  /// Gets rank configuration including colors, icons and gradients
  RankConfig _getRankConfig(int rank) {
    switch (rank) {
      case 1:
        return RankConfig(
          color: const Color(0xFFFF6B35),
          icon: Icons.workspace_premium_rounded,
          text: "1",
          gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)]),
        );
      case 2:
        return RankConfig(
          color: const Color(0xFFC0C0C0),
          icon: Icons.emoji_events_rounded,
          text: "2",
          gradient: const LinearGradient(colors: [Color(0xFFE8E8E8), Color(0xFFB0B0B0)]),
        );
      case 3:
        return RankConfig(
          color: const Color(0xFFCD7F32),
          icon: Icons.emoji_events_rounded,
          text: "3",
          gradient: const LinearGradient(colors: [Color(0xFFCD7F32), Color(0xFF8B4513)]),
        );
      default:
        return RankConfig(
          color: const Color(0xFF667EEA),
          icon: Icons.person,
          text: rank.toString(),
          gradient: const LinearGradient(colors: [Colors.pink, Colors.orange]),
        );
    }
  }

  /// Builds user avatar with initials or profile image
  Widget _buildAvatar(String username) {
    final double size = isTablet ? 48.0 : 42.0;
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)])),
      child: Center(
        child: Text(
          _getInitials(username),
          style: GoogleFonts.quicksand(fontSize: size * 0.4, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
    );
  }

  /// Extracts initials from username for avatar display
  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  /// Shows user statistics dialog
  void _showUserStatsDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (context) => UserStatsDialog(userName: userName),
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserListController controller = Get.find<UserListController>();
    final rankConfig = _getRankConfig(rank);

    // This Container's margin is now controlled by the parent ListView or Carousel wrapper
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 10 : 8), // Spacing between list items
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        // Shadow moved here to adhere to the rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.12), // Slightly darker, more prominent shadow
            blurRadius: 6, // Reduced blur for a smaller shadow
            spreadRadius: -2, // Negative spread to make it even smaller/tighter
            offset: const Offset(0, 5), // Reduced vertical offset
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7), // Subtle top highlight for lift
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, -3), // Slightly offset upwards
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showUserStatsDialog(context, user.username),
          onLongPress: onEdit, // Add long press handler
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 14 : 12),
            child: Row(
              children: [
                // Rank display
                Container(
                  width: isTablet ? 40 : 36,
                  height: isTablet ? 40 : 36,
                  decoration: BoxDecoration(gradient: rankConfig.gradient, borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: rank <= 3
                        ? Icon(rankConfig.icon, color: Colors.white, size: isTablet ? 18 : 16)
                        : Text(
                            "$rank",
                            style: GoogleFonts.quicksand(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                  ),
                ),
                SizedBox(width: isTablet ? 14 : 12),
                // Avatar display
                Container(
                  width: isTablet ? 48 : 42,
                  height: isTablet ? 48 : 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade300.withOpacity(0.5), width: 1.5),
                  ),
                  child: ClipOval(
                    child: user.profileImagePath != null ? Image.file(File(user.profileImagePath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildAvatar(user.username)) : _buildAvatar(user.username),
                  ),
                ),
                SizedBox(width: isTablet ? 14 : 12),
                // User information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: GoogleFonts.quicksand(
                          fontSize: isTablet
                              ? 16
                              : isSmall
                              ? 13
                              : 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        final userStat = controller.userStats[user.username];
                        final wins = userStat?.totalWins ?? 0;
                        final level = userStat?.level ?? 1;

                        return Row(
                          children: [
                            Text(
                              "Victory",
                              style: GoogleFonts.poppins(fontSize: isTablet ? 11 : 10, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "$wins",
                              style: GoogleFonts.quicksand(fontSize: isTablet ? 11 : 10, fontWeight: FontWeight.w800, color: Colors.grey.shade800),
                            ),
                            Container(
                              width: 1,
                              height: 12,
                              margin: EdgeInsets.symmetric(horizontal: isTablet ? 10 : 8),
                              color: Colors.grey.shade400,
                            ),
                            Text(
                              "Level",
                              style: GoogleFonts.poppins(fontSize: isTablet ? 11 : 10, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "$level",
                              style: GoogleFonts.quicksand(fontSize: isTablet ? 11 : 10, fontWeight: FontWeight.w800, color: Colors.grey.shade800),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                // Info icon
                Container(
                  width: isTablet ? 36 : 32,
                  height: isTablet ? 36 : 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0044CC)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.info_outline_rounded, color: Colors.white, size: isTablet ? 18 : 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Configuration class for rank display properties
class RankConfig {
  final Color color;
  final IconData icon;
  final String text;
  final Gradient gradient;

  RankConfig({required this.color, required this.icon, required this.text, required this.gradient});
}
