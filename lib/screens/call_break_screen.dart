import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../controllers/call_break_controller.dart';
import '../widgets/call_break/action_buttons.dart';
import '../widgets/call_break/player_card.dart';
import '../widgets/call_break/round_history.dart';
import '../widgets/moder_app_bar.dart';
import '../widgets/player_selection_dialog.dart';

/// Screen for playing Call Break card game
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

  /// Shows player selection dialog for choosing game participants
  void _showPlayerSelectionDialog() {
    Get.dialog(PlayerSelectionDialog(numberOfPlayers: 4, alreadySelectedPlayers: controller.selectedPlayers.map((user) => user.username).toList()), barrierDismissible: false).then((selectedPlayers) {
      if (selectedPlayers != null && selectedPlayers is List) {
        controller.setPlayers(selectedPlayers.cast());
      }
    });
  }

  /// Builds floating action button for adding players
  Widget _buildFloatingActionButton() {
    return Obx(() {
      if (controller.selectedPlayers.isEmpty) {
        return FloatingActionButton(
          onPressed: _showPlayerSelectionDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [
                BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.5), blurRadius: 20, spreadRadius: 3, offset: const Offset(0, 8)),
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            ),
            child: const Icon(Icons.supervisor_account_rounded, color: Colors.white, size: 28),
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

    return Scaffold(
      appBar: ModernAppBar(title: "Call Break"),
      backgroundColor: const Color(0xFFF8FAFF),
      floatingActionButton: _buildFloatingActionButton(),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Display game sections only when players are selected
                    if (controller.selectedPlayers.isNotEmpty) ...[_buildPlayersHeader(), const SizedBox(height: 5), RoundHistory(tag: widget.tag), const SizedBox(height: 5), _buildPlayersContainer(), const SizedBox(height: 5)],

                    // Show empty state when no players are selected
                    if (controller.selectedPlayers.isEmpty) ...[_buildEmptyState()],
                  ],
                ),
              );
            }),
          ),

          // Bottom action buttons (only show when players are selected)
          Obx(() => controller.selectedPlayers.isNotEmpty ? ActionButtons(tag: widget.tag) : const SizedBox()),
        ],
      ),
    );
  }

  /// Builds players header section with round progress indicator
  Widget _buildPlayersHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          // Game icon container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),

          // Round progress indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Round Progress",
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                ),
                const SizedBox(height: 2),
                Obx(() {
                  final currentRound = controller.currentRound.value;
                  final progress = currentRound / 5.0; // Assuming 5 rounds total

                  return Container(
                    height: 6,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(3)),
                    child: Stack(
                      children: [
                        // Background
                        Container(
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(3)),
                        ),
                        // Progress bar
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

          // Round indicator
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
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds container for player cards
  Widget _buildPlayersContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
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

  /// Builds empty state when no players are selected
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 200),
          SizedBox(width: 200, height: 200, child: Lottie.asset('assets/lottie/intro3.json', fit: BoxFit.contain)),
          Text(
            "Tap + icon to add players",
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<CallBreakController>(tag: widget.tag);
    super.dispose();
  }
}
