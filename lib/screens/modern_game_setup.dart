import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Assuming these models/widgets exist in your project
import '../model/marriage_game.dart';
import '../model/user_model.dart';
import '../widgets/player_selection_dialog.dart'; // Ensure this path is correct

class ModernGameSetup extends StatefulWidget {
  final int selectedPlayers; // The target/maximum player count
  final double pointsPerRupee;
  // This list now comes directly from the PlayerController and is reactive.
  final List<MarriagePlayer> selectedPlayersList;
  final Function(int) onPlayersChanged;
  final Function(double) onPointsChanged;
  final Function(List<User> confirmedUsers) onPlayersConfirmed;

  const ModernGameSetup({super.key, required this.selectedPlayers, required this.pointsPerRupee, required this.selectedPlayersList, required this.onPlayersChanged, required this.onPointsChanged, required this.onPlayersConfirmed});

  @override
  State<ModernGameSetup> createState() => _ModernGameSetupState();
}

class _ModernGameSetupState extends State<ModernGameSetup> {
  final List<int> _playerOptions = [3, 4, 5, 6];
  // Change to RxBool for reactive behavior
  final RxBool _isExpanded = true.obs;
  late final TextEditingController _pointsController;

  // Add a flag to track if we're currently editing points
  final RxBool _isEditingPoints = false.obs;

  // --- REVERTED COLOR CONSTANTS TO ORIGINAL GRADIENT THEME ---
  static const Color _primaryDark = Color(0xFF1E3A8A);
  static const Color _primaryMedium = Color(0xFF2563EB);
  static const Color _primaryLight = Color(0xFF3B82F6);
  static const Color _lightGrey = Color(0xFFF8FAFC);
  static const Color _borderGrey = Color(0xFFE5E7EB);
  static const Color _textGrey = Color(0xFF6B7280);
  static const Color _darkText = Color(0xFF1A1D21);

  // New color for iOS-like outline
  static const Color _iosBorder = Color(0xFFD1D5DB);
  static const Color _iosBackground = Color(0xFFF9FAFB);

