import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/user_stats_controller.dart';
import '../model/user_model.dart';

class UserStatsDialog extends StatelessWidget {
  final String userName;

  const UserStatsDialog({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 350;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: GetBuilder<UserStatsController>(
        init: UserStatsController(userName),
        global: false,
        builder: (controller) {
          return Obx(() {
            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 15, left: 8, right: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 25, spreadRadius: 3, offset: const Offset(0, 8)),
                      BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: Colors.grey.shade100, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with reduced font size and better color
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Profile Avatar with left margin
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                width: isSmallScreen ? 36 : 40,
                                height: isSmallScreen ? 36 : 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.blueAccent.withOpacity(0.8), width: 2),
                                  boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))],
                                ),
                                child: _buildProfileAvatar(userName),
                              ),
                              const SizedBox(width: 12),
                              // Name with reduced font size and better color
                              Text(
                                userName,
                                style: GoogleFonts.quicksand(
                                  fontSize: isSmallScreen ? 13 : 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blue.shade800, // Better color
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          // Close Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Get.back(),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: isSmallScreen ? 32 : 36,
                                  height: isSmallScreen ? 32 : 36,
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(Icons.close_rounded, size: isSmallScreen ? 16 : 18, color: Colors.grey.shade600),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Date Picker Section
                      _buildDatePickerSection(context, controller, isSmallScreen),

                      const SizedBox(height: 16),

                      // Content Area
                      controller.isLoading.value ? _buildModernLoading(isSmallScreen) : _buildContent(controller, isSmallScreen),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildProfileAvatar(String playerName) {
    try {
      final userBox = Hive.box<User>('usersBox');
      final user = userBox.values.firstWhere((user) => user.username == playerName, orElse: () => User(username: playerName));

      if (user.profileImagePath != null && user.profileImagePath!.isNotEmpty) {
        return ClipOval(
          child: Image.file(
            File(user.profileImagePath!),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackAvatar(playerName);
            },
          ),
        );
      } else {
        return _buildFallbackAvatar(playerName);
      }
    } catch (e) {
      return _buildFallbackAvatar(playerName);
    }
  }

  Widget _buildFallbackAvatar(String playerName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        child: Text(
          _getInitials(playerName),
          style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  Widget _buildDatePickerSection(BuildContext context, UserStatsController controller, bool isSmallScreen) {
    final dateRange = controller.selectedDateRange.value;
    final isToday = controller.isToday.value;

    String topText;
    String bottomText;

    if (isToday) {
      topText = 'Today';
      bottomText = DateFormat('MMM dd, yyyy').format(DateTime.now());
    } else if (dateRange == null) {
      topText = 'Today';
      bottomText = DateFormat('MMM dd, yyyy').format(DateTime.now());
    } else {
      topText = 'From: ${DateFormat('MMM dd').format(dateRange['start']!)}';
      bottomText = 'To: ${DateFormat('MMM dd, yyyy').format(dateRange['end']!)}';
    }

    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Date Icon in Rectangle - Deep blue gradient
          Container(
            width: isSmallScreen ? 40 : 44,
            height: isSmallScreen ? 40 : 44,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.blue.shade800.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Icon(Icons.calendar_month_rounded, size: isSmallScreen ? 18 : 20, color: Colors.white),
          ),

          // Date Text Section
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey.shade200, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topText,
                    style: GoogleFonts.poppins(fontSize: isSmallScreen ? 10 : 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bottomText,
                    style: GoogleFonts.poppins(fontSize: isSmallScreen ? 11 : 12, fontWeight: FontWeight.w700, color: Colors.blue.shade900),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: Colors.blue.shade800.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.clearDateRange(),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: isSmallScreen ? 28 : 32,
                      height: isSmallScreen ? 28 : 32,
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.restart_alt_rounded, size: isSmallScreen ? 14 : 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: Colors.blue.shade800.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showPremiumDatePicker(context, controller, isSmallScreen),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: isSmallScreen ? 28 : 32,
                      height: isSmallScreen ? 28 : 32,
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.date_range_rounded, size: isSmallScreen ? 14 : 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(UserStatsController controller, bool isSmallScreen) {
    final marriageStats = controller.marriageStats.value;
    final callbreakStats = controller.callbreakStats.value;

    return Column(
      children: [
        // Marriage Performance Section
        _buildMarriageSection(marriageStats, isSmallScreen),

        const SizedBox(height: 12),

        // Callbreak Performance Section
        _buildCallbreakSection(callbreakStats, isSmallScreen),
      ],
    );
  }

  Widget _buildMarriageSection(MarriageStats? stats, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.pinkAccent.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
          BoxShadow(color: Colors.pinkAccent.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: isSmallScreen ? 28 : 32,
                height: isSmallScreen ? 28 : 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade900.withOpacity(0.6), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.blue.shade900.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Icon(Icons.favorite_rounded, size: isSmallScreen ? 14 : 16, color: Colors.blue.shade900),
              ),
              const SizedBox(width: 8),
              Text(
                'Marriage',
                style: GoogleFonts.quicksand(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.w800, color: Colors.blue.shade900),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats Cards - Ultra thin outlines
          if (stats == null || stats.totalMatches == 0)
            _buildNoDataWidget('No marriage games found', isSmallScreen) // Now uses the same centered widget
          else
            Column(
              children: [
                // First Row - 3 cards without icons
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCardNoIcon(value: stats.totalMatches.toString(), label: 'Matches', gradientColors: [Colors.blue.shade400, Colors.purple.shade400], isSmallScreen: isSmallScreen),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildStatCardNoIcon(value: stats.wins.toString(), label: 'Wins', gradientColors: [Colors.green.shade400, Colors.teal.shade400], isSmallScreen: isSmallScreen),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildStatCardNoIcon(value: '${stats.winRate.toStringAsFixed(1)}%', label: 'Win Rate', gradientColors: [Colors.orange.shade400, Colors.red.shade400], isSmallScreen: isSmallScreen),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Second Row - 2 cards with icons
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCardWithIcon(icon: Icons.attach_money_rounded, value: stats.totalAmountEarned.toStringAsFixed(0), label: 'Amount', gradientColors: [Colors.purple.shade400, Colors.pink.shade400], isSmallScreen: isSmallScreen),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildStatCardWithIcon(icon: Icons.star_rounded, value: stats.totalMarriagePoints.toStringAsFixed(0), label: 'Points', gradientColors: [Colors.red.shade400, Colors.orange.shade400], isSmallScreen: isSmallScreen),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCallbreakSection(CallbreakStats? stats, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
          BoxShadow(color: Colors.blueAccent.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: isSmallScreen ? 28 : 32,
                height: isSmallScreen ? 28 : 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade900.withOpacity(0.6), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.blue.shade900.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Icon(Icons.control_camera_rounded, size: isSmallScreen ? 14 : 16, color: Colors.blue.shade900),
              ),
              const SizedBox(width: 8),
              Text(
                'Callbreak',
                style: GoogleFonts.quicksand(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.w800, color: Colors.blue.shade900),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (stats == null)
            _buildNoDataWidget('No callbreak games found', isSmallScreen)
          else if (stats.totalMatches == 0)
            _buildNoDataWidget('No callbreak games found', isSmallScreen)
          else
            Column(
              children: [
                // Position Ranking Header
                Text(
                  'POSITION RANKING',
                  style: GoogleFonts.poppins(fontSize: isSmallScreen ? 10 : 12, fontWeight: FontWeight.w700, color: Colors.blue.shade800, letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),

                // Medal-like UI for position ranking
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      _buildMedalCard(position: '1st', count: stats.firstPlace.toString(), medalColor: Colors.orange.shade700, isSmallScreen: isSmallScreen),
                      const SizedBox(width: 6),
                      _buildMedalCard(position: '2nd', count: stats.secondPlace.toString(), medalColor: Colors.grey.shade500, isSmallScreen: isSmallScreen),
                      const SizedBox(width: 6),
                      _buildMedalCard(position: '3rd', count: stats.thirdPlace.toString(), medalColor: Colors.brown.shade600, isSmallScreen: isSmallScreen),
                      const SizedBox(width: 6),
                      _buildMedalCard(position: '4th', count: stats.fourthPlace.toString(), medalColor: Colors.blue.shade700, isSmallScreen: isSmallScreen),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Performance Summary
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCardWithIcon(icon: Icons.sports_esports_rounded, value: stats.totalMatches.toString(), label: 'Matches', gradientColors: [Colors.blue.shade400, Colors.purple.shade400], isSmallScreen: isSmallScreen),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildStatCardWithIcon(icon: Icons.trending_up_rounded, value: '${((stats.firstPlace / (stats.totalMatches == 0 ? 1 : stats.totalMatches)) * 100).toStringAsFixed(1)}%', label: 'Top Rate', gradientColors: [Colors.green.shade400, Colors.teal.shade400], isSmallScreen: isSmallScreen),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCardNoIcon({required String value, required String label, required List<Color> gradientColors, required bool isSmallScreen}) {
    return Container(
      padding: const EdgeInsets.all(1.0), // Ultra thin outline
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.2), // Reduced opacity
            blurRadius: 4, // Reduced blur
            spreadRadius: 0.3, // Reduced spread
            offset: const Offset(0, 1), // Reduced offset
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 10, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.quicksand(fontSize: isSmallScreen ? 10 : 12, fontWeight: FontWeight.w800, color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardWithIcon({required IconData icon, required String value, required String label, required List<Color> gradientColors, required bool isSmallScreen}) {
    return Container(
      padding: const EdgeInsets.all(1.0), // Ultra thin outline
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: gradientColors.first.withOpacity(0.2), blurRadius: 4, spreadRadius: 0.3, offset: const Offset(0, 1))],
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon in gradient container
            Container(
              width: isSmallScreen ? 20 : 24,
              height: isSmallScreen ? 20 : 24,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: isSmallScreen ? 10 : 12, color: Colors.white),
            ),
            const SizedBox(width: 6),
            // Text and Value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 10, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    value,
                    style: GoogleFonts.quicksand(fontSize: isSmallScreen ? 10 : 12, fontWeight: FontWeight.w800, color: Colors.grey.shade800),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedalCard({required String position, required String count, required Color medalColor, required bool isSmallScreen}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: medalColor.withOpacity(0.4), width: 2),
          boxShadow: [BoxShadow(color: medalColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon
            Container(
              width: isSmallScreen ? 20 : 24,
              height: isSmallScreen ? 20 : 24,
              decoration: BoxDecoration(
                color: medalColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: medalColor.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Center(
                child: Icon(Icons.emoji_events_rounded, size: isSmallScreen ? 10 : 12, color: Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            // Position text
            Text(
              position,
              style: GoogleFonts.poppins(fontSize: isSmallScreen ? 8 : 10, fontWeight: FontWeight.w700, color: medalColor),
            ),
            const SizedBox(height: 2),
            // Count
            Text(
              count,
              style: GoogleFonts.quicksand(fontSize: isSmallScreen ? 10 : 12, fontWeight: FontWeight.w800, color: medalColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget(String message, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20), // Equal padding from all sides
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernLoading(bool isSmallScreen) {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isSmallScreen ? 36 : 42,
              height: isSmallScreen ? 36 : 42,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
                boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Colors.blue.shade700)),
            ),
            const SizedBox(height: 12),
            Text(
              'Analyzing Performance',
              style: GoogleFonts.poppins(color: Colors.blue.shade800, fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDatePicker(BuildContext context, UserStatsController controller, bool isSmallScreen) {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year + 1);

    DateTime? tempRangeStart;
    DateTime? tempRangeEnd;
    bool showConfirmButton = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 30, spreadRadius: 2, offset: const Offset(0, 10)),
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Calendar with elevated border
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: TableCalendar(
                      firstDay: firstDate,
                      lastDay: lastDate,
                      focusedDay: now,
                      rangeStartDay: tempRangeStart,
                      rangeEndDay: tempRangeEnd,
                      calendarFormat: CalendarFormat.month,
                      rangeSelectionMode: RangeSelectionMode.toggledOn,
                      availableGestures: AvailableGestures.all,
                      selectedDayPredicate: (day) => false,
                      onDaySelected: (selectedDay, focusedDay) {
                        // Disable future dates
                        if (selectedDay.isAfter(DateTime.now())) {
                          return;
                        }

                        if (tempRangeStart == null) {
                          setState(() {
                            tempRangeStart = selectedDay;
                            showConfirmButton = false;
                          });
                        } else if (tempRangeEnd == null) {
                          setState(() {
                            tempRangeEnd = selectedDay;
                            showConfirmButton = true;
                          });
                        } else {
                          setState(() {
                            tempRangeStart = selectedDay;
                            tempRangeEnd = null;
                            showConfirmButton = false;
                          });
                        }
                      },
                      onRangeSelected: (start, end, focusedDay) {
                        // Not used since we're handling selection manually
                      },
                      enabledDayPredicate: (day) {
                        // Disable future dates
                        return !day.isAfter(DateTime.now());
                      },
                      calendarStyle: CalendarStyle(
                        // Disabled date styling
                        disabledTextStyle: TextStyle(color: Colors.grey.shade400),

                        // Today's date styling
                        todayDecoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.red.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),

                        // Selected range styling
                        selectedDecoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          shape: BoxShape.circle,
                        ),
                        rangeStartDecoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          shape: BoxShape.circle,
                        ),
                        rangeEndDecoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          shape: BoxShape.circle,
                        ),

                        // Within range styling
                        withinRangeDecoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),

                        // Outside range styling
                        outsideDecoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), shape: BoxShape.circle),
                        outsideTextStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),

                        // Default styling
                        defaultTextStyle: GoogleFonts.poppins(color: Colors.blue.shade900, fontWeight: FontWeight.w500),
                        weekendTextStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),

                        // Range highlight indication
                        rangeHighlightColor: Colors.blueAccent.withOpacity(0.1),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: GoogleFonts.quicksand(color: Colors.blue.shade900, fontWeight: FontWeight.w800, fontSize: 16),
                        leftChevronIcon: Icon(Icons.chevron_left_rounded, color: Colors.blue.shade700, size: 24),
                        rightChevronIcon: Icon(Icons.chevron_right_rounded, color: Colors.blue.shade700, size: 24),
                        headerPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.poppins(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                        weekendStyle: GoogleFonts.poppins(color: Colors.purple.shade700, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  // Buttons
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(colors: [Colors.purple.shade300, Colors.purple.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 12, // Further reduced size
                                      height: 12, // Further reduced size
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                      child: Icon(Icons.cancel, size: 10, color: Colors.purple.shade700), // Further reduced icon size
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Cancel',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: isSmallScreen ? 12 : 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: showConfirmButton ? LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight) : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: showConfirmButton ? [BoxShadow(color: Colors.blue.shade800.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: showConfirmButton && tempRangeStart != null && tempRangeEnd != null
                                    ? () {
                                        final endDate = DateTime(tempRangeEnd!.year, tempRangeEnd!.month, tempRangeEnd!.day, 23, 59, 59);
                                        controller.setDateRange(tempRangeStart!, endDate);
                                        Navigator.pop(context);
                                      }
                                    : null,
                                borderRadius: BorderRadius.circular(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Confirm',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: isSmallScreen ? 12 : 13),
                                    ),
                                  ],
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
      ),
    );
  }
}
