// widgets/player_cards_grid.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/marriage_game.dart';

class PlayerCardsGrid extends StatefulWidget {
  final List<MarriagePlayer> players;
  final Function(int, double) onPointsChanged;
  final Function(int) onDoubleeToggle;

  const PlayerCardsGrid({
    super.key,
    required this.players,
    required this.onPointsChanged,
    required this.onDoubleeToggle,
  });

  @override
  State<PlayerCardsGrid> createState() => _PlayerCardsGridState();
}

class _PlayerCardsGridState extends State<PlayerCardsGrid> {
  final List<Map<String, dynamic>> _playerStates = [];

  @override
  void initState() {
    super.initState();
    _initializePlayerStates();
  }

  @override
  void didUpdateWidget(PlayerCardsGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.players.length != widget.players.length) {
      _initializePlayerStates();
    }
  }

  void _initializePlayerStates() {
    _playerStates.clear();
    for (int i = 0; i < widget.players.length; i++) {
      _playerStates.add({
        'status': 'Unseen', // Unseen, Seen, Win
        'points': 0.0,
      });
    }
  }

  void _showDoubleeDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.looks_two, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'Doublee Mode',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF1A1D2B),
              ),
            ),
          ],
        ),
        content: Text(
          'Switch ${widget.players[index].userName} to Doublee mode? Points will be counted double.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: const Color(0xFF5A6C8A),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.poppins(
                color: const Color(0xFF5A6C8A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () {
                widget.onDoubleeToggle(index);
                Navigator.pop(context);
              },
              child: Text(
                'SWITCH TO DOUBLEE',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(int playerCount) {
    if (playerCount == 3) return 3;
    if (playerCount <= 4) return 2;
    if (playerCount <= 6) return 3;
    return 2;
  }

  double _getChildAspectRatio(int playerCount) {
    if (playerCount == 3) return 0.9;
    if (playerCount <= 4) return 0.85;
    return 0.8;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.players.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  'Players',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D2B),
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.players.length} Players',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF5A6C8A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Players Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(widget.players.length),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: _getChildAspectRatio(widget.players.length),
            ),
            itemCount: widget.players.length,
            itemBuilder: (context, index) => _PlayerCard(
              player: widget.players[index],
              index: index,
              status: _playerStates[index]['status'],
              points: _playerStates[index]['points'],
              isDoublee: widget.players[index].isDoublee,
              onStatusChanged: (status) {
                setState(() {
                  _playerStates[index]['status'] = status;
                });
              },
              onPointsChanged: (points) {
                setState(() {
                  _playerStates[index]['points'] = points;
                });
                widget.onPointsChanged(index, points);
              },
              onDoubleeToggle: () => _showDoubleeDialog(index),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final MarriagePlayer player;
  final int index;
  final String status;
  final double points;
  final bool isDoublee;
  final Function(String) onStatusChanged;
  final Function(double) onPointsChanged;
  final VoidCallback onDoubleeToggle;

  const _PlayerCard({
    required this.player,
    required this.index,
    required this.status,
    required this.points,
    required this.isDoublee,
    required this.onStatusChanged,
    required this.onPointsChanged,
    required this.onDoubleeToggle,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Win':
        return const Color(0xFF00C6FF);
      case 'Seen':
        return const Color(0xFFFFD166);
      case 'Unseen':
      default:
        return const Color(0xFF5A6C8A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8FAFF).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066FF).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8F0FF), width: 1.5),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0066FF).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: player.userImage != null
                            ? Image.file(File(player.userImage!), fit: BoxFit.cover)
                            : Icon(Icons.person, size: 20, color: const Color(0xFF0066FF).withOpacity(0.6)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.userName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1D2B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Player ${index + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF5A6C8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Status Selector
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE8F0FF)),
                  ),
                  child: Row(
                    children: ['Unseen', 'Seen', 'Win'].map((option) {
                      final isSelected = status == option;
                      return Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onStatusChanged(option),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? _getStatusColor(option) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  option,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF5A6C8A),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Points Input
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE8F0FF)),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Points:',
                        style: TextStyle(
                          color: Color(0xFF5A6C8A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1D2B),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.0',
                            hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
                          ),
                          onChanged: (value) => onPointsChanged(double.tryParse(value) ?? 0.0),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Doublee Toggle
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onDoubleeToggle,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDoublee ? const Color(0xFFFF6B6B).withOpacity(0.1) : const Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDoublee ? const Color(0xFFFF6B6B) : const Color(0xFFE8F0FF),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.looks_two,
                            size: 14,
                            color: isDoublee ? const Color(0xFFFF6B6B) : const Color(0xFF5A6C8A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isDoublee ? 'DOUBLEE MODE' : 'Normal',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDoublee ? const Color(0xFFFF6B6B) : const Color(0xFF5A6C8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Doublee Badge
          if (isDoublee)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '2x',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}