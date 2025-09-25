import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Modern IntroScreen for Marriage Calculator - Advanced 3D Effects
class IntroScreen extends StatefulWidget {
  final VoidCallback? onFinish;

  const IntroScreen({Key? key, this.onFinish}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _page = 0;

  // Global Animations
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Lottie Floating Animation
  late AnimationController _lottieFloatController;
  late Animation<double> _lottieFloatAnimation;

  // Define colors
  static const Color _cardBaseColor = Color(0xFF001F52);
  static const Color _glassGradientStart = Color(0xFF98E6FF);
  static const Color _glassGradientEnd = Color(0xFF6C8CFF);
  static const Color _neumorphicHighlight = Color(0xFF003A7F);

  // Background glow colors linked to page index
  final List<Color> _glowColors = [
    Colors.lightBlue.shade700, // Page 0: WELCOME
    Colors.purple.shade700, // Page 1: EXPLORE
    Colors.pink.shade700, // Page 2: CALCULATE
  ];

  final List<_IntroPageData> _pages = [_IntroPageData(title: 'WELCOME', lottie: 'assets/lottie/intro1.json', body: 'Where numbers meet emotions, and joy is in every personalized calculation and insight.'), _IntroPageData(title: 'EXPLORE', lottie: 'assets/lottie/intro2.json', body: 'Explore advanced features — unique, creative, and beyond ordinary math to strengthen your bond.'), _IntroPageData(title: 'CALCULATE', lottie: 'assets/lottie/intro3.json', body: 'Smart calculations that add fun, connection, and real meaning to every result you share together.')];

  @override
  void initState() {
    super.initState();

    // 1. Entrance Animation setup
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Floating Lottie Animation setup
    _lottieFloatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);

    _lottieFloatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _lottieFloatController, curve: Curves.easeInOutSine));
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
    } else {
      widget.onFinish?.call();
    }
  }

  void _skipToEnd() {
    HapticFeedback.lightImpact();
    _controller.animateToPage(_pages.length - 1, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    _entranceController.dispose();
    _lottieFloatController.dispose();
    super.dispose();
  }

  /// Dynamic Glowing Background
  Widget _background() {
    double page = 0;
    if (_controller.hasClients) {
      page = (_controller.page ?? _controller.initialPage.toDouble()).clamp(0.0, (_pages.length - 1).toDouble());
    } else {
      page = _page.toDouble();
    }

    final int startIndex = page.floor();
    final int endIndex = (page + 1).floor().clamp(0, _pages.length - 1);
    final double t = page - startIndex;

    final Color startColor = _glowColors[startIndex];
    final Color endColor = _glowColors[endIndex];
    final Color currentColor = Color.lerp(startColor, endColor, t) ?? startColor;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF001A40), Color(0xFF002C66), Color(0xFF041427)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(
        // Animated Container for the background glow
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: currentColor.withOpacity(0.4), blurRadius: 120.0, spreadRadius: 0.0),
              BoxShadow(color: currentColor.withOpacity(0.1), blurRadius: 200.0, spreadRadius: 10.0),
            ],
          ),
        ),
      ),
    );
  }

  // Glass title
  Widget _glassTitle(String text, double animValue) {
    // This title blur/scale can now be affected by the 3D tilt in _IntroPageContent
    final double scale = 0.95 + (animValue * 0.08);
    return Center(
      child: Transform.scale(
        scale: scale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0 * animValue, sigmaY: 8.0 * animValue),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.035 + 0.02 * animValue),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04 * animValue)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.28 * animValue), blurRadius: 12 * animValue, offset: Offset(0, 6 * animValue))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(colors: [_glassGradientStart, _glassGradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      text,
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 56,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_glassGradientStart, _glassGradientEnd]),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.10 * animValue), blurRadius: 8 * animValue, offset: Offset(0, 3 * animValue))],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // builds animated page content using page position
  Widget _buildPage(_IntroPageData data, BuildContext context, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double page = 0;
        if (_controller.hasClients) {
          page = (_controller.page ?? _controller.initialPage.toDouble());
        } else {
          page = _page.toDouble();
        }
        final double delta = (page - index);
        final double absDelta = delta.abs().clamp(0.0, 1.0);

        final double lottieTranslateYScroll = delta * 60;
        final double lottieScale = 1 - (absDelta * 0.1);
        final double contentOpacity = (1.0 - absDelta).clamp(0.0, 1.0);
        final double contentTranslateY = delta * 40;
        final double titleAnim = (1.0 - absDelta).clamp(0.0, 1.0);

        return SafeArea(
          child: Column(
            children: [
              // Lottie Animation Area (Responsive: 32% of total height)
              Expanded(
                flex: 32,
                child: FractionallySizedBox(
                  alignment: const Alignment(0, -0.15),
                  heightFactor: 1.0,
                  widthFactor: 1.0,
                  child: AnimatedBuilder(
                    animation: _lottieFloatAnimation,
                    builder: (context, child) {
                      // Combined scroll parallax and perpetual float animation
                      final double floatOffset = _lottieFloatAnimation.value * 10.0;
                      return Transform.translate(
                        offset: Offset(0, lottieTranslateYScroll + floatOffset),
                        child: Transform.scale(
                          scale: lottieScale,
                          child: Opacity(
                            opacity: contentOpacity,
                            child: Lottie.asset(data.lottie, fit: BoxFit.contain, repeat: true),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Glass-like title box (Subtle depth of field effect)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Opacity(opacity: 0.9 + (0.1 * titleAnim), child: _glassTitle(data.title, titleAnim)),
              ),

              const Spacer(flex: 2),

              // Center: ADVANCED 3D TILT DESCRIPTION CARD
              _IntroPageContent(data: data, contentOpacity: contentOpacity, contentTranslateY: contentTranslateY),

              const Spacer(flex: 3),

              // Page Indicator wrapped in a subtle glass container
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.0),
                      ),
                      child: SmoothPageIndicator(
                        controller: _controller,
                        count: _pages.length,
                        effect: const ExpandingDotsEffect(dotHeight: 9, dotWidth: 9, activeDotColor: Colors.white, dotColor: Colors.white24, expansionFactor: 1.6, spacing: 8),
                      ),
                    ),
                  ),
                ),
              ),

              // Buttons area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: _PrimaryPillButton(label: _page == _pages.length - 1 ? 'GET STARTED' : 'NEXT', onTap: _next),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: _SecondaryOutlineGlassButton(label: 'SKIP', onTap: _skipToEnd),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _background(),
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: PageView.builder(controller: _controller, itemCount: _pages.length, onPageChanged: (i) => setState(() => _page = i), itemBuilder: (context, i) => _buildPage(_pages[i], context, i)),
            ),
          ),
        ],
      ),
    );
  }
}

