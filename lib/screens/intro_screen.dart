import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Modern IntroScreen for Marriage Calculator
class IntroScreen extends StatefulWidget {
  final VoidCallback? onFinish;

  const IntroScreen({Key? key, this.onFinish}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<_IntroPageData> _pages = [_IntroPageData(title: 'DATA MEETS EMOTION', lottie: 'assets/lottie/intro1.json', body: 'Where numbers meet emotions, and joy is in every personalized calculation and insight.'), _IntroPageData(title: 'ADVANCED FEATURES', lottie: 'assets/lottie/intro2.json', body: 'Explore advanced features — unique, creative, and beyond ordinary math to strengthen your bond.'), _IntroPageData(title: 'CALCULATE & SHARE', lottie: 'assets/lottie/intro3.json', body: 'Smart calculations that add fun, connection, and real meaning to every result you share together.')];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic);
    } else {
      widget.onFinish?.call();
    }
  }

  void _skipToEnd() {
    _controller.animateToPage(_pages.length - 1, duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Define refined colors
  static const Color _cardBaseColor = Color(0xFF001F52);
  static const Color _glassGradientStart = Color(0xFF98E6FF);
  static const Color _glassGradientEnd = Color(0xFF6C8CFF);
  static const Color _neumorphicHighlight = Color(0xFF003A7F);

  Widget _background() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF001A40), Color(0xFF002C66), Color(0xFF041427)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Container(
        // subtle vignette
        decoration: BoxDecoration(
          gradient: RadialGradient(center: const Alignment(0.0, -0.75), radius: 1.0, colors: [Colors.transparent, Colors.black.withOpacity(0.36)], stops: const [0.62, 1.0]),
        ),
      ),
    );
  }

  // glass title with gradient text and subtle underline accent
  Widget _glassTitle(String text, double animValue) {
    final double scale = 0.96 + (animValue * 0.04);
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
                  // gradient title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(colors: [_glassGradientStart, _glassGradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      text,
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // subtle gradient underline
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

  // UPDATED: Glass-outlined Description Card with Text Enhancements
  Widget _buildNeumorphicDescriptionCard(_IntroPageData data, double contentOpacity, double contentTranslateY) {
    const Color shadowColor = Color(0xFF000F22);
    const double borderRadius = 16.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Transform.translate(
        offset: Offset(0, contentTranslateY),
        child: Opacity(
          opacity: contentOpacity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Strong blur for glass effect
              child: Container(
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
                decoration: BoxDecoration(
                  color: _cardBaseColor.withOpacity(0.6), // More transparent base color
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15), // Subtle glass border
                    width: 1.0,
                  ),
                  boxShadow: [
                    // Inner glow to mimic light on glass edges
                    BoxShadow(color: _glassGradientStart.withOpacity(0.08), offset: const Offset(2, 2), blurRadius: 10, spreadRadius: -2),
                    BoxShadow(color: _glassGradientEnd.withOpacity(0.08), offset: const Offset(-2, -2), blurRadius: 10, spreadRadius: -2),
                    // Original Neumorphic shadows for depth
                    BoxShadow(color: _neumorphicHighlight.withOpacity(0.8), offset: const Offset(-5, -5), blurRadius: 12, spreadRadius: -2),
                    BoxShadow(color: shadowColor.withOpacity(0.9), offset: const Offset(7, 7), blurRadius: 14, spreadRadius: -2),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // UPDATED: Text style using Quicksand font
                    Text(
                      data.body,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        // Changed font to Quicksand
                        color: Colors.white, // Full opacity white
                        fontSize: 15.5,
                        height: 1.6,
                        fontWeight: FontWeight.w600, // Semi-bold for sharpness
                        shadows: [
                          // Crisp inner shadow
                          Shadow(color: Colors.black.withOpacity(0.6), offset: const Offset(1.0, 1.0), blurRadius: 2),
                          // Subtle light glow
                          Shadow(color: Colors.white.withOpacity(0.1), offset: const Offset(0, 0), blurRadius: 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtle divider or accent at the bottom of the card
                    Center(
                      child: Container(
                        width: 60,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_glassGradientStart, _glassGradientEnd]),
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
    );
  }

  // builds animated page content using page position
  Widget _buildPage(_IntroPageData data, BuildContext context, int index) {
    final media = MediaQuery.of(context);
    final topHeight = media.size.height * 0.32;

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
        final double lottieTranslateY = delta * 40;
        final double lottieScale = 1 - (absDelta * 0.06);
        final double contentOpacity = (1.0 - absDelta * 0.5).clamp(0.0, 1.0);
        final double contentTranslateY = delta * 18;
        final double titleAnim = (1.0 - absDelta).clamp(0.0, 1.0);

        return SafeArea(
          child: Column(
            children: [
              // Top area: Lottie with parallax + scale
              SizedBox(
                height: topHeight,
                child: Align(
                  alignment: const Alignment(0, -0.35),
                  child: Transform.translate(
                    offset: Offset(0, lottieTranslateY),
                    child: Transform.scale(
                      scale: lottieScale,
                      child: Opacity(
                        opacity: contentOpacity,
                        child: Lottie.asset(data.lottie, fit: BoxFit.contain, repeat: true),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Glass-like title box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Opacity(opacity: 0.9 + (0.1 * titleAnim), child: _glassTitle(data.title, titleAnim)),
              ),

              const SizedBox(height: 28),

              // Center: NEUMORPHIC DESCRIPTION CARD
              _buildNeumorphicDescriptionCard(data, contentOpacity, contentTranslateY),

              const SizedBox(height: 78),

              // Page indicator placed a bit above the buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(dotHeight: 9, dotWidth: 9, activeDotColor: Colors.white, dotColor: Colors.white24, expansionFactor: 1.6, spacing: 8),
                ),
              ),

              // Buttons stacked vertically
              Transform.translate(
                offset: const Offset(0, -6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Primary full-width modern gradient button (Next / Get Started)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: _PrimaryPillButton(label: _page == _pages.length - 1 ? 'GET STARTED' : 'NEXT', onTap: _next),
                      ),

                      const SizedBox(height: 12),

                      // Secondary skip button with new glass outline design
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: _SecondaryOutlineGlassButton(label: 'SKIP', onTap: _skipToEnd),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _background(),
          PageView.builder(controller: _controller, itemCount: _pages.length, onPageChanged: (i) => setState(() => _page = i), itemBuilder: (context, i) => _buildPage(_pages[i], context, i)),
        ],
      ),
    );
  }
}

//---

/// Primary Pill Button with Deep Sapphire Blue Gradient and Gloss Border
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
    // Deep Sapphire Blue to Dark Cyan
    const List<Color> gradientColors = [Color(0xFF003D95), Color(0xFF007A92)];
    const Color shadowColor = Color(0xFF007A92);

    return Container(
      decoration: BoxDecoration(
        // Outer white glass border
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
                  // Animated icon
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

/// Secondary Outline Glass Button
class _SecondaryOutlineGlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _SecondaryOutlineGlassButton({Key? key, required this.onTap, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 27.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white10,
            highlightColor: Colors.white.withOpacity(0.02),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.01),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25), // Brighter, clearer glass border
                  width: 1.0,
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600, fontSize: 12.0, letterSpacing: 1.5),
              ),
            ),
          ),
        ),
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
