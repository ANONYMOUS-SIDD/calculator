import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'home_screen.dart';

/// Splash screen with animated card flip and fade transitions
/// Features a 3D card flip animation with gradient background and vignette effect
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for 2-second duration
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    // Flip animation for 3D card rotation effect
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Fade animation for smooth opacity transition
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start the animation sequence
    _controller.forward();

    // Navigate to HomeScreen after 3 seconds using GetX
    Future.delayed(const Duration(seconds: 3), () {
      // Use Get.off() to navigate to the HomeScreen widget
      // and remove the SplashScreen from the navigation stack.
      Get.off(() => const HomeScreen());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Responsive container sizing
    final double containerWidth = screenWidth * 0.4;
    final double containerHeight = screenHeight * 0.3;
    final BorderRadius borderRadius = BorderRadius.circular(20);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF001F3F), // deep blue
              Color(0xFF004C99), // blueish
            ],
          ),
        ),
        child: Stack(
          children: [
            // Vignette effect for depth and focus
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(center: Alignment.center, radius: 1.0, colors: [Colors.transparent, Colors.black.withOpacity(0.25)], stops: const [0.7, 1.0]),
              ),
            ),

            // Center card rectangle with flip + fade animation
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Calculate rotation angle for 3D flip effect
                  double angle = -_flipAnimation.value * 3.1415;
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Perspective transformation
                        ..rotateY(angle), // 3D rotation around Y-axis
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: containerWidth,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF42A5F5), Color(0xFF81D4FA)]),
                    boxShadow: [
                      // Bottom-right shadow for depth
                      BoxShadow(color: Colors.black.withOpacity(0.25), offset: const Offset(6, 6), blurRadius: 15, spreadRadius: 1),
                      // Top-left highlight for glassmorphism effect
                      BoxShadow(color: Colors.white.withOpacity(0.2), offset: const Offset(-6, -6), blurRadius: 15, spreadRadius: 1),
                    ],
                    border: Border.all(width: 3, color: Colors.white.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // Glassmorphism blur effect
                      child: Center(
                        child: Lottie.asset('assets/lottie/loading card suit.json', width: containerWidth * 0.8, height: containerHeight * 0.5, repeat: true),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
