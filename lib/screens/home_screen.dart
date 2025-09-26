import 'dart:ui';

import 'package:calculators/screens/call_break_screen.dart';
import 'package:calculators/screens/game_history_screen.dart';
import 'package:calculators/screens/marriage_screen.dart';
import 'package:calculators/screens/rules_screen.dart';
import 'package:calculators/screens/settings_screen.dart';
import 'package:calculators/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
// -----------------------------------------------------------

// 🎨 Final Dark Theme Color Palette (Defined here for self-containment)
class ModernColors {
  // Simplified Gradient Background Colors
  static const Color gradientStart = Color(0xFF1E3C72); // Darker Blue (Near Top Left)
  static const Color gradientEnd = Color(0xFF2A5298); // Lighter Blue (Near Bottom Right)

  // Surface & Accent Colors
  static const Color darkSurface = Color(0xFF1A243F); // Card/Search background base
  static const Color neonCyan = Color(0xFF00FFFF); // Primary Accent (Vibrant)
  static const Color electricBlue = Color(0xFF0099FF); // Secondary Accent
  static const Color textLight = Color(0xFFE0E0E0); // Light Text
  static const Color textMuted = Color(0xFFA0A0CC); // Muted Text

  // Grid Accent Colors
  static const Color gridMarriage = Color(0xFF00E5FF);
  static const Color gridCallBreak = Color(0xFF3366FF);
  static const Color gridHistory = Color(0xFF9966FF);
  static const Color gridUsers = Color(0xFFFF9900);
  static const Color gridRules = Color(0xFF00FF99);
  static const Color gridSettings = Color(0xFFCCCCCC);
}

// ----------------------------------------------------
// Staggered Fade-In Animation for Grid Items
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

  // 🔹 MINIMALIST HEADER (No changes)
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

  // 🔹 Modern Search Bar (No changes)
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

  // 🌟 FINAL NAVIGATION LOGIC: Routes to your specific pages
  Widget _getDestinationScreen(String label, Color color, IconData iconData) {
    // This logic ensures the correct screen object is instantiated
    switch (label) {
      case "Marriage":
        return MarriageScreen(tag: label, color: color, iconData: iconData);
      case "Call Break":
        return CallBreakScreen(tag: label, color: color, iconData: iconData);
      case "Game History":
        return GameHistoryScreen(tag: label, color: color, iconData: iconData);
      case "Users":
        return UsersScreen(tag: label, color: color, iconData: iconData);
      case "Rules":
        return RulesScreen(tag: label, color: color, iconData: iconData);
      case "Settings":
        return SettingsScreen(tag: label, color: color, iconData: iconData);
      default:
        // Fallback in case of a missing screen file or label mismatch
        return Scaffold(
          body: Center(
            child: Text("Error: Screen not found for $label", style: GoogleFonts.poppins(color: Colors.red)),
          ),
        );
    }
  }

  // Function to handle navigation with a custom animated transition
  void _handleTap(BuildContext context, String label) {
    setState(() => _isPressed = true);

    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() => _isPressed = false);

      final destinationScreen = _getDestinationScreen(widget.gridItem.label, widget.gridItem.color, widget.gridItem.icon);

      // Navigate with Hero and Slide/Fade transition
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => destinationScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Page slides up from bottom
            const end = Offset.zero;
            const curve = Curves.easeOutCubic; // Smooth, dramatic curve

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation, // Added fade for a smoother entrance
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
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => _handleTap(context, widget.gridItem.label),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        // ENHANCED PRESS ANIMATION
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.96 : 1.0)
          ..translate(0.0, _isPressed ? 1.0 : 0.0),
        decoration: BoxDecoration(
          color: ModernColors.darkSurface.withOpacity(_isPressed ? 0.8 : 0.6),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: color.withOpacity(_isPressed ? 0.8 : 0.4), width: _isPressed ? 2.5 : 1.5),
          // INNER SHADOW/GRADIENT
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ModernColors.darkSurface.withOpacity(_isPressed ? 0.75 : 0.6), ModernColors.darkSurface.withOpacity(_isPressed ? 0.95 : 0.8)], stops: const [0.0, 1.0]),

          // Outer Shadow for elevation
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(_isPressed ? 0.8 : 0.5), blurRadius: 25, spreadRadius: 2, offset: Offset(_isPressed ? 1 : 4, _isPressed ? 1 : 4)),
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
                  // Icon with Gradient Background and HERO Source
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
                  // Grid Text Style
                  Text(
                    widget.gridItem.label.toString(),
                    style: GoogleFonts.inter(fontSize: widget.isDesktop ? 17 : 13, fontWeight: FontWeight.w600, color: ModernColors.textLight, letterSpacing: 1.0),
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

// 🔹 Grid Items Data Class
class GridItem {
  final IconData icon;
  final String label;
  final Color color;

  const GridItem(this.icon, this.label, this.color);
}
