import 'dart:io';

import 'package:calculators/controllers/user_list_controller.dart';
import 'package:calculators/model/user_model.dart';
import 'package:calculators/screens/call_break_screen.dart';
import 'package:calculators/screens/game_history_screen.dart';
import 'package:calculators/screens/marriage_screen.dart';
import 'package:calculators/screens/rules_screen.dart';
import 'package:calculators/screens/users_screen.dart';
import 'package:calculators/widgets/user_stats_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';

// ==================== DATA MODELS AND CONSTANTS ====================

/// Represents a grid item in the home screen
class GridItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color gradientStart;
  final Color gradientEnd;
  final String shortDescription;

  const GridItem(this.icon, this.label, this.color, this.shortDescription, {Color? gradientStart, Color? gradientEnd}) : gradientStart = gradientStart ?? color, gradientEnd = gradientEnd ?? color;
}

/// Modern color scheme for the application
class ModernColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color onSurface = Color(0xFF1E293B);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color primaryContainer = Color(0xFFEEF2FF);
}

// ==================== MODERN APP BAR ====================

/// Custom modern app bar for home screen
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ModernAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(50.0);

  /// Builds floating circle decoration element
  Widget _buildFloatingShape(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  /// Builds the decorative background for app bar
  Widget _buildAppBarDecoration(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ModernColors.primary.withOpacity(0.05), ModernColors.primary.withOpacity(0.02)]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12.0)),
      ),
      child: Stack(
        children: [
          Positioned(top: -10, left: 20, child: _buildFloatingShape(25, ModernColors.primary.withOpacity(0.08))),
          Positioned(bottom: 10, right: 40, child: _buildFloatingShape(40, ModernColors.primary.withOpacity(0.06))),
          Positioned(top: 30, left: 100, child: _buildFloatingShape(30, ModernColors.primary.withOpacity(0.1))),
          Positioned(top: 5, right: 80, child: _buildFloatingShape(15, ModernColors.primary.withOpacity(0.12))),
          Positioned(bottom: -5, left: 120, child: _buildFloatingShape(20, ModernColors.primary.withOpacity(0.08))),
          Positioned(bottom: -15, right: 5, child: _buildFloatingShape(35, ModernColors.primary.withOpacity(0.06))),
          Positioned(top: -25, right: 15, child: _buildFloatingShape(50, ModernColors.primary.withOpacity(0.08))),
          Positioned(top: 55, left: 5, child: _buildFloatingShape(10, ModernColors.primary.withOpacity(0.1))),
          Positioned(top: -5, left: 180, child: _buildFloatingShape(22, ModernColors.primary.withOpacity(0.07))),
          Positioned(bottom: 25, left: 50, child: _buildFloatingShape(18, ModernColors.primary.withOpacity(0.09))),
          Positioned(top: 15, right: 20, child: _buildFloatingShape(14, ModernColors.primary.withOpacity(0.12))),
          Positioned(top: 5, left: 50, child: _buildFloatingShape(16, ModernColors.primary.withOpacity(0.08))),
          Positioned(top: 40, right: 100, child: _buildFloatingShape(12, ModernColors.primary.withOpacity(0.1))),
          Positioned(bottom: 0, left: 30, child: _buildFloatingShape(22, ModernColors.primary.withOpacity(0.06))),
          Positioned(bottom: 40, right: 10, child: _buildFloatingShape(18, ModernColors.primary.withOpacity(0.12))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15.0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 7, offset: const Offset(0, 2))],
      ),
      child: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0))),
        title: Text(
          title,
          style: GoogleFonts.poppins(letterSpacing: 1.0, fontSize: 17, fontWeight: FontWeight.w800, color: ModernColors.onSurface),
        ),
        centerTitle: true,
        leading: Container(), // Empty container to remove back button
        actions: const [],
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12.0)),
          child: Column(
            children: [
              Expanded(child: _buildAppBarDecoration(context)),
              Container(
                height: 1.5,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [ModernColors.outline.withOpacity(0.8), ModernColors.outline.withOpacity(0.4), ModernColors.outline.withOpacity(0.8)])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== MAIN HOME SCREEN ====================

/// Main home screen with search functionality and game navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserListController _userController = Get.find<UserListController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchText = '';
  List<GridItem> _filteredItems = [];
  List<User> _filteredUsers = [];

  /// All available grid items with descriptions
  final List<GridItem> _allGridItems = [GridItem(Icons.favorite_rounded, "Marriage", const Color(0xFFEC4899), "Track marriage scores", gradientStart: const Color(0xFFEC4899), gradientEnd: const Color(0xFFF59E0B)), GridItem(Icons.star, "Call Break", const Color(0xFF3B82F6), "Card game scoring", gradientStart: const Color(0xFF3B82F6), gradientEnd: const Color(0xFF06B6D4)), GridItem(Icons.timelapse_rounded, "History", const Color(0xFF8B5CF6), "Game history records", gradientStart: const Color(0xFF8B5CF6), gradientEnd: const Color(0xFFEC4899)), GridItem(Icons.people_rounded, "Users", const Color(0xFFF59E0B), "Manage players", gradientStart: const Color(0xFFF59E0B), gradientEnd: const Color(0xFFEF4444)), GridItem(Icons.menu_book_rounded, "Manual", const Color(0xFF10B981), "Game rules guide", gradientStart: const Color(0xFF10B981), gradientEnd: const Color(0xFF3B82F6))];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allGridItems;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Determines appropriate greeting based on time of day
  String _greetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  /// Filters items and users based on search query
  void _filterItems(String query) {
    final lowerCaseQuery = query.toLowerCase();

    // Filter grid items
    final filteredGrid = _allGridItems.where((item) => item.label.toLowerCase().contains(lowerCaseQuery)).toList();

    // Filter users from Hive
    List<User> filteredUsers = [];
    if (Hive.isBoxOpen('usersBox')) {
      final userBox = Hive.box<User>('usersBox');
      filteredUsers = userBox.values.where((user) => user.username.toLowerCase().contains(lowerCaseQuery)).toList();
    }

    setState(() {
      _searchText = query;
      _filteredItems = filteredGrid;
      _filteredUsers = filteredUsers;
    });
  }

  /// Shows user statistics dialog
  void _showUserStatsDialog(String userName) {
    showDialog(
      context: context,
      builder: (context) => UserStatsDialog(userName: userName),
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }

  /// Clears search and resets to default state
  void _clearSearch() {
    setState(() {
      _searchText = '';
      _filteredItems = _allGridItems;
      _filteredUsers = [];
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768;
    final isDesktop = size.width >= 1024;
    final greeting = _greetingMessage();

    final double horizontalMargin = isDesktop
        ? 22.0
        : isTablet
        ? 20.0
        : 18.0;

    return Scaffold(
      appBar: const ModernAppBar(title: "Home"),
      backgroundColor: ModernColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Greeting and Search Container
            Container(
              margin: EdgeInsets.only(
                left: horizontalMargin,
                right: horizontalMargin,
                top: isDesktop
                    ? 14.0
                    : isTablet
                    ? 12.0
                    : 10.0,
                bottom: horizontalMargin,
              ),
              decoration: BoxDecoration(
                color: ModernColors.surface,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: ModernColors.outline, width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18.0, offset: const Offset(0, 8)),
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8.0, offset: const Offset(0, 2)),
                ],
              ),
              child: _buildMainContainerContent(greeting, isDesktop, isTablet),
            ),

            // Search Results or Main Content
            if (_searchText.isNotEmpty)
              _buildSearchResultsOverlay(isDesktop, isTablet, horizontalMargin)
            else
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: horizontalMargin, right: horizontalMargin, top: 0.0, bottom: 10.0),
                  decoration: BoxDecoration(
                    color: ModernColors.surface,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: ModernColors.outline, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18.0, offset: const Offset(0, 8)),
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8.0, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: _filteredItems.isEmpty
                      ? _buildEmptyState(isDesktop)
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.all(
                            isDesktop
                                ? 14.0
                                : isTablet
                                ? 12.0
                                : 10.0,
                          ),
                          children: [
                            ..._filteredItems.map(
                              (item) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: isDesktop
                                      ? 18.0
                                      : isTablet
                                      ? 16.0
                                      : 14.0,
                                ),
                                child: _ModernFullWidthCard(gridItem: item, isDesktop: isDesktop, isTablet: isTablet),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the main container content with greeting and search
  Widget _buildMainContainerContent(String greeting, bool isDesktop, bool isTablet) {
    return Column(
      children: [
        // Greeting and Lottie Section
        Container(
          padding: EdgeInsets.all(
            isDesktop
                ? 18.0
                : isTablet
                ? 16.0
                : 14.0,
          ),
          child: Row(
            children: [
              // Greeting Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop
                            ? 22.0
                            : isTablet
                            ? 20.0
                            : 18.0,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Welcome to Game Hub",
                      style: GoogleFonts.quicksand(
                        fontSize: isDesktop
                            ? 13.0
                            : isTablet
                            ? 12.0
                            : 11.0,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),
              // Lottie Animation
              Container(
                width: isDesktop
                    ? 70.0
                    : isTablet
                    ? 65.0
                    : 60.0,
                height: isDesktop
                    ? 70.0
                    : isTablet
                    ? 65.0
                    : 60.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: ModernColors.outline, width: 1.5),
                  color: ModernColors.primaryContainer,
                ),
                child: Center(
                  child: Lottie.asset(
                    'assets/lottie/intro1.json',
                    width: isDesktop
                        ? 60.0
                        : isTablet
                        ? 55.0
                        : 50.0,
                    height: isDesktop
                        ? 60.0
                        : isTablet
                        ? 55.0
                        : 50.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Divider
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? 18.0
                : isTablet
                ? 16.0
                : 14.0,
          ),
          child: const Divider(color: ModernColors.outline, height: 1.0, thickness: 1.0),
        ),

        // Search Bar Section
        Container(
          padding: EdgeInsets.all(
            isDesktop
                ? 18.0
                : isTablet
                ? 16.0
                : 14.0,
          ),
          child: _buildSearchBar(isDesktop, isTablet),
        ),
      ],
    );
  }

  /// Builds the search bar widget
  Widget _buildSearchBar(bool isDesktop, bool isTablet) {
    return Container(
      height: isDesktop
          ? 58.0
          : isTablet
          ? 54.0
          : 50.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: ModernColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 22, offset: const Offset(0, 8)),
          BoxShadow(color: ModernColors.primary.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _filterItems,
        decoration: InputDecoration(
          hintText: "Search Player or Game",
          hintStyle: GoogleFonts.poppins(
            color: ModernColors.onSurfaceVariant,
            fontSize: isDesktop
                ? 15.0
                : isTablet
                ? 14.0
                : 13.0,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [ModernColors.primary, ModernColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: ModernColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: isDesktop
                  ? 22.0
                  : isTablet
                  ? 20.0
                  : 18.0,
            ),
          ),
          filled: true,
          fillColor: ModernColors.surface,
          contentPadding: EdgeInsets.symmetric(
            vertical: isDesktop
                ? 18.0
                : isTablet
                ? 16.0
                : 14.0,
            horizontal: 18.0,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: ModernColors.primary, width: 2.0),
          ),
        ),
        style: GoogleFonts.poppins(
          color: ModernColors.onSurface,
          fontSize: isDesktop
              ? 15.0
              : isTablet
              ? 14.0
              : 13.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Builds search results overlay when search is active
  Widget _buildSearchResultsOverlay(bool isDesktop, bool isTablet, double horizontalMargin) {
    final bool hasGameResults = _filteredItems.isNotEmpty;
    final bool hasUserResults = _filteredUsers.isNotEmpty;

    if (!hasGameResults && !hasUserResults) {
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(left: horizontalMargin, right: horizontalMargin, bottom: 10.0),
          decoration: BoxDecoration(
            color: ModernColors.surface,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: ModernColors.outline, width: 1.5),
          ),
          child: _buildEmptyState(isDesktop),
        ),
      );
    }

    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: horizontalMargin, right: horizontalMargin, bottom: 10.0),
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: ModernColors.outline, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18.0, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8.0, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(
                  isDesktop
                      ? 14.0
                      : isTablet
                      ? 12.0
                      : 10.0,
                ),
                children: [
                  // User Search Results
                  if (hasUserResults) ...[
                    Padding(
                      padding: EdgeInsets.only(top: isDesktop ? 8.0 : 6.0, bottom: isDesktop ? 12.0 : 10.0),
                      child: Row(
                        children: [
                          Text(
                            "Players",
                            style: GoogleFonts.poppins(fontSize: isDesktop ? 16 : 14, fontWeight: FontWeight.w700, color: ModernColors.onSurface),
                          ),
                          SizedBox(width: isDesktop ? 8 : 6),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 6, vertical: isDesktop ? 2 : 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: ModernColors.outline, width: 1.5),
                            ),
                            child: Text(
                              _filteredUsers.length.toString(),
                              style: GoogleFonts.poppins(fontSize: isDesktop ? 12 : 10, fontWeight: FontWeight.w600, color: ModernColors.onSurface),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _clearSearch,
                            child: Container(
                              padding: EdgeInsets.all(isDesktop ? 6 : 5),
                              decoration: BoxDecoration(
                                color: ModernColors.background,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: ModernColors.outline, width: 1.0),
                              ),
                              child: Icon(Icons.close_rounded, size: isDesktop ? 18 : 16, color: ModernColors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._filteredUsers.map(
                      (user) => Padding(
                        padding: EdgeInsets.only(
                          bottom: isDesktop
                              ? 12.0
                              : isTablet
                              ? 10.0
                              : 8.0,
                        ),
                        child: _SearchUserTile(user: user, isDesktop: isDesktop, isTablet: isTablet, onDetailsTap: _showUserStatsDialog),
                      ),
                    ),
                    if (hasGameResults)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: isDesktop ? 16.0 : 14.0),
                        child: const Divider(color: ModernColors.outline, height: 1.0),
                      ),
                  ],

                  // Game Search Results
                  if (hasGameResults) ...[
                    Padding(
                      padding: EdgeInsets.only(top: hasUserResults ? 0 : 8.0, bottom: isDesktop ? 12.0 : 10.0),
                      child: Row(
                        children: [
                          Text(
                            "Games",
                            style: GoogleFonts.poppins(fontSize: isDesktop ? 16 : 14, fontWeight: FontWeight.w700, color: ModernColors.onSurface),
                          ),
                          SizedBox(width: isDesktop ? 8 : 6),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 6, vertical: isDesktop ? 2 : 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: ModernColors.outline, width: 1.5),
                            ),
                            child: Text(
                              _filteredItems.length.toString(),
                              style: GoogleFonts.poppins(fontSize: isDesktop ? 12 : 10, fontWeight: FontWeight.w600, color: ModernColors.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._filteredItems.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(
                          bottom: isDesktop
                              ? 18.0
                              : isTablet
                              ? 16.0
                              : 14.0,
                        ),
                        child: _ModernFullWidthCard(gridItem: item, isDesktop: isDesktop, isTablet: isTablet),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty state widget
  Widget _buildEmptyState(bool isDesktop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: isDesktop ? 60.0 : 52.0, color: ModernColors.onSurfaceVariant),
          const SizedBox(height: 14),
          Text(
            "No results found",
            style: GoogleFonts.quicksand(fontSize: isDesktop ? 20.0 : 18.0, fontWeight: FontWeight.w600, color: ModernColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            "Try searching with different keywords",
            style: GoogleFonts.quicksand(fontSize: isDesktop ? 13.0 : 12.0, fontWeight: FontWeight.w500, color: ModernColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ==================== SEARCH USER TILE ====================

/// Tile widget for displaying user search results
class _SearchUserTile extends StatelessWidget {
  final User user;
  final bool isDesktop;
  final bool isTablet;
  final Function(String userName) onDetailsTap;

  const _SearchUserTile({required this.user, required this.isDesktop, required this.isTablet, required this.onDetailsTap});

  /// Builds avatar with gradient background
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

  /// Extracts initials from username
  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final double tileHeight = isDesktop
        ? 75.0
        : isTablet
        ? 70.0
        : 65.0;
    final double avatarSize = isDesktop
        ? 48.0
        : isTablet
        ? 42.0
        : 38.0;

    return Container(
      height: tileHeight,
      decoration: BoxDecoration(
        color: ModernColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ModernColors.outline, width: 1.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 14 : 12, vertical: isDesktop ? 10 : 8),
      child: Row(
        children: [
          // Avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ModernColors.primary.withOpacity(0.5), width: 1.5),
            ),
            child: ClipOval(
              child: user.profileImagePath != null ? Image.file(File(user.profileImagePath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildAvatar(user.username)) : _buildAvatar(user.username),
            ),
          ),
          SizedBox(width: isDesktop ? 14 : 12),
          // Username
          Expanded(
            child: Text(
              user.username,
              style: GoogleFonts.quicksand(fontSize: isDesktop ? 16 : 14, fontWeight: FontWeight.w700, color: ModernColors.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: isDesktop ? 14 : 12),
          // Details Button
          GestureDetector(
            onTap: () => onDetailsTap(user.username),
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 10 : 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [ModernColors.primary, ModernColors.primaryDark]),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: ModernColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Icon(Icons.info_outline_rounded, color: Colors.white, size: isDesktop ? 18 : 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== MODERN FULL WIDTH CARD ====================

/// Full-width card widget for game navigation
class _ModernFullWidthCard extends StatefulWidget {
  final GridItem gridItem;
  final bool isDesktop;
  final bool isTablet;

  const _ModernFullWidthCard({required this.gridItem, required this.isDesktop, required this.isTablet});

  @override
  State<_ModernFullWidthCard> createState() => _ModernFullWidthCardState();
}

class _ModernFullWidthCardState extends State<_ModernFullWidthCard> {
  bool _isHovering = false;
  bool _isPressed = false;

  /// Determines destination screen based on grid item label
  Widget _getDestinationScreen(String label, Color color, IconData iconData) {
    switch (label) {
      case "Marriage":
        return MarriageScreen(tag: label, color: color, iconData: iconData);
      case "Call Break":
        return CallBreakScreen(tag: label, color: color, iconData: iconData);
      case "History":
        return GameHistoryScreen(tag: label, color: color, iconData: iconData);
      case "Users":
        return UsersScreen(tag: label, color: color, iconData: iconData);
      case "Manual":
        return RulesScreen(tag: label, color: color, iconData: iconData);
      default:
        return Scaffold(
          body: Center(
            child: Text("Error: Screen not found for $label", style: GoogleFonts.quicksand(color: Colors.red)),
          ),
        );
    }
  }

  /// Handles card tap with animation
  void _handleTap(BuildContext context) {
    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() => _isPressed = false);
      final destinationScreen = _getDestinationScreen(widget.gridItem.label, widget.gridItem.color, widget.gridItem.icon);
      Get.to(() => destinationScreen, transition: Transition.cupertino, duration: const Duration(milliseconds: 500));
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.isDesktop
        ? 90.0
        : widget.isTablet
        ? 85.0
        : 80.0;
    final iconSize = widget.isDesktop
        ? 26.0
        : widget.isTablet
        ? 24.0
        : 22.0;
    final containerSize = widget.isDesktop
        ? 55.0
        : widget.isTablet
        ? 50.0
        : 45.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => _handleTap(context),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : (_isHovering ? 1.01 : 1.0)),
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [widget.gridItem.gradientStart, widget.gridItem.gradientEnd]),
            boxShadow: [
              BoxShadow(color: widget.gridItem.color.withOpacity(0.5), blurRadius: _isHovering ? 25 : 18, spreadRadius: _isHovering ? 2 : 0, offset: Offset(0, _isHovering ? 12 : 8)),
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned(
                right: -14,
                top: -14,
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(
                  widget.isDesktop
                      ? 18.0
                      : widget.isTablet
                      ? 16.0
                      : 14.0,
                ),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      width: containerSize,
                      height: containerSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.2)], stops: const [0.0, 0.7, 1.0]),
                        boxShadow: [
                          BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 14, offset: const Offset(-4, -4)),
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(4, 4)),
                        ],
                      ),
                      child: Center(
                        child: Hero(
                          tag: widget.gridItem.label,
                          child: Icon(widget.gridItem.icon, size: iconSize, color: widget.gridItem.color),
                        ),
                      ),
                    ),

                    SizedBox(width: widget.isDesktop ? 14.0 : 12.0),
                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.gridItem.label,
                            style: GoogleFonts.quicksand(
                              fontSize: widget.isDesktop
                                  ? 17.0
                                  : widget.isTablet
                                  ? 16.0
                                  : 15.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.gridItem.shortDescription,
                            style: GoogleFonts.quicksand(
                              fontSize: widget.isDesktop
                                  ? 12.0
                                  : widget.isTablet
                                  ? 11.0
                                  : 10.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(_isHovering ? 0.3 : 0.2), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: widget.isDesktop ? 16.0 : 14.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
