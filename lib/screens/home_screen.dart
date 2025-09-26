import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

// 🎨 Final Dark Theme Color Palette with Simplified Blue Gradient Shades
class ModernColors {
  // Simplified Gradient Background Colors
  static const Color gradientStart = Color(0xFF1E3C72); // Darker Blue (Near Top Left)
  static const Color gradientEnd = Color(0xFF2A5298); // Lighter Blue (Near Bottom Right)

  // Surface & Accent Colors (Kept dark for contrast against the new background)
  static const Color darkSurface = Color(0xFF1A243F); // Card/Search background base
  static const Color neonCyan = Color(0xFF00FFFF); // Primary Accent (Vibrant)
  static const Color electricBlue = Color(0xFF0099FF); // Secondary Accent
  static const Color textLight = Color(0xFFE0E0E0); // Light Text
  static const Color textMuted = Color(0xFFA0A0CC); // Muted Text

  // Grid Accent Colors (Retained)
  static const Color gridMarriage = Color(0xFF00E5FF);
  static const Color gridCallBreak = Color(0xFF3366FF);
  static const Color gridHistory = Color(0xFF9966FF);
  static const Color gridUsers = Color(0xFFFF9900);
  static const Color gridRules = Color(0xFF00FF99);
  static const Color gridSettings = Color(0xFFCCCCCC);
}

// ----------------------------------------------------
// 🌟 NEW: Staggered Fade-In Animation for Grid Items
// ----------------------------------------------------
class _StaggeredGridFadeIn extends StatefulWidget {
  final int index;
  final Widget child;
  const _StaggeredGridFadeIn({super.key, required this.index, required this.child});

  @override
  State<_StaggeredGridFadeIn> createState() => _StaggeredGridFadeInState();
}

class _StaggeredGridFadeInState extends State<_StaggeredGridFadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    // Stagger the animation start for each item
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero) // Slide slightly upwards
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
// ----------------------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  // Grid Items Data
  final List<GridItem> _gridItems = const [GridItem(Icons.favorite, "Marriage", ModernColors.gridMarriage), GridItem(Icons.grade, "Call Break", ModernColors.gridCallBreak), GridItem(Icons.restore, "Game History", ModernColors.gridHistory), GridItem(Icons.groups, "Users", ModernColors.gridUsers), GridItem(Icons.gavel, "Rules", ModernColors.gridRules), GridItem(Icons.settings, "Settings", ModernColors.gridSettings)];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768;
    final isDesktop = size.width >= 1024;
    final greeting = _greetingMessage();

    // Full-screen diagonal simple blue gradient
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight, // Diagonal direction
            colors: [
              ModernColors.gradientStart, // Darker Blue
              ModernColors.gradientEnd, // Lighter Blue
            ],
          ),
        ),
        // No global fade-in, as grid items will now animate individually
        child: SafeArea(
          child: Column(
            children: [
              // 1. MINIMALIST HEADER
              _buildMinimalistHeader(greeting, context, isDesktop),

              // 2. OPTIMIZED GRID SECTION
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 15 : 10, vertical: 10),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop
                          ? 4
                          : isTablet
                          ? 3
                          : 2,
                      crossAxisSpacing: isDesktop ? 15 : 10,
                      mainAxisSpacing: isDesktop ? 15 : 10,
                      childAspectRatio: isDesktop
                          ? 0.98
                          : isTablet
                          ? 0.95
                          : 1.0,
                    ),
                    itemCount: _gridItems.length,
                    itemBuilder: (context, index) => _StaggeredGridFadeIn(
                      // 🌟 Wrap each grid item
                      index: index,
                      child: _ModernGridItemWithFeedback(gridItem: _gridItems[index], isDesktop: isDesktop),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 MINIMALIST HEADER
  Widget _buildMinimalistHeader(String greeting, BuildContext context, bool isDesktop) {
    final horizontalPadding = isDesktop ? 40.0 : 20.0;
    final double lottieSize = isDesktop ? 80 : 65;

    return Padding(
      padding: EdgeInsets.only(top: 5, left: horizontalPadding, right: horizontalPadding, bottom: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                greeting,
                style: GoogleFonts.poppins(fontSize: isDesktop ? 22 : 18, fontWeight: FontWeight.w800, color: ModernColors.textLight),
              ),
              Container(
                width: lottieSize,
                height: lottieSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: ModernColors.neonCyan.withOpacity(0.3), blurRadius: 20, spreadRadius: 1)],
                  border: Border.all(color: ModernColors.neonCyan.withOpacity(0.2), width: 1.5),
                ),
                child: Lottie.asset("assets/lottie/intro1.json", fit: BoxFit.contain),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Search Bar
          _ModernSearchBar(context, isDesktop),
        ],
      ),
    );
  }

  // 🔹 Modern Search Bar
  Widget _ModernSearchBar(BuildContext context, bool isDesktop) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isDesktop ? 25 : 20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          decoration: BoxDecoration(
            color: ModernColors.darkSurface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(isDesktop ? 25 : 20),
            border: Border.all(color: ModernColors.neonCyan.withOpacity(0.5), width: 1),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search modules...",
              hintStyle: GoogleFonts.poppins(color: ModernColors.textMuted.withOpacity(0.8), fontSize: isDesktop ? 15 : 13),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(Icons.search, color: ModernColors.neonCyan, size: isDesktop ? 22 : 18),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 10, horizontal: 20),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(isDesktop ? 25 : 20), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 25 : 20),
                borderSide: BorderSide(color: ModernColors.electricBlue, width: 2),
              ),
            ),
            style: GoogleFonts.poppins(color: ModernColors.textLight, fontSize: isDesktop ? 15 : 13),
          ),
        ),
      ),
    );
  }
}

