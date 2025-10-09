import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/user_stats_controller.dart';
// NOTE: Ensure your models (MarriageStats, CallbreakStats) are imported or available in scope

class UserStatsDialog extends StatelessWidget {
  final String userName;

  const UserStatsDialog({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: GetBuilder<UserStatsController>(
        init: UserStatsController(userName),
        global: false,
        builder: (controller) {
          // 🛑 FIX: Wrap the entire content with Obx so it rebuilds on
          // controller.isLoading.value and controller.isToday.value changes.
          return Obx(() {
            return Container(
              width: double.maxFinite,
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 32, offset: const Offset(0, 16))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildHeader(context, controller),

                  // Date Range Picker
                  _buildDateRangePicker(context, controller),

                  // Content
                  Expanded(child: controller.isLoading.value ? _buildLoadingIndicator() : _buildContent(controller)),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserStatsController controller) {
    // Note: The Obx is now around the entire dialog content, so you don't need it here.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0066FF), Color(0xFF00B8FF)]),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Avatar and Name
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0066FF)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    // Removed Obx as the parent is already Obx
                    Text(controller.isToday.value ? "Today's Performance" : 'Filtered Statistics', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context, UserStatsController controller) {
    // Note: The Obx is now around the entire dialog content, so you don't need it here.
    final dateRange = controller.selectedDateRange.value;
    final isToday = controller.isToday.value;

    String dateText;
    if (isToday) {
      dateText = 'Today • ${DateFormat('MMM dd, yyyy').format(DateTime.now())}';
    } else if (dateRange == null) {
      // This case should ideally not be hit if logic is correct, but handles fallback.
      dateText = 'Today • ${DateFormat('MMM dd, yyyy').format(DateTime.now())}';
    } else {
      dateText = '${DateFormat('MMM dd, yyyy').format(dateRange['start']!)} - ${DateFormat('MMM dd, yyyy').format(dateRange['end']!)}';
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            // Today badge when showing today's data
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF00D26A), borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  'TODAY',
                  style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            else
              Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),

            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateText,
                style: TextStyle(fontSize: 15, color: Colors.grey[800], fontWeight: FontWeight.w500),
              ),
            ),
            if (!isToday)
              IconButton(
                icon: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                onPressed: () => controller.clearDateRange(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF0066FF), borderRadius: BorderRadius.circular(12)),
              child: IconButton(
                icon: const Icon(Icons.date_range, size: 18, color: Colors.white),
                onPressed: () => _selectDateRange(context, controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(UserStatsController controller) {
    // Retrieve latest stats values from the reactive variables
    final marriageStats = controller.marriageStats.value;
    final callbreakStats = controller.callbreakStats.value;
    final isToday = controller.isToday.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Marriage Statistics
          _buildMarriageSection(marriageStats, isToday),

          const SizedBox(height: 20),

          // Callbreak Statistics
          _buildCallbreakSection(callbreakStats, isToday),

          const SizedBox(height: 20),

          // Info text when showing today's data
          if (isToday) _buildInfoText(),
        ],
      ),
    );
  }

  Widget _buildMarriageSection(MarriageStats? stats, bool isToday) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.grey[100]!, blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFFFE5E5), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.favorite, color: Color(0xFFFF4757), size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Marriage Points',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (stats == null || stats.totalMatches == 0) _buildNoDataWidget(isToday ? 'No marriage games today' : 'No marriage games in selected period') else _buildMarriageStats(stats),
        ],
      ),
    );
  }

  Widget _buildMarriageStats(stats) {
    // Changed type to dynamic/Stats if you have trouble importing the model
    return Column(
      children: [
        // Top Row - Total Matches & Wins
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Matches', stats.totalMatches.toString(), Icons.games_outlined, const Color(0xFF0066FF), 'Games Played')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Total Wins', stats.wins.toString(), Icons.emoji_events_outlined, const Color(0xFF00D26A), 'Victories')),
          ],
        ),
        const SizedBox(height: 12),

        // Middle Row - Win Rate & Amount
        Row(
          children: [
            Expanded(child: _buildStatCard('Win Rate', '${stats.winRate.toStringAsFixed(1)}%', Icons.trending_up_outlined, const Color(0xFFFF6B00), 'Success Rate')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Amount Earned', '₹${stats.totalAmountEarned.toStringAsFixed(0)}', Icons.currency_rupee_outlined, const Color(0xFF9C27B0), 'Total Earnings')),
          ],
        ),
        const SizedBox(height: 12),

        // Bottom - Marriage Points
        _buildStatCard('Marriage Points', stats.totalMarriagePoints.toStringAsFixed(0), Icons.star_outline, const Color(0xFFFFC107), 'Total Points', fullWidth: true),
      ],
    );
  }

  Widget _buildCallbreakSection(stats, bool isToday) {
    // Changed type to dynamic/Stats
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.grey[100]!, blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFE5F3FF), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.emoji_events_outlined, color: Color(0xFF0066FF), size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Callbreak',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (stats == null || stats.totalMatches == 0) _buildNoDataWidget(isToday ? 'No callbreak games today' : 'No callbreak games in selected period') else _buildCallbreakStats(stats),
        ],
      ),
    );
  }

  Widget _buildCallbreakStats(stats) {
    // Changed type to dynamic/Stats
    return Column(
      children: [
        // Total Matches
        _buildStatCard('Total Matches', stats.totalMatches.toString(), Icons.games_outlined, const Color(0xFF0066FF), 'Games Played', fullWidth: true),
        const SizedBox(height: 16),

        // Positions
        Text(
          'Positions Achieved',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildPositionCard(
                '1st',
                stats.firstPlace.toString(),
                const Color(0xFFFFD700), // Gold
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPositionCard(
                '2nd',
                stats.secondPlace.toString(),
                const Color(0xFFC0C0C0), // Silver
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPositionCard(
                '3rd',
                stats.thirdPlace.toString(),
                const Color(0xFFCD7F32), // Bronze
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPositionCard(
                '4th',
                stats.fourthPlace.toString(),
                const Color(0xFF6B7280), // Gray
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPositionCard(String position, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            position,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          const Text('Times', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[600], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Showing today\'s matches. Use date picker to view other periods.', style: TextStyle(color: Colors.blue[800], fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF0066FF)))),
    );
  }

  Future<void> _selectDateRange(BuildContext context, UserStatsController controller) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'Apply',
      helpText: 'Select Date Range',
      confirmText: 'Apply',
      cancelText: 'Cancel',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0066FF), onPrimary: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Ensure the end date includes the entire day
      final endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      controller.setDateRange(picked.start, endDate);
    }
  }
}
