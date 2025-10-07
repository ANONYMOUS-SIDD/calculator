import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../controllers/call_break_controller.dart';

class BidPickerDialog extends StatefulWidget {
  final int playerIndex;
  final String tag;

  const BidPickerDialog({super.key, required this.playerIndex, required this.tag});

  @override
  State<BidPickerDialog> createState() => _BidPickerDialogState();
}

class _BidPickerDialogState extends State<BidPickerDialog> {
  static const Color primaryDark = Color(0xFF0D47A1); // Dark Blue Confirm
  static const Color accentDeep = Color(0xFFC51162); // Deep Pink Cancel
  static const Color nameDeepBlue = Color(0xFF1A237E); // Deep Blue for name

  late int currentBid;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<CallBreakController>(tag: widget.tag);
    currentBid = controller.currentBids[widget.playerIndex] == 0 ? 2 : controller.currentBids[widget.playerIndex];
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallBreakController>(tag: widget.tag);
    double dialogWidth = MediaQuery.of(context).size.width * 0.75;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.gavel_rounded, color: primaryDark, size: 24)],
            ),
            const SizedBox(height: 12),

            // Main Content Container
            Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
                boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 3, spreadRadius: 1)],
              ),
              child: Column(
                children: [
                  // Player Info + Current Bid
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Profile Picture with Outline
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: primaryDark, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: accentDeep.withOpacity(0.8),
                                backgroundImage: controller.selectedPlayers[widget.playerIndex].profileImagePath != null && controller.selectedPlayers[widget.playerIndex].profileImagePath!.isNotEmpty ? FileImage(File(controller.selectedPlayers[widget.playerIndex].profileImagePath!)) : null,
                                child: (controller.selectedPlayers[widget.playerIndex].profileImagePath == null || controller.selectedPlayers[widget.playerIndex].profileImagePath!.isEmpty)
                                    ? Text(
                                        controller.selectedPlayers[widget.playerIndex].username[0].toUpperCase(),
                                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Name Text with Deep Blue
                            Text(
                              controller.selectedPlayers[widget.playerIndex].username,
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: nameDeepBlue),
                            ),
                          ],
                        ),
                        // Current Bid Bubble (Slightly Smaller)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // reduced
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(colors: [Colors.indigo.shade900, Colors.blue.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            boxShadow: [BoxShadow(color: Colors.indigo.shade200.withOpacity(0.6), blurRadius: 4, spreadRadius: 1)],
                          ),
                          child: Text(
                            '$currentBid',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white), // reduced
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Horizontal Divider
                  Divider(color: Colors.grey.shade300, thickness: 1, height: 1),

                  // Horizontal Number Picker
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: NumberPicker(
                      value: currentBid,
                      minValue: 1,
                      maxValue: 13,
                      itemHeight: 40,
                      itemWidth: 50,
                      axis: Axis.horizontal,
                      textStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w500),
                      selectedTextStyle: GoogleFonts.poppins(fontSize: 22, color: accentDeep, fontWeight: FontWeight.w900),
                      onChanged: (value) {
                        setState(() {
                          currentBid = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
                boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 3, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        gradient: LinearGradient(colors: [accentDeep, accentDeep.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.cancel, size: 18, color: Colors.white),
                        label: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Confirm Button (Dark Blue Gradient)
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        gradient: LinearGradient(colors: [primaryDark, primaryDark.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.setBid(widget.playerIndex, currentBid);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.verified, size: 18, color: Colors.white),
                        label: Text(
                          'Confirm',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          padding: EdgeInsets.zero,
                        ),
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
