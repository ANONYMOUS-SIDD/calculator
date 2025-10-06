import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/call_break_controller.dart';
import '../screens/user_app_bar.dart';
import '../widgets/call_break/action_buttons.dart';
import '../widgets/call_break/player_card.dart';
import '../widgets/call_break/round_history.dart';
import '../widgets/player_selection_dialog.dart';

class CallBreakScreen extends StatefulWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  const CallBreakScreen({super.key, required this.tag, required this.color, required this.iconData});

  @override
  State<CallBreakScreen> createState() => _CallBreakScreenState();
}

class _CallBreakScreenState extends State<CallBreakScreen> {
  late final CallBreakController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CallBreakController(widget.tag), tag: widget.tag);
  }

  void _showPlayerSelectionDialog() {
    Get.dialog(PlayerSelectionDialog(numberOfPlayers: 4, alreadySelectedPlayers: controller.selectedPlayers.map((user) => user.username).toList()), barrierDismissible: false).then((selectedPlayers) {
      if (selectedPlayers != null && selectedPlayers is List) {
        controller.setPlayers(selectedPlayers.cast());
      }
    });
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      if (controller.selectedPlayers.isEmpty) {
        return FloatingActionButton(
          onPressed: _showPlayerSelectionDialog,
          backgroundColor: Colors.blueAccent,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0066FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.group_add, color: Colors.white, size: 28),
          ),
        );
      }
      return const SizedBox();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 400 ? 12.0 : 16.0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        floatingActionButton: _buildFloatingActionButton(),
        body: Column(
          children: [
            const UserAppBar(title: "Call Break"),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      // Top Players Section
                      if (controller.selectedPlayers.isNotEmpty) ...[_buildPlayersHeader(), _buildPlayersContainer(), RoundHistory(tag: widget.tag)],

                      // Empty State
                      if (controller.selectedPlayers.isEmpty) ...[_buildEmptyState()],

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }),
            ),

            // Bottom Action Buttons
            Obx(() => controller.selectedPlayers.isNotEmpty ? ActionButtons(tag: widget.tag) : const SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Reduced padding
      child: Row(
        children: [
          // Game Icon - Compact
          Container(
            width: 36, // Smaller
            height: 36, // Smaller
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: const Icon(
              Icons.sports_esports_rounded,
              color: Colors.white,
              size: 18, // Smaller
            ),
          ),
          const SizedBox(width: 8),

          // Round Progress Indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Round Progress",
                  style: GoogleFonts.poppins(
                    fontSize: 10, // Smaller
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() {
                  final currentRound = controller.currentRound.value;
                  final progress = currentRound / 5.0; // Assuming 5 rounds total

                  return Container(
                    height: 6, // Thin progress bar
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(3)),
                    child: Stack(
                      children: [
                        // Background
                        Container(
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(3)),
                        ),
                        // Progress
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: MediaQuery.of(Get.context!).size.width * 0.6 * progress,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent], begin: Alignment.centerLeft, end: Alignment.centerRight),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Round Indicator - Compact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(colors: [Colors.cyan.shade400, Colors.cyan.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => Text(
                    'R${controller.currentRound.value}',
                    style: GoogleFonts.poppins(
                      fontSize: 10, // Smaller
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  Widget _buildPlayersContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8), // Reduced horizontal margin
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [...controller.selectedPlayers.asMap().entries.map((entry) => PlayerCard(index: entry.key, player: entry.value, tag: widget.tag))],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
          ),
          child: Icon(Icons.people_outline, size: 60, color: Colors.blueAccent.withOpacity(0.6)),
        ),
        const SizedBox(height: 24),
        Text(
          "No Players Selected",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Text(
          "Tap the + button to select 4 players",
          style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  void dispose() {
    Get.delete<CallBreakController>(tag: widget.tag);
    super.dispose();
  }
}
