import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact game setup section for player count, rate input, and player selection
class GameSetupSection extends StatefulWidget {
  final int selectedNumberOfPlayers;
  final int selectedPlayersCount;
  final double pointsPerRupee;
  final ValueChanged<int> onNumberOfPlayersChanged;
  final ValueChanged<double> onPointsPerRupeeChanged;
  final VoidCallback onOpenPlayerSelector;

  const GameSetupSection({super.key, required this.selectedNumberOfPlayers, required this.selectedPlayersCount, required this.pointsPerRupee, required this.onNumberOfPlayersChanged, required this.onPointsPerRupeeChanged, required this.onOpenPlayerSelector});

  @override
  State<GameSetupSection> createState() => _GameSetupSectionState();
}

class _GameSetupSectionState extends State<GameSetupSection> {
  final List<int> _options = [3, 4, 5, 6];
  late TextEditingController _rateController;

  // Color constants for consistent styling
  static const Color _primaryColor = Color(0xFF0066FF);
  static const Color _backgroundColor = Color(0xFFF8FAFF);
  static const Color _borderColor = Color(0xFFE1E8F5);
  static const Color _dividerColor = Color(0xFFECEFF8);
  static const Color _textPrimary = Color(0xFF1A1D2B);
  static const Color _textSecondary = Color(0xFF5A6C8A);
  static const Color _shadowColor = Color(0xFF0066FF);

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(text: widget.pointsPerRupee.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(covariant GameSetupSection oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
        boxShadow: [BoxShadow(color: _shadowColor.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          // Player Count Selection
          _buildPlayerCountSection(),

          // Vertical Divider
          _buildVerticalDivider(),

          // Rate Input Section
          _buildRateInputSection(),

          // Player Selection Button
          _buildPlayerSelectionButton(),
        ],
      ),
    );
  }

  /// Builds the player count selection section with chips
  Widget _buildPlayerCountSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Players', style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final number = _options[index];
                final isSelected = number == widget.selectedNumberOfPlayers;
                return _buildPlayerCountChip(number, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds individual player count chip
  Widget _buildPlayerCountChip(int number, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onNumberOfPlayersChanged(number),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : _backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? _primaryColor : _borderColor),
        ),
        child: Text(
          '$number',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : _textPrimary),
        ),
      ),
    );
  }

  /// Builds vertical divider between sections
  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 44, margin: const EdgeInsets.symmetric(horizontal: 12), color: _dividerColor);
  }

  /// Builds the rate input section
  Widget _buildRateInputSection() {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rate', style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary)),
          const SizedBox(height: 8),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor),
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
                      final doubleValue = double.tryParse(value) ?? widget.pointsPerRupee;
                      widget.onPointsPerRupeeChanged(doubleValue);
                    },
                    onChanged: (value) {
                      final doubleValue = double.tryParse(value);
                      if (doubleValue != null) {
                        widget.onPointsPerRupeeChanged(doubleValue);
                      }
                    },
                  ),
                ),
                Text('₹', style: GoogleFonts.poppins(fontSize: 14, color: _textSecondary)),
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Players selected', style: GoogleFonts.poppins(fontSize: 11, color: _textSecondary)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: widget.onOpenPlayerSelector,
          icon: const Icon(Icons.person_add, size: 18),
          label: Text(widget.selectedPlayersCount == 0 ? 'Select' : '${widget.selectedPlayersCount} selected', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            backgroundColor: widget.selectedPlayersCount == widget.selectedNumberOfPlayers ? _primaryColor : const Color(0xFF3C82FF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
