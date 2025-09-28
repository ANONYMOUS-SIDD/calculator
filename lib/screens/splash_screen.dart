import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'home_screen.dart';

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

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Navigate to HomeScreen after 3 seconds using GetX
    Future.delayed(const Duration(seconds: 3), () {
      // Use Get.off() to navigate to the HomeScreen widget
      // and remove the SplashScreen from the navigation stack.
      Get.off(() => const HomeScreen());
    });
  } // ❌ initState() ENDS HERE

  // ✅ CORRECT PLACEMENT: dispose() must be a direct method of the State class
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ✅ CORRECT PLACEMENT: build() must be a direct method of the State class
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

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
            // Vignette effect
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
                  // Use pi from dart:math for accuracy, but 3.1415 is fine.
                  double angle = -_flipAnimation.value * 3.1415;
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
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
                      BoxShadow(color: Colors.black.withOpacity(0.25), offset: const Offset(6, 6), blurRadius: 15, spreadRadius: 1),
                      BoxShadow(color: Colors.white.withOpacity(0.2), offset: const Offset(-6, -6), blurRadius: 15, spreadRadius: 1),
                    ],
                    border: Border.all(width: 3, color: Colors.white.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
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
