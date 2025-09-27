// widgets/game_setup_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameSetupSection extends StatefulWidget {
  final int selectedNumberOfPlayers;
  final int selectedPlayersCount;
  final double pointsPerRupee;
  final ValueChanged<int> onNumberOfPlayersChanged;
  final ValueChanged<double> onPointsPerRupeeChanged;
  final VoidCallback onOpenPlayerSelector;

  const GameSetupSection({super.key, required this.selectedNumberOfPlayers, required this.pointsPerRupee, required this.onNumberOfPlayersChanged, required this.onPointsPerRupeeChanged, required this.onOpenPlayerSelector, required this.selectedPlayersCount});

  @override
  State<GameSetupSection> createState() => _GameSetupSectionState();
}

class _GameSetupSectionState extends State<GameSetupSection> {
  final List<int> _options = [3, 4, 5, 6];
  late TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(text: widget.pointsPerRupee.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(covariant GameSetupSection oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    // A compact, minimal-height, visually pleasing card that groups player count, rate and select-player action.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E8F5)),
        boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          // Player count chips - compact vertical stacked label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Players', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF5A6C8A))),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _options.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final number = _options[idx];
                      final selected = number == widget.selectedNumberOfPlayers;
                      return GestureDetector(
                        onTap: () => widget.onNumberOfPlayersChanged(number),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF0066FF) : const Color(0xFFF8FAFF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? const Color(0xFF0066FF) : const Color(0xFFE1E8F5)),
                          ),
                          child: Text(
                            '$number',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF1A1D2B)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(width: 1, height: 44, margin: const EdgeInsets.symmetric(horizontal: 12), color: const Color(0xFFECEFF8)),

          // Rate input
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rate', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF5A6C8A))),
                const SizedBox(height: 8),
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE1E8F5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _rateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                          textAlign: TextAlign.center,
                          onSubmitted: (value) {
                            final v = double.tryParse(value) ?? widget.pointsPerRupee;
                            widget.onPointsPerRupeeChanged(v);
                          },
                          onChanged: (value) {
                            final v = double.tryParse(value);
                            if (v != null) widget.onPointsPerRupeeChanged(v);
                          },
                        ),
                      ),
                      Text('₹', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF5A6C8A))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Select players action
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Players selected', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF5A6C8A))),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: widget.onOpenPlayerSelector,
                icon: const Icon(Icons.person_add, size: 18),
                label: Text(widget.selectedPlayersCount == 0 ? 'Select' : '${widget.selectedPlayersCount} selected', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  backgroundColor: widget.selectedPlayersCount == widget.selectedNumberOfPlayers ? const Color(0xFF0066FF) : const Color(0xFF3C82FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
