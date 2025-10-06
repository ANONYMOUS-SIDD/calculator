import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../controllers/call_break_controller.dart';

class BidPickerDialog extends StatelessWidget {
  final int playerIndex;
  final String tag;

  const BidPickerDialog({super.key, required this.playerIndex, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallBreakController>(tag: tag);
    int currentBid = controller.currentBids[playerIndex] == 0 ? 2 : controller.currentBids[playerIndex];

    return StatefulBuilder(
      builder: (context, setState) {
        double dialogWidth = MediaQuery.of(context).size.width * 0.75;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: dialogWidth,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 6))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Section: Icon + "Bid Selection"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_esports_rounded, color: Colors.blue.shade700, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      'BID SELECTION',
                      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Player Name Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal.shade400, width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.teal.shade100.withOpacity(0.7), blurRadius: 8, spreadRadius: 1)],
                  ),
                  child: Text(
                    controller.selectedPlayers[playerIndex].username,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.teal.shade700),
                  ),
                ),
                const SizedBox(height: 14),

                // Current Bid Bubble
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.lightBlue.shade300], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: Colors.blue.shade200.withOpacity(0.6), blurRadius: 12, spreadRadius: 1)],
                    border: Border.all(color: Colors.blue.shade400, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$currentBid',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Compact Number Picker
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade300, width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.blue.shade100.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)],
                  ),
                  child: NumberPicker(
                    value: currentBid,
                    minValue: 1,
                    maxValue: 13,
                    itemHeight: 40,
                    itemWidth: 45,
                    axis: Axis.vertical,
                    textStyle: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[400], fontWeight: FontWeight.w500),
                    selectedTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.blue.shade700),
                    onChanged: (value) {
                      setState(() {
                        currentBid = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Responsive Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.zero,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Cancel',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                              ),
                            ],
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
                          gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            controller.setBid(playerIndex, currentBid);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.zero,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.verified, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Confirm',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                              ),
                            ],
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
