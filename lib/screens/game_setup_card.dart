import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact game setup card for player count selection, rate input, and player selection
class GameSetupCard extends StatefulWidget {
  final int selectedNumberOfPlayers;
  final int selectedPlayersCount;
  final double pointsPerRupee;
  final ValueChanged<int> onNumberOfPlayersChanged;
  final ValueChanged<double> onPointsPerRupeeChanged;
  final VoidCallback onOpenPlayerSelector;

  const GameSetupCard({super.key, required this.selectedNumberOfPlayers, required this.selectedPlayersCount, required this.pointsPerRupee, required this.onNumberOfPlayersChanged, required this.onPointsPerRupeeChanged, required this.onOpenPlayerSelector});

  @override
  State<GameSetupCard> createState() => _GameSetupCardState();
}

class _GameSetupCardState extends State<GameSetupCard> {
  final List<int> _playerOptions = [3, 4, 5, 6];
  late TextEditingController _rateController;

  // Color constants for consistent styling
  static const Color _primaryColor = Color(0xFF0066FF);
  static const Color _backgroundColor = Color(0xFFF8FBFF);
  static const Color _borderColor = Color(0xFFE9EFF8);
  static const Color _textPrimary = Color(0xFF1A1D2B);
  static const Color _textSecondary = Color(0xFF5A6C8A);
  static const Color _shadowColor = Color(0xFF0066FF);
  static const Color _buttonColor = Color(0xFF3C82FF);

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(text: widget.pointsPerRupee.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(covariant GameSetupCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update rate controller when points per rupee changes
    if (oldWidget.pointsPerRupee != widget.pointsPerRupee) {
      _rateController.text = widget.pointsPerRupee.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  /// Builds individual player count option chip
  Widget _buildPlayerOption(int value) {
    final bool isSelected = value == widget.selectedNumberOfPlayers;

    return GestureDetector(
      onTap: () => widget.onNumberOfPlayersChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? _primaryColor : _borderColor),
        ),
        child: Text(
          '$value',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: isSelected ? Colors.white : _textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
        boxShadow: [BoxShadow(color: _shadowColor.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          // Player Count Selection Section
          _buildPlayerCountSection(),

          // Rate Input Section
          _buildRateInputSection(),

          // Player Selection Button Section
          _buildPlayerSelectionButton(),
        ],
      ),
    );
  }

  /// Builds the player count selection section
  Widget _buildPlayerCountSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Players', style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary)),
          const SizedBox(height: 6),
          Row(
            children: _playerOptions.map((option) {
              return Padding(padding: const EdgeInsets.only(right: 8), child: _buildPlayerOption(option));
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Builds the rate input section
  Widget _buildRateInputSection() {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rate', style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary)),
          const SizedBox(height: 6),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor),
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
                    onChanged: (value) {
                      final doubleValue = double.tryParse(value);
                      if (doubleValue != null) {
                        widget.onPointsPerRupeeChanged(doubleValue);
                      }
                    },
                  ),
                ),
                Text('₹', style: GoogleFonts.poppins(color: _textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the player selection button section
  Widget _buildPlayerSelectionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Selected', style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary)),
        const SizedBox(height: 6),
        ElevatedButton(
          onPressed: widget.onOpenPlayerSelector,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.selectedPlayersCount == widget.selectedNumberOfPlayers ? _primaryColor : _buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(widget.selectedPlayersCount == 0 ? 'Select' : '${widget.selectedPlayersCount}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
