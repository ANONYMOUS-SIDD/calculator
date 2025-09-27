// screens/marriage_screen.dart
import 'package:calculators/screens/player_cards_grid.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/marriage_game.dart';
import '../model/user_model.dart';
import '../screens/user_app_bar.dart';
import 'modern_game_setup.dart';
import 'results_table.dart';

class MarriageScreen extends StatefulWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  const MarriageScreen({super.key, required this.tag, required this.color, required this.iconData});

  @override
  State<MarriageScreen> createState() => _MarriageScreenState();
}

class _MarriageScreenState extends State<MarriageScreen> {
  int _selectedPlayers = 4;
  double _pointsPerRupee = 1.0;
  final List<MarriagePlayer> _players = [];
  final List<MarriageGame> _gameHistory = [];

  // ❌ REMOVE THE OLD FUNCTION
  // void _onPlayerSelected(User user) {
  //   if (_players.length < _selectedPlayers) {
  //     setState(() {
  //       _players.add(MarriagePlayer(userId: user.username, userName: user.username, userImage: user.profileImagePath));
  //     });
  //   }
  // }

  // ✅ ADD THE NEW FUNCTION to handle the list of confirmed users
  void _onPlayersConfirmed(List<User> confirmedUsers) {
    setState(() {
      // 1. Clear the old list
      _players.clear();

      // 2. Add all confirmed users to the game's player list
      for (var user in confirmedUsers) {
        _players.add(MarriagePlayer(userId: user.username, userName: user.username, userImage: user.profileImagePath));
      }

      // 3. Update the total player count to match the selection
      _selectedPlayers = confirmedUsers.length;
    });
  }

  void _updatePlayerPoints(int index, double points) {
    setState(() {
      _players[index].maalPoints = points;
    });
  }

  void _toggleDoublee(int index) {
    setState(() {
      _players[index].isDoublee = !_players[index].isDoublee;
    });
  }

  void _calculateGame() {
    final game = MarriageGame(id: DateTime.now().millisecondsSinceEpoch.toString(), createdAt: DateTime.now(), numberOfPlayers: _selectedPlayers, pointsPerRupee: _pointsPerRupee, players: List.from(_players));

    setState(() {
      _gameHistory.insert(0, game);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Game calculated successfully!'),
        backgroundColor: const Color(0xFF0066FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _newGame() {
    setState(() {
      _players.clear();
      _gameHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: Column(
          children: [
            const UserAppBar(title: "Marriage"),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Game Setup
                    ModernGameSetup(
                      selectedPlayers: _selectedPlayers,
                      pointsPerRupee: _pointsPerRupee,
                      selectedPlayersList: _players,
                      onPlayersChanged: (value) => setState(() {
                        _selectedPlayers = value;
                        _players.clear();
                      }),
                      onPointsChanged: (value) => setState(() => _pointsPerRupee = value),

                      // 🔥 UPDATE THIS PROP 🔥
                      // You must also update the ModernGameSetup widget to accept
                      // a prop named 'onPlayersConfirmed' instead of 'onPlayerSelected'.
                      onPlayersConfirmed: _onPlayersConfirmed,
                    ),

                    // Players Grid
                    if (_players.isNotEmpty) PlayerCardsGrid(players: _players, onPointsChanged: _updatePlayerPoints, onDoubleeToggle: _toggleDoublee),

                    // Results
                    if (_gameHistory.isNotEmpty) ResultsTable(players: _players, pointsPerRupee: _pointsPerRupee),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            if (_players.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _newGame,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xFF0066FF)),
                        ),
                        child: Text(
                          'NEW GAME',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF0066FF)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _calculateGame,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF0066FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: Text(
                          'CALCULATE',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
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
  }
}
