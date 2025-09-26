// lib/screens/user_app_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const UserAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.blue.shade50, // light blue mixed into white
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.15), blurRadius: 16, spreadRadius: 1, offset: const Offset(0, 6))],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glossy Capsule Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade100, Colors.blue.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 8, offset: const Offset(2, 3))],
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),

          // Back button (aligned left)
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade100, Colors.blue.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 8, offset: const Offset(2, 3))],
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.blue, size: 18),
              ),
            ),
          ),

          // Lottie animation (aligned right)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade100, Colors.blue.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.25), blurRadius: 10, offset: const Offset(2, 3))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Lottie.asset("assets/lottie/intro1.json", fit: BoxFit.contain, repeat: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65); // reduced height
}
