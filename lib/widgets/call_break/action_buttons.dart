import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/call_break_controller.dart';

class ActionButtons extends StatelessWidget {
  final String tag;

  const ActionButtons({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final buttonHeight = screenHeight < 700 ? 40.0 : 42.0;
    final buttonFontSize = screenWidth < 350 ? 11.0 : 13.0;
    final iconSize = screenWidth < 350 ? 16.0 : 18.0;

    return Obx(() {
      final controller = Get.find<CallBreakController>(tag: tag);

      return Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth < 400 ? 12.0 : 16.0, vertical: screenHeight < 700 ? 8.0 : 12.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 25, spreadRadius: 1, offset: const Offset(0, -6))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: screenWidth < 350 ? 8.0 : 12.0, vertical: screenHeight < 700 ? 8.0 : 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(colors: [Colors.grey.shade50, Colors.grey.shade100], begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: screenWidth < 350
                  ? Column(children: [_buildNewGameButton(controller, buttonHeight, buttonFontSize, iconSize), const SizedBox(height: 10), _buildRoundButton(controller, buttonHeight, buttonFontSize, iconSize)])
                  : Row(
                      children: [
                        Expanded(child: _buildNewGameButton(controller, buttonHeight, buttonFontSize, iconSize)),
                        SizedBox(width: screenWidth < 400 ? 10.0 : 14.0),
                        Expanded(child: _buildRoundButton(controller, buttonHeight, buttonFontSize, iconSize)),
                      ],
                    ),
            ),
            SizedBox(height: screenHeight < 700 ? 4.0 : 6.0),
          ],
        ),
      );
    });
  }

  Widget _buildNewGameButton(CallBreakController controller, double height, double fontSize, double iconSize) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [Colors.pinkAccent.shade200, Colors.pinkAccent.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: controller.resetGame,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh_rounded, size: iconSize, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                "NEW GAME",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: fontSize, color: Colors.white, letterSpacing: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundButton(CallBreakController controller, double height, double fontSize, double iconSize) {
    final bool canStartRound = controller.selectedPlayers.isNotEmpty && controller.currentRound.value <= 5 && !controller.bidPhase.value && !controller.otPhase.value;
    final bool allBidsCompleted = controller.bidCompleted.every((completed) => completed);
    final bool allOTCompleted = controller.otCompleted.every((completed) => completed);

    String buttonText;
    VoidCallback? onPressed;
    Color backgroundColor = const Color(0xFF0D47A1); // Deep Dark Blue
    IconData icon = Icons.play_arrow;

    if (controller.currentRound.value > 5) {
      buttonText = 'COMPLETED';
      onPressed = null;
      backgroundColor = Colors.grey.shade600;
      icon = Icons.check;
    } else if (canStartRound) {
      buttonText = 'START ROUND ${controller.currentRound.value}';
      onPressed = controller.startRound;
      icon = Icons.play_arrow;
    } else if (controller.bidPhase.value && allBidsCompleted && !controller.otPhase.value) {
      buttonText = 'FINISH ROUND ${controller.currentRound.value}';
      onPressed = controller.finishBidPhase;
      icon = Icons.flag;
    } else if (controller.otPhase.value && allOTCompleted) {
      buttonText = 'FINISH ROUND ${controller.currentRound.value}';
      onPressed = controller.finishRound;
      icon = Icons.verified;
    } else {
      buttonText = 'START ROUND ${controller.currentRound.value}';
      onPressed = null;
      backgroundColor = Colors.grey;
      icon = Icons.play_arrow;
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: onPressed != null ? LinearGradient(colors: [backgroundColor, Color.alphaBlend(backgroundColor.withOpacity(0.8), backgroundColor)], begin: Alignment.topLeft, end: Alignment.bottomRight) : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: onPressed != null ? [BoxShadow(color: backgroundColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))] : [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                buttonText,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: fontSize, color: Colors.white, letterSpacing: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
