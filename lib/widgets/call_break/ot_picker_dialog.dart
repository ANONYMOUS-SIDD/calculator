import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../controllers/call_break_controller.dart';

class OTPickerDialog extends StatelessWidget {
  final int playerIndex;
  final String tag;

  const OTPickerDialog({super.key, required this.playerIndex, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallBreakController>(tag: tag);
    int currentExtra = controller.currentExtras[playerIndex];
    final bid = controller.currentBids[playerIndex];

    return StatefulBuilder(
      builder: (context, setState) {
        double dialogWidth = MediaQuery.of(context).size.width * 0.78;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: dialogWidth,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title with Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calculate_rounded, color: Colors.green.shade700, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      'OT SELECTION',
                      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Player Name Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade400, width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.green.shade100.withOpacity(0.7), blurRadius: 8, spreadRadius: 1)],
                  ),
                  child: Text(
                    controller.selectedPlayers[playerIndex].username,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.green.shade700),
                  ),
                ),
                const SizedBox(height: 16),

                // Current Extra Bubble
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade300], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: Colors.green.shade200.withOpacity(0.6), blurRadius: 12, spreadRadius: 1)],
                    border: Border.all(color: Colors.green.shade400, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$currentExtra',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Number Picker Container
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300, width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.green.shade100.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)],
                  ),
                  child: NumberPicker(
                    value: currentExtra,
                    minValue: 0,
                    maxValue: 13,
                    itemHeight: 40,
                    itemWidth: 45,
                    axis: Axis.vertical,
                    textStyle: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[400], fontWeight: FontWeight.w500),
                    selectedTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.green.shade700),
                    onChanged: (value) {
                      setState(() {
                        currentExtra = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.orange.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            controller.setExtra(playerIndex, bid);
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.shield_rounded, size: 16, color: Colors.white),
                          label: Text(
                            'Tight',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            controller.setExtra(playerIndex, 0);
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.error_outline, size: 16, color: Colors.white),
                          label: Text(
                            'Failed',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Main Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.grey),
                          label: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey[700]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            controller.setExtra(playerIndex, currentExtra);
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.verified, size: 16, color: Colors.white),
                          label: Text(
                            'Confirm',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