// 🔹 INTERACTIVE GLOSSY GRID ITEM
class _ModernGridItemWithFeedback extends StatefulWidget {
  final GridItem gridItem;
  final bool isDesktop;

  const _ModernGridItemWithFeedback({required this.gridItem, required this.isDesktop});

  @override
  State<_ModernGridItemWithFeedback> createState() => _ModernGridItemWithFeedbackState();
}

class _ModernGridItemWithFeedbackState extends State<_ModernGridItemWithFeedback> {
  bool _isPressed = false;

  // Function to handle navigation with a custom animated transition
  void _handleTap(BuildContext context, String label) {
    // 1. Temporarily show press feedback
    setState(() => _isPressed = true);

    // 2. Navigate after a short delay to allow the animation to show
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() => _isPressed = false); // Release press state

      // Navigate to a placeholder screen with a Fade/Slide transition
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500), // Slightly longer for smoother Hero
          pageBuilder: (context, animation, secondaryAnimation) => _PlaceholderDetailScreen(
            title: label,
            tag: label, // Pass the tag for Hero
            color: widget.gridItem.color, // Pass the color for consistency
            iconData: widget.gridItem.icon, // Pass the icon data for the Hero
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Page slides up from bottom
            const end = Offset.zero;
            const curve = Curves.easeOutCubic; // More dramatic curve for page transition

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation, // Add a fade effect
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.gridItem.color;
    final iconContainerSize = widget.isDesktop ? 55.0 : 50.0;
    final padding = widget.isDesktop ? 18.0 : 15.0;
    final borderRadius = widget.isDesktop ? 18.0 : 16.0;

    return GestureDetector(
      // Using GestureDetector for fine-grained control over press state
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => _handleTap(context, widget.gridItem.label), // Call navigation on tap up
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150), // Increased duration for smoother press effect
        curve: Curves.easeOut,
        // ENHANCED PRESS ANIMATION: Subtle 3D-like shrink and opacity adjustment
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.96 : 1.0)
          ..translate(0.0, _isPressed ? 1.0 : 0.0), // Slight downward shift
        decoration: BoxDecoration(
          color: ModernColors.darkSurface.withOpacity(_isPressed ? 0.8 : 0.6), // Darker when pressed
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: color.withOpacity(_isPressed ? 0.8 : 0.4), width: _isPressed ? 2.5 : 1.5), // Accent border highlights
          // INNER SHADOW/GRADIENT
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ModernColors.darkSurface.withOpacity(_isPressed ? 0.75 : 0.6), ModernColors.darkSurface.withOpacity(_isPressed ? 0.95 : 0.8)], stops: const [0.0, 1.0]),

          // Outer Shadow for elevation
          boxShadow: [
            // Darker shadow for depth
            BoxShadow(color: Colors.black.withOpacity(_isPressed ? 0.8 : 0.5), blurRadius: 25, spreadRadius: 2, offset: Offset(_isPressed ? 1 : 4, _isPressed ? 1 : 4)),
            // Accent color glow shadow (subtle)
            BoxShadow(color: color.withOpacity(_isPressed ? 0.3 : 0.15), blurRadius: 10, spreadRadius: 1, offset: const Offset(-2, -2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon with Gradient Background and HERO
                  Container(
                    width: iconContainerSize,
                    height: iconContainerSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, Color.lerp(color, ModernColors.electricBlue, 0.4)!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, offset: const Offset(2, 2))],
                    ),
                    child: Hero(
                      // 🌟 HERO WIDGET AROUND THE ICON
                      tag: widget.gridItem.label,
                      child: Icon(widget.gridItem.icon, size: widget.isDesktop ? 26 : 24, color: ModernColors.textLight),
                    ),
                  ),
                  SizedBox(height: widget.isDesktop ? 10 : 8),
                  // Grid Text Style (Inter) - assuming you decided on Inter from previous iterations
                  Text(
                    widget.gridItem.label.toUpperCase(), // Ensure uppercase
                    style: GoogleFonts.inter(fontSize: widget.isDesktop ? 15 : 13, fontWeight: FontWeight.w600, color: ModernColors.textLight, letterSpacing: 1.0),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: widget.isDesktop ? 4 : 2),
                  // Accent line
                  Container(
                    width: widget.isDesktop ? 25 : 20,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.5)]),
                      borderRadius: BorderRadius.circular(1),
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
}

// 🔹 Placeholder Screen for Navigation Demonstration
class _PlaceholderDetailScreen extends StatelessWidget {
  final String title;
  final String tag;
  final Color color;
  final IconData iconData; // Added iconData to receive the icon

  const _PlaceholderDetailScreen({
    required this.title,
    required this.tag,
    required this.color,
    required this.iconData, // Required in constructor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkSurface,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ModernColors.gradientStart, ModernColors.gradientEnd]),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🌟 HERO WIDGET HERE (Destination)
              Hero(
                tag: tag,
                child: Container(
                  width: 100, // Larger size for the destination icon container
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, Color.lerp(color, ModernColors.electricBlue, 0.4)!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: color.withOpacity(0.7), blurRadius: 15, offset: const Offset(4, 4))],
                  ),
                  child: Icon(iconData, size: 50, color: ModernColors.textLight), // 🌟 Use the actual iconData here
                ),
              ),
              const SizedBox(height: 30),
              Text('NAVIGATED TO', style: GoogleFonts.poppins(fontSize: 18, color: ModernColors.textMuted, letterSpacing: 2)),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold, color: ModernColors.neonCyan),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(backgroundColor: ModernColors.electricBlue, foregroundColor: ModernColors.textLight, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), textStyle: GoogleFonts.poppins(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Grid Items Data Class
class GridItem {
  final IconData icon;
  final String label;
  final Color color;

  const GridItem(this.icon, this.label, this.color);
}
