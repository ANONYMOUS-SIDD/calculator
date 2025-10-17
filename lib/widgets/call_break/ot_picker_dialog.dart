import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../controllers/call_break_controller.dart';

/// Dialog for selecting overtricks (OT) in Callbreak game
/// Allows players to choose extra tricks taken beyond their bid
class OTPickerDialog extends StatefulWidget {
  final int playerIndex;
  final String tag;

  const OTPickerDialog({super.key, required this.playerIndex, required this.tag});

  @override
  State<OTPickerDialog> createState() => _OTPickerDialogState();
}

class _OTPickerDialogState extends State<OTPickerDialog> {
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accentDeep = Color(0xFFC51162);
  static const Color nameDeepBlue = Color(0xFF1A237E);

  late int currentExtra;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<CallBreakController>(tag: widget.tag);
    currentExtra = controller.currentExtras[widget.playerIndex] == 0 ? 2 : controller.currentExtras[widget.playerIndex];
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
            // Header Icon (Growth)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.trending_up_rounded, color: primaryDark, size: 28)],
            ),
            const SizedBox(height: 12),

            // Player Info + Current Extra
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
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
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
                            Text(
                              controller.selectedPlayers[widget.playerIndex].username,
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: nameDeepBlue),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(colors: [Colors.deepPurple.shade700, Colors.purple.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            boxShadow: [BoxShadow(color: Colors.purple.shade200.withOpacity(0.6), blurRadius: 4, spreadRadius: 1)],
                          ),
                          child: Text(
                            '$currentExtra',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: NumberPicker(
                      value: currentExtra,
                      minValue: 1,
                      maxValue: 13,
                      itemHeight: 40,
                      itemWidth: 50,
                      axis: Axis.horizontal,
                      textStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w500),
                      selectedTextStyle: GoogleFonts.poppins(fontSize: 22, color: accentDeep, fontWeight: FontWeight.w900),
                      onChanged: (value) {
                        setState(() {
                          currentExtra = value;
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
              child: Column(
                children: [
                  Row(
                    children: [
                      // Failed (Golo) - Pink Gradient
                      Expanded(
                        child: Container(
                          height: 36, // Reduced height
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [Colors.pink.shade700, Colors.pink.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final negativeExtra = -(currentExtra - 1);
                              controller.setExtra(widget.playerIndex, negativeExtra);
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.error_outline, size: 16, color: Colors.white), // Reduced icon size
                            label: Text(
                              'Golo',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white), // Reduced font size
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Tight - Purple Gradient
                      Expanded(
                        child: Container(
                          height: 36, // Reduced height
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [Colors.deepPurple.shade700, Colors.purple.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              controller.setExtra(widget.playerIndex, 0);
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.shield_rounded, size: 16, color: Colors.white), // Reduced icon size
                            label: Text(
                              'Tight',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white), // Reduced font size
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Cancel - Grey Gradient
                      Expanded(
                        child: Container(
                          height: 36, // Reduced height
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.cancel, size: 16, color: Colors.white), // Reduced icon size
                            label: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white), // Reduced font size
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Confirm - Primary Dark Gradient
                      Expanded(
                        child: Container(
                          height: 36, // Reduced height
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [primaryDark, primaryDark.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              controller.setExtra(widget.playerIndex, currentExtra);
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.verified, size: 16, color: Colors.white), // Reduced icon size
                            label: Text(
                              'Confirm',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white), // Reduced font size
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          ],
        ),
      ),
    );
  }
}
