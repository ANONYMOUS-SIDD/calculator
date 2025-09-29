import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get for controller access and Obx
import 'package:google_fonts/google_fonts.dart';

import '../controllers/player_controller.dart'; // Import the controller

class ResultsTable extends StatelessWidget {
  // We no longer need to pass players and pointsPerRupee as they are accessed via the controller
  const ResultsTable({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the controller instance
    final PlayerController controller = Get.find<PlayerController>();

    // 2. Use Obx to listen to the reactive calculatedResults and pointsPerRupee
    return Obx(() {
      final List<CalculatedResult> netResults = controller.calculatedResults;
      final double pointsPerRupee = controller.pointsPerRupee.value;

      // Check if results are empty and return nothing if so (SizedBox.shrink() makes it disappear completely)
      if (netResults.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, const Color(0xFFF0F5FF).withOpacity(0.5)]),
          boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
          border: Border.all(color: const Color(0xFFE8F0FF), width: 1),
        ),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0099FF)]),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.leaderboard, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Game Results',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '₹${pointsPerRupee.toStringAsFixed(2)}/pt',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Table Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: netResults.asMap().entries.map((entry) {
                  // netResults now contains CalculatedResult objects directly from the controller
                  final result = entry.value;
                  final player = result.player;

                  // --- Calculations using Net Points from Controller ---
                  final netPointChange = result.netPoints;
                  final totalAmount = netPointChange * pointsPerRupee;
                  final isWinner = netPointChange > 0;
                  final isLoser = netPointChange < 0;
                  // ---------------------------------------------

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8F0FF)),
                      boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
                    ),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: (isWinner ? const Color(0xFF00C6FF) : const Color(0xFF0066FF)).withOpacity(0.3), width: 2),
                            ),
                            child: ClipOval(
                              // Using a placeholder icon since File I/O might not work in all environments
                              child: player.userImage != null && (player.userImage!.isNotEmpty) ? Icon(Icons.verified_user, size: 20, color: const Color(0xFF0066FF).withOpacity(0.6)) : Icon(Icons.person, size: 20, color: const Color(0xFF0066FF).withOpacity(0.6)),
                            ),
                          ),
                          if (isWinner)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFD700)),
                                child: const Icon(Icons.star, size: 10, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      title: Text(player.userName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),

                      // Displaying Raw Points and Net Points
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Using pointsEarned from the player object (the raw score)
                          Text('Raw Pts: ${player.pointsEarned.toStringAsFixed(1)}${player.isDoublee ? ' (2x)' : ''}', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF5A6C8A))),
                          Text(
                            'Net Pts: ${netPointChange.toStringAsFixed(1)}', // The calculated win/loss points
                            style: GoogleFonts.poppins(fontSize: 11, color: isWinner ? const Color(0xFF10B981) : (isLoser ? const Color(0xFFFF6B6B) : const Color(0xFF5A6C8A)), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),

                      // Displaying Total Amount Win/Lose
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹ ${totalAmount.abs().toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: isWinner ? const Color(0xFF00C6FF) : (isLoser ? const Color(0xFFFF6B6B) : const Color(0xFF5A6C8A))),
                          ),
                          Text(
                            isWinner ? 'WON' : (isLoser ? 'LOST' : 'TIED'),
                            style: GoogleFonts.poppins(fontSize: 10, color: isWinner ? const Color(0xFF00C6FF) : (isLoser ? const Color(0xFFFF6B6B) : const Color(0xFF5A6C8A)), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }
}
