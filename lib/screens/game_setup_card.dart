// widgets/game_setup_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameSetupCard extends StatefulWidget {
  final int selectedNumberOfPlayers;
  final int selectedPlayersCount;
  final double pointsPerRupee;
  final ValueChanged<int> onNumberOfPlayersChanged;
  final ValueChanged<double> onPointsPerRupeeChanged;
  final VoidCallback onOpenPlayerSelector;

  const GameSetupCard({super.key, required this.selectedNumberOfPlayers, required this.pointsPerRupee, required this.onNumberOfPlayersChanged, required this.onPointsPerRupeeChanged, required this.onOpenPlayerSelector, required this.selectedPlayersCount});

  @override
  State<GameSetupCard> createState() => _GameSetupCardState();
}

class _GameSetupCardState extends State<GameSetupCard> {
  final List<int> _playerOptions = [3, 4, 5, 6];
  late TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(text: widget.pointsPerRupee.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(covariant GameSetupCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pointsPerRupee != widget.pointsPerRupee) {
      _rateController.text = widget.pointsPerRupee.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  Widget _buildOption(int value) {
    final selected = value == widget.selectedNumberOfPlayers;
    return GestureDetector(
      onTap: () => widget.onNumberOfPlayersChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0066FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? const Color(0xFF0066FF) : const Color(0xFFE7EDF8)),
        ),
        child: Text(
          '$value',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF1A1D2B)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86, // minimal area
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EFF8)),
        boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          // player options
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Players', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF5A6C8A))),
                const SizedBox(height: 6),
                Row(
                  children: _playerOptions.map((o) => Padding(padding: const EdgeInsets.only(right: 8), child: _buildOption(o))).toList(),
                ),
              ],
            ),
          ),

          // rate input (compact)
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rate', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF5A6C8A))),
                const SizedBox(height: 6),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE9EFF8)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _rateController,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                          onChanged: (v) {
                            final parsed = double.tryParse(v);
                            if (parsed != null) widget.onPointsPerRupeeChanged(parsed);
                          },
                        ),
                      ),
                      Text('₹', style: GoogleFonts.poppins(color: const Color(0xFF5A6C8A))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // selector button showing only count
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Selected', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF5A6C8A))),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: widget.onOpenPlayerSelector,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.selectedPlayersCount == widget.selectedNumberOfPlayers ? const Color(0xFF0066FF) : const Color(0xFF3C82FF),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(widget.selectedPlayersCount == 0 ? 'Select' : '${widget.selectedPlayersCount}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