  // --- RESTORED GRADIENT ---
  static const LinearGradient _blueGradient = LinearGradient(colors: [_primaryDark, _primaryMedium, _primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight);

  @override
  void initState() {
    super.initState();
    // Use the actual point value, not just the rounded one for initial display
    _pointsController = TextEditingController(text: widget.pointsPerRupee.toStringAsFixed(0));

    // Initialize the expanded state based on whether players are already selected
    if (widget.selectedPlayersList.length >= widget.selectedPlayers) {
      _isExpanded.value = false;
    }
  }

  @override
  void didUpdateWidget(covariant ModernGameSetup oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only handle player selection completion if not currently editing points
    if (!_isEditingPoints.value) {
      _handlePlayerSelectionCompletion();
    }

    // 2. Point Controller Update Logic
    if (oldWidget.pointsPerRupee != widget.pointsPerRupee) {
      String newPointsText = widget.pointsPerRupee.toStringAsFixed(0);
      if (_pointsController.text != newPointsText) {
        _pointsController.text = newPointsText;
      }
    }
  }

  // Reactive method to handle player selection completion
  void _handlePlayerSelectionCompletion() {
    final bool isComplete = widget.selectedPlayersList.length >= widget.selectedPlayers;

    // Automatically collapse when all players are selected AND not editing points
    if (isComplete && _isExpanded.value && !_isEditingPoints.value) {
      _isExpanded.value = false;
    }
  }

  @override
  void dispose() {
    _pointsController.dispose();
    _isExpanded.close(); // Important: close the Rx variable
    _isEditingPoints.close();
    super.dispose();
  }

  // --- RETAINED FUNCTIONAL FIX FOR DIALOG ---
  void _selectPlayers() async {
    final List<String> currentSelectedIds = widget.selectedPlayersList.map((p) => p.userName).toList();

    // 1. Await the result from the dialog
    final List<User>? confirmedUsers = await showDialog<List<User>>(
      context: context,
      builder: (context) => PlayerSelectionDialog(numberOfPlayers: widget.selectedPlayers, alreadySelectedPlayers: currentSelectedIds),
    );

    // 2. Check the result and pass it up to the parent widget (MarriageScreen)
    if (confirmedUsers != null && confirmedUsers.isNotEmpty) {
      widget.onPlayersConfirmed(confirmedUsers);

      // Immediately check if we should collapse after player selection
      _handlePlayerSelectionCompletion();
    }
  }

  void _confirmPlayerChange(int newCount) {
    if (newCount == widget.selectedPlayers) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Content Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Change  Player  Number',
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                  const SizedBox(height: 5),
                  // Message
                  Text(
                    'Are you sure you want to change the number of players',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // Actions Section - Exact same as your design
            Column(
              children: [
                const Divider(color: Colors.black12, height: 1.0, thickness: 0.8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const RoundedRectangleBorder()),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.blue.shade700),
                        ),
                      ),
                    ),

                    // Vertical Divider
                    Container(height: 45, width: 0.8, color: Colors.black12),

                    // Change Button
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: const RoundedRectangleBorder()),
                        onPressed: () {
                          widget.onPlayersChanged(newCount);
                          _isExpanded.value = true;
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Change',
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.red.shade700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- RESTORED ORIGINAL HEADER WITH GRADIENT AND SIMPLER BADGE DISPLAY ---
  Widget _buildHeader() {
    // Use the maximum number of players for the display (Original UI intent)
    String maxPlayers = widget.selectedPlayers.toString();
    String pointsValue = widget.pointsPerRupee.toStringAsFixed(0);

    return GestureDetector(
      onTap: () {
        // Only allow toggle if not currently editing points
        if (!_isEditingPoints.value) {
          _isExpanded.value = !_isExpanded.value;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // RESTORED GRADIENT
          gradient: _blueGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _primaryDark.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.sports_esports, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game Setup',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  // Progress Badge: [Max Players] | [Points Value] (Original format)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // RESTORED: Only Max Players count is shown
                        Text(
                          maxPlayers,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        // Separator '|'
                        Container(height: 12, width: 1, margin: const EdgeInsets.symmetric(horizontal: 6), color: Colors.white.withOpacity(0.5)),
                        // POINTS VALUE
                        Text(
                          pointsValue,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(_isExpanded.value ? Icons.expand_less : Icons.expand_more, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- RESTORED ORIGINAL PLAYER SELECTION WIDGET (Segmented Control look) ---
  Widget _buildPlayerSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderGrey, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _lightGrey,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _borderGrey),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group, size: 14, color: _primaryDark),
                const SizedBox(width: 6),
                Text(
                  'TOTAL PLAYERS',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _textGrey, letterSpacing: 0.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Segmented Control container
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: _lightGrey,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderGrey),
            ),
            child: Row(
              children: _playerOptions.map((number) {
                final isSelected = widget.selectedPlayers == number;
                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _confirmPlayerChange(number),
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          // RESTORED GRADIENT AND STYLING
                          gradient: isSelected ? _blueGradient : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFD1D5DB), width: 1.5),
                          boxShadow: isSelected ? [BoxShadow(color: _primaryLight.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : null,
                        ),
                        child: Center(
                          child: Text(
                            number.toString(),
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF374151)),
                          ),
                        ),
                      ),
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

  // --- RESTORED ORIGINAL COMBINED ACTIONS WIDGET (iOS-like styling) ---
  Widget _buildCombinedActions() {
    String currentPoints = widget.pointsPerRupee.toStringAsFixed(0);
    // Logic for button state
    bool canSelectMorePlayers = widget.selectedPlayersList.length < widget.selectedPlayers;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderGrey, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _lightGrey,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _borderGrey),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on_outlined, size: 14, color: _primaryDark),
                const SizedBox(width: 6),
                Text(
                  'POINTS',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _textGrey, letterSpacing: 0.8),
                ),
                Container(height: 12, width: 1, margin: const EdgeInsets.symmetric(horizontal: 6), color: _textGrey.withOpacity(0.5)),
                Text(
                  currentPoints,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _primaryDark, letterSpacing: 0.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // iOS-like WRAPPER CONTAINER
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _iosBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _iosBorder, width: 1.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Points Input Section
                Flexible(
                  flex: 3,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 85, maxWidth: 120),
                    height: 36, // Original smaller height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Center(
                        child: TextField(
                          controller: _pointsController,
                          textAlign: TextAlign.center, // Original alignment
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _primaryDark),
                          decoration: InputDecoration(
                            prefixText: 'POINT | ',
                            prefixStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _textGrey),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.only(bottom: 2),
                            hintText: '1',
                            hintStyle: GoogleFonts.inter(color: const Color(0xFFD1D5DB)),
                          ),
                          onTap: () {
                            // Set editing flag when user starts typing
                            _isEditingPoints.value = true;
                          },
                          onChanged: (value) {
                            int? parsedValue = int.tryParse(value);
                            if (parsedValue != null && parsedValue > 0) {
                              widget.onPointsChanged(parsedValue.toDouble());
                            }
                          },
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            int? finalValue = int.tryParse(_pointsController.text);
                            if (finalValue == null || finalValue <= 0) {
                              finalValue = widget.pointsPerRupee.round() > 0 ? widget.pointsPerRupee.round() : 1;
                            }
                            if (_pointsController.text != finalValue.toString()) {
                              _pointsController.text = finalValue.toString();
                            }
                            widget.onPointsChanged(finalValue.toDouble());

                            // Finish editing when tapping outside
                            _isEditingPoints.value = false;
                            // Now check if we should collapse
                            _handlePlayerSelectionCompletion();
                          },
                          onEditingComplete: () {
                            // When user presses tick/done on keyboard
                            FocusManager.instance.primaryFocus?.unfocus();
                            int? finalValue = int.tryParse(_pointsController.text);
                            if (finalValue == null || finalValue <= 0) {
                              finalValue = widget.pointsPerRupee.round() > 0 ? widget.pointsPerRupee.round() : 1;
                            }
                            if (_pointsController.text != finalValue.toString()) {
                              _pointsController.text = finalValue.toString();
                            }
                            widget.onPointsChanged(finalValue.toDouble());

                            // Finish editing and check if we should collapse
                            _isEditingPoints.value = false;
                            _handlePlayerSelectionCompletion();
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // 2. Select Players Button - RESTORED ORIGINAL APPEARANCE
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 36, // Original smaller height
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      // RESTORED GRADIENT AND DISABLED STATE LOGIC
                      gradient: canSelectMorePlayers ? _blueGradient : const LinearGradient(colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)]),
                      boxShadow: [BoxShadow(color: (canSelectMorePlayers ? _primaryLight : const Color(0xFF6B7280)).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: canSelectMorePlayers ? _selectPlayers : null,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.group_add, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'SELECT PLAYER',
                                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final dynamicMargin = screenWidth > 600 ? 32.0 : 16.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(left: dynamicMargin, right: dynamicMargin, top: 10, bottom: 20),
          decoration: BoxDecoration(
            color: _lightGrey,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Obx(
                () => AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      // The _isExpanded check controls the visibility of the setup controls
                      if (_isExpanded.value) ...[const SizedBox(height: 16), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildPlayerSelection()), const SizedBox(height: 12), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildCombinedActions()), const SizedBox(height: 16)],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