//---

/// NEW: Card that implements 3D tilt based on gesture drag.
class _IntroPageContent extends StatefulWidget {
  final _IntroPageData data;
  final double contentOpacity;
  final double contentTranslateY;

  const _IntroPageContent({required this.data, required this.contentOpacity, required this.contentTranslateY});

  @override
  State<_IntroPageContent> createState() => _IntroPageContentState();
}

class _IntroPageContentState extends State<_IntroPageContent> with SingleTickerProviderStateMixin {
  // Tilt values (normalized from -1.0 to 1.0)
  double _tiltX = 0;
  double _tiltY = 0;

  // Animation controller for smooth return to center
  late AnimationController _tiltController;
  late Animation<double> _tiltAnimation;

  @override
  void initState() {
    super.initState();
    _tiltController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _tiltAnimation = CurvedAnimation(parent: _tiltController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _tiltController.dispose();
    super.dispose();
  }

  // Resets the tilt animation
  void _resetTilt() {
    if (_tiltController.isAnimating) return;

    double startX = _tiltX;
    double startY = _tiltY;

    _tiltController.reset();
    _tiltAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_tiltController)
      ..addListener(() {
        setState(() {
          _tiltX = startX * (1.0 - _tiltAnimation.value);
          _tiltY = startY * (1.0 - _tiltAnimation.value);
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _tiltX = 0;
          _tiltY = 0;
        }
      });

    _tiltController.forward();
  }

  // Handles drag updates to set tilt values
  void _onPanUpdate(DragUpdateDetails details, Size size) {
    _tiltController.stop();

    // Calculate normalized position relative to the center of the card
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    double newX = (details.localPosition.dx - centerX) / centerX;
    double newY = (details.localPosition.dy - centerY) / centerY;

    // Invert for natural rotation (tilt away from the pointer)
    _tiltX = (newY * -1).clamp(-0.15, 0.15); // Sensitivity Y-axis for X rotation
    _tiltY = (newX * 1).clamp(-0.15, 0.15); // Sensitivity X-axis for Y rotation

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const Color shadowColor = Color(0xFF000F22);
    const double borderRadius = 16.0;

    // Max rotation in degrees
    const double maxTilt = 10.0;
    final double rotX = _tiltX * maxTilt * (1.0 - widget.contentOpacity); // Dampen tilt when fading out
    final double rotY = _tiltY * maxTilt * (1.0 - widget.contentOpacity);

    return GestureDetector(
      onPanUpdate: (d) => _onPanUpdate(d, context.size ?? Size.zero),
      onPanEnd: (_) => _resetTilt(),
      onTapDown: (_) => _resetTilt(),
      onTapUp: (_) => _resetTilt(),
      child: Transform(
        // The 3D Matrix Transform
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..rotateX(rotX * (3.14159 / 180))
          ..rotateY(rotY * (3.14159 / 180)),
        alignment: FractionalOffset.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Transform.translate(
            offset: Offset(0, widget.contentTranslateY),
            child: Opacity(
              opacity: widget.contentOpacity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
                    decoration: BoxDecoration(
                      color: _IntroScreenState._cardBaseColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.0),
                      boxShadow: const [
                        BoxShadow(color: _IntroScreenState._glassGradientStart, offset: Offset(2, 2), blurRadius: 10, spreadRadius: -2),
                        BoxShadow(color: _IntroScreenState._glassGradientEnd, offset: Offset(-2, -2), blurRadius: 10, spreadRadius: -2),
                        BoxShadow(color: _IntroScreenState._neumorphicHighlight, offset: Offset(-5, -5), blurRadius: 12, spreadRadius: -2),
                        BoxShadow(color: shadowColor, offset: Offset(7, 7), blurRadius: 14, spreadRadius: -2),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.body,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            color: Colors.white,
                            fontSize: 15.5,
                            height: 1.6,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(color: Colors.black.withOpacity(0.6), offset: const Offset(1.0, 1.0), blurRadius: 2),
                              Shadow(color: Colors.white.withOpacity(0.1), offset: const Offset(0, 0), blurRadius: 1),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Container(
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [_IntroScreenState._glassGradientStart, _IntroScreenState._glassGradientEnd]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//---

/// Primary Pill Button (Unchanged, remains clean and animated)
class _PrimaryPillButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;

  const _PrimaryPillButton({Key? key, required this.onTap, required this.label}) : super(key: key);

  @override
  State<_PrimaryPillButton> createState() => _PrimaryPillButtonState();
}

class _PrimaryPillButtonState extends State<_PrimaryPillButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.3, 0.0)).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) => _animationController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 27.0;
    const List<Color> gradientColors = [Color(0xFF003D95), Color(0xFF007A92)];
    const Color shadowColor = Color(0xFF007A92);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.0),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(color: shadowColor.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 15),
          BoxShadow(color: shadowColor.withOpacity(0.08), offset: Offset(0, 0), blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleTap,
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            child: Ink(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: gradientColors, begin: Alignment.centerLeft, end: Alignment.centerRight),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.0, letterSpacing: 2.0),
                  ),
                  const SizedBox(width: 10),
                  SlideTransition(
                    position: _slideAnimation,
                    child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//---

/// Secondary Outline Glass Button (Unchanged, retains interactive scale/blur)
class _SecondaryOutlineGlassButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;

  const _SecondaryOutlineGlassButton({Key? key, required this.onTap, required this.label}) : super(key: key);

  @override
  State<_SecondaryOutlineGlassButton> createState() => _SecondaryOutlineGlassButtonState();
}

class _SecondaryOutlineGlassButtonState extends State<_SecondaryOutlineGlassButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _blurAnimation = Tween<double>(begin: 10.0, end: 5.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();
  void _onTap() => widget.onTap();

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 27.0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _blurAnimation.value, sigmaY: _blurAnimation.value),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.01),
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.0),
                  ),
                  child: Text(
                    widget.label,
                    style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600, fontSize: 12.0, letterSpacing: 1.5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IntroPageData {
  final String title;
  final String lottie;
  final String body;

  _IntroPageData({required this.title, required this.lottie, required this.body});
}
