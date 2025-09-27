// widgets/results_table.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/marriage_game.dart';

class ResultsTable extends StatelessWidget {
  final List<MarriagePlayer> players;
  final double pointsPerRupee;

  const ResultsTable({super.key, required this.players, required this.pointsPerRupee});

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<MarriagePlayer>.from(players)..sort((a, b) => (b.maalPoints * (b.isDoublee ? 2 : 1)).compareTo(a.maalPoints * (a.isDoublee ? 2 : 1)));

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
                    '₹$pointsPerRupee/pt',
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
              children: sortedPlayers.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;
                final amount = player.maalPoints * pointsPerRupee * (player.isDoublee ? 2 : 1);
                final isWinner = amount >= 0;

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
                            border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.3), width: 2),
                          ),
                          child: ClipOval(
                            child: player.userImage != null ? Image.file(File(player.userImage!), fit: BoxFit.cover) : Icon(Icons.person, size: 20, color: const Color(0xFF0066FF).withOpacity(0.6)),
                          ),
                        ),
                        if (index == 0)
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
                    subtitle: Text(
                      'Points: ${player.maalPoints.toStringAsFixed(1)}'
                      '${player.isDoublee ? ' (2x)' : ''}',
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF5A6C8A)),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'रु ${amount.abs().toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: isWinner ? const Color(0xFF00C6FF) : const Color(0xFFFF6B6B)),
                        ),
                        Text(
                          isWinner ? 'WON' : 'LOST',
                          style: GoogleFonts.poppins(fontSize: 10, color: isWinner ? const Color(0xFF00C6FF) : const Color(0xFFFF6B6B), fontWeight: FontWeight.w600),
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
  }
}
