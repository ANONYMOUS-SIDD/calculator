import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Modern IntroScreen for Marriage Calculator
/// - Lottie assets:
///   assets/lottie/intro1.json
///   assets/lottie/intro2.json
///   assets/lottie/intro3.json
/// - Call IntroScreen(onFinish: () { ... }) to handle completion.
class IntroScreen extends StatefulWidget {
  final VoidCallback? onFinish;

  const IntroScreen({Key? key, this.onFinish}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<_IntroPageData> _pages = [_IntroPageData(title: 'Welcome', lottie: 'assets/lottie/intro1.json', body: 'Welcome! Where numbers meet emotions, and joy is in every calculation.'), _IntroPageData(title: 'Explore', lottie: 'assets/lottie/intro2.json', body: 'Explore advanced features — unique, creative, and beyond ordinary math.'), _IntroPageData(title: 'Calculate', lottie: 'assets/lottie/intro3.json', body: 'Smart calculations that add fun, connection, and meaning to every result')];

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
    // animValue: 1.0 when on-center, <1 when off-center.
    final double scale = 0.96 + (animValue * 0.04); // subtle scale on focused
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
                    shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF8EE8FF), Color(0xFF7A92FF)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      text,
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // subtle gradient underline for refinement
                  Container(
                    width: 56,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF8EE8FF), Color(0xFF7A92FF)]),
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
    final media = MediaQuery.of(context);
    final topHeight = media.size.height * 0.34;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // calculate page offset (0 when focused)
        double page = 0;
        if (_controller.hasClients) {
          page = (_controller.page ?? _controller.initialPage.toDouble());
        } else {
          page = _page.toDouble();
        }
        final double delta = (page - index);
        final double absDelta = delta.abs().clamp(0.0, 1.0);

        // compute transform values
        final double lottieTranslateY = delta * 40; // parallax
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

              // Glass-like title box (only the page name) with gradient text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Opacity(opacity: 0.9 + (0.1 * titleAnim), child: _glassTitle(data.title, titleAnim)),
              ),

              const SizedBox(height: 18),

              // Center: description inside a translucent card with a modern left-accent bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Transform.translate(
                  offset: Offset(0, contentTranslateY),
                  child: Opacity(
                    opacity: contentOpacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04 + 0.02 * (1 - absDelta)),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.45 * (1 - absDelta)), blurRadius: 24, offset: const Offset(0, 10))],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // left accent bar
                          Container(
                            width: 6,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF8EE8FF), Color(0xFF7A92FF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                          ),
                          const SizedBox(width: 14),
                          // text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.body,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.94), fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // slightly increased gap so dots sit with a small comfortable space below the description
              const SizedBox(height: 98),

              // Page indicator placed a bit above the buttons (reduced bottom padding)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  // Reduced expansionFactor so current (active) dot is less elongated
                  effect: ExpandingDotsEffect(
                    dotHeight: 9,
                    dotWidth: 9,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white24,
                    expansionFactor: 1.6, // smaller expansion -> shorter active length
                    spacing: 8,
                  ),
                ),
              ),

              // Buttons stacked vertically: primary Next/Get Started then secondary Skip
              // moved slightly up by applying a small negative translate so buttons sit higher
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
                        height: 56, // fixed height for consistent sizing
                        child: _PrimarySameSizeButton(
                          label: _page == _pages.length - 1 ? 'Get Started' : 'Next',
                          onTap: _next,
                          // always forward arrow (no circle)
                          icon: Icons.arrow_forward_rounded,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Secondary skip button with glass-like outline — same size as primary
                      SizedBox(
                        width: double.infinity,
                        height: 56, // same fixed height
                        child: _SecondarySameSizeButton(label: 'Skip', onTap: _skipToEnd),
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

/// Primary button (kept same size as secondary) with improved visuals:
/// - refined gradient with soft glow, inline icon, stronger font
/// - subtle pressed scale via InkWell splash
class _PrimarySameSizeButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const _PrimarySameSizeButton({Key? key, required this.onTap, required this.label, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Slightly richer gradient, subtle outer glow and crisp border
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00E0FF), Color(0xFF0078FF)], begin: Alignment(-0.8, -0.4), end: Alignment(1.0, 0.8)),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              // main shadow
              BoxShadow(color: Colors.blueAccent.withOpacity(0.24), offset: const Offset(0, 10), blurRadius: 30),
              // soft outer glow
              BoxShadow(color: const Color(0xFF7AD8FF).withOpacity(0.08), offset: Offset(0, 0), blurRadius: 24),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // label
              Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(width: 12),
              // icon inline (no circle)
              Icon(icon, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary button (same height) with glass/frosted look and a crisp outline
class _SecondarySameSizeButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _SecondarySameSizeButton({Key? key, required this.onTap, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: InkWell(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.025),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 10),
                Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
              ],
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
