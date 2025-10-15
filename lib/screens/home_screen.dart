import 'package:calculators/screens/call_break_screen.dart';
import 'package:calculators/screens/game_history_screen.dart';
import 'package:calculators/screens/marriage_screen.dart';
import 'package:calculators/screens/rules_screen.dart';
import 'package:calculators/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// -----------------------------------------------------------------------------
// 1. Grid Item Model
// -----------------------------------------------------------------------------

class GridItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color gradientStart;
  final Color gradientEnd;

  const GridItem(
      this.icon,
      this.label,
      this.color, {
        Color? gradientStart,
        Color? gradientEnd,
      })  : gradientStart = gradientStart ?? color,
        gradientEnd = gradientEnd ?? color;
}

// -----------------------------------------------------------------------------
// 2. Modern App Bar (EXACTLY AS YOU PROVIDED)
// -----------------------------------------------------------------------------

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ModernAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 20.0,
          color: Colors.black87,
        ),
      ),
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 0.0,
      toolbarHeight: 60.0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

// -----------------------------------------------------------------------------
// 3. Main HomeScreen (Stateful)
// -----------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchText = '';
  List<GridItem> _filteredItems = [];

  // All available grid items with enhanced gradient colors and better icons
  final List<GridItem> _allGridItems = [
    GridItem(
      Icons.favorite_border_rounded,
      "Marriage",
      Color(0xFFEC4899),
      gradientStart: Color(0xFFEC4899),
      gradientEnd: Color(0xFFF59E0B),
    ),
    GridItem(
      Icons.leaderboard_outlined,
      "Call Break",
      Color(0xFF3B82F6),
      gradientStart: Color(0xFF3B82F6),
      gradientEnd: Color(0xFF06B6D4),
    ),
    GridItem(
      Icons.history_rounded,
      "History",
      Color(0xFF8B5CF6),
      gradientStart: Color(0xFF8B5CF6),
      gradientEnd: Color(0xFFEC4899),
    ),
    GridItem(
      Icons.people_outline_rounded,
      "Users",
      Color(0xFFF59E0B),
      gradientStart: Color(0xFFF59E0B),
      gradientEnd: Color(0xFFEF4444),
    ),
    GridItem(
      Icons.menu_book_outlined,
      "Manual",
      Color(0xFF10B981),
      gradientStart: Color(0xFF10B981),
      gradientEnd: Color(0xFF3B82F6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allGridItems;
  }

  // Determine the correct greeting based on time
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

  // Filter the grid items based on the search query
  void _filterItems(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _searchText = query;
      if (query.isEmpty) {
        _filteredItems = _allGridItems;
      } else {
        _filteredItems = _allGridItems
            .where((item) =>
            item.label.toLowerCase().contains(lowerCaseQuery))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768;
    final isDesktop = size.width >= 1024;

    final isSearching = _searchText.isNotEmpty;

    // Separate the first 4 items for the grid and the 5th for full width
    final List<GridItem> gridItems = isSearching ? _filteredItems : (_filteredItems.length > 4 ? _filteredItems.sublist(0, 4) : _filteredItems);
    final GridItem? fullWidthItem = isSearching || _filteredItems.length <= 4 ? null : _filteredItems[4];

    return Scaffold(
      // USING YOUR EXACT APP BAR WITH "Marriage" TITLE
      appBar: ModernAppBar(title: "Marriage"),
      backgroundColor: Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Search Bar Section
            _buildModernSearchSection(isDesktop, isTablet),

            // Horizontal Divider between Search Bar and Container
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : isTablet ? 20.0 : 16.0),
              child: Divider(
                color: Colors.grey.shade300,
                height: 1.0,
                thickness: 1.0,
              ),
            ),

            // Main Content Container with enhanced elevation
            Expanded(
              child: Container(
                margin: EdgeInsets.all(isDesktop ? 24.0 : isTablet ? 20.0 : 16.0),
                padding: EdgeInsets.all(isDesktop ? 20.0 : isTablet ? 18.0 : 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 32.0,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _filteredItems.isEmpty && fullWidthItem == null
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: isDesktop ? 72.0 : isTablet ? 64.0 : 56.0,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: isDesktop ? 20.0 : 16.0),
                      Text(
                        "No results found for '$_searchText'",
                        style: GoogleFonts.quicksand(
                          color: Colors.grey.shade600,
                          fontSize: isDesktop ? 18.0 : isTablet ? 16.0 : 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Grid Items (responsive layout)
                    if (gridItems.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 3 : isTablet ? 3 : 2,
                          crossAxisSpacing: isDesktop ? 20.0 : isTablet ? 18.0 : 16.0,
                          mainAxisSpacing: isDesktop ? 20.0 : isTablet ? 18.0 : 16.0,
                          childAspectRatio: isDesktop ? 0.9 : isTablet ? 0.95 : 1.0,
                        ),
                        itemCount: gridItems.length,
                        itemBuilder: (context, index) => _ModernGridItem(
                          gridItem: gridItems[index],
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                        ),
                      ),

                    // Full Width Manual Card
                    if (fullWidthItem != null) ...[
                      SizedBox(height: isDesktop ? 24.0 : isTablet ? 20.0 : 16.0),
                      _ModernManualCard(
                        gridItem: fullWidthItem,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSearchSection(bool isDesktop, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? 20.0 : isTablet ? 18.0 : 16.0),
      child: Container(
        height: isDesktop ? 58.0 : isTablet ? 54.0 : 50.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF667EEA).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: _filterItems,
          decoration: InputDecoration(
            hintText: "Search player",
            hintStyle: GoogleFonts.quicksand(
              color: Colors.grey.shade500,
              fontSize: isDesktop ? 16.0 : isTablet ? 15.0 : 14.0,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: isDesktop ? 22.0 : isTablet ? 21.0 : 20.0,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: isDesktop ? 16.0 : isTablet ? 14.0 : 12.0,
              horizontal: 20.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: Color(0xFF667EEA),
                width: 2.0,
              ),
            ),
          ),
          style: GoogleFonts.quicksand(
            color: Colors.black87,
            fontSize: isDesktop ? 16.0 : isTablet ? 15.0 : 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. Modern Grid Item (Responsive cards)
// -----------------------------------------------------------------------------

class _ModernGridItem extends StatefulWidget {
  final GridItem gridItem;
  final bool isDesktop;
  final bool isTablet;

  const _ModernGridItem({
    required this.gridItem,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  State<_ModernGridItem> createState() => _ModernGridItemState();
}

class _ModernGridItemState extends State<_ModernGridItem> {
  bool _isHovering = false;
  bool _isPressed = false;

  Widget _getDestinationScreen(String label, Color color, IconData iconData) {
    switch (label) {
      case "Marriage":
        return MarriageScreen(tag: label, color: color, iconData: iconData);
      case "Call Break":
        return CallBreakScreen(tag: label, color: color, iconData: iconData);
      case "History":
        return GameHistoryScreen(tag: label, color: color, iconData: iconData);
      case "Users":
        return UsersScreen(tag: label, color: color, iconData: iconData);
      case "Manual":
        return RulesScreen(tag: label, color: color, iconData: iconData);
      default:
        return Scaffold(
          body: Center(
            child: Text(
              "Error: Screen not found for $label",
              style: GoogleFonts.quicksand(color: Colors.red),
            ),
          ),
        );
    }
  }

  void _handleTap(BuildContext context) {
    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() => _isPressed = false);
      final destinationScreen = _getDestinationScreen(
        widget.gridItem.label,
        widget.gridItem.color,
        widget.gridItem.icon,
      );
      Get.to(
            () => destinationScreen,
        transition: Transition.cupertino,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.isDesktop ? 36.0 : widget.isTablet ? 34.0 : 32.0;
    final containerSize = widget.isDesktop ? 80.0 : widget.isTablet ? 75.0 : 70.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => _handleTap(context),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.95 : (_isHovering ? 1.02 : 1.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.gridItem.gradientStart,
                widget.gridItem.gradientEnd,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gridItem.color.withOpacity(0.4),
                blurRadius: _isHovering ? 30 : 20,
                offset: Offset(0, _isHovering ? 15 : 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Glow Effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content - Centered
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced Icon Container with Better Gradient
                      Container(
                        width: containerSize,
                        height: containerSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.8),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                            stops: [0.0, 0.6, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.9),
                              blurRadius: 20,
                              offset: Offset(-6, -6),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              offset: Offset(6, 6),
                            ),
                            BoxShadow(
                              color: widget.gridItem.color.withOpacity(0.4),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Hero(
                            tag: widget.gridItem.label,
                            child: Icon(
                              widget.gridItem.icon,
                              size: iconSize,
                              color: widget.gridItem.color,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: widget.isDesktop ? 16.0 : 12.0),

                      // Text Label with Quicksand font - Centered
                      Text(
                        widget.gridItem.label,
                        style: GoogleFonts.quicksand(
                          fontSize: widget.isDesktop ? 15.0 : widget.isTablet ? 14.0 : 13.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. Modern Manual Card (Full Width)
// -----------------------------------------------------------------------------

class _ModernManualCard extends StatefulWidget {
  final GridItem gridItem;
  final bool isDesktop;
  final bool isTablet;

  const _ModernManualCard({
    required this.gridItem,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  State<_ModernManualCard> createState() => _ModernManualCardState();
}

class _ModernManualCardState extends State<_ModernManualCard> {
  bool _isHovering = false;
  bool _isPressed = false;

  Widget _getDestinationScreen(String label, Color color, IconData iconData) {
    return RulesScreen(tag: label, color: color, iconData: iconData);
  }

  void _handleTap(BuildContext context) {
    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() => _isPressed = false);
      final destinationScreen = _getDestinationScreen(
        widget.gridItem.label,
        widget.gridItem.color,
        widget.gridItem.icon,
      );
      Get.to(
            () => destinationScreen,
        transition: Transition.cupertino,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.isDesktop ? 130.0 : widget.isTablet ? 125.0 : 120.0;
    final iconSize = widget.isDesktop ? 34.0 : widget.isTablet ? 32.0 : 30.0;
    final containerSize = widget.isDesktop ? 75.0 : widget.isTablet ? 70.0 : 65.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => _handleTap(context),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.98 : (_isHovering ? 1.01 : 1.0)),
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.gridItem.gradientStart,
                widget.gridItem.gradientEnd,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gridItem.color.withOpacity(0.5),
                blurRadius: _isHovering ? 35 : 25,
                offset: Offset(0, _isHovering ? 18 : 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Glow Effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: RadialGradient(
                      center: Alignment.centerRight,
                      radius: 1.2,
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content - Centered vertically
              Padding(
                padding: EdgeInsets.all(widget.isDesktop ? 24.0 : widget.isTablet ? 22.0 : 20.0),
                child: Row(
                  children: [
                    // Enhanced Icon Container with Better Gradient
                    Container(
                      width: containerSize,
                      height: containerSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0.2),
                          ],
                          stops: [0.0, 0.7, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 25,
                            offset: Offset(-8, -8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(8, 8),
                          ),
                          BoxShadow(
                            color: widget.gridItem.color.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Hero(
                          tag: widget.gridItem.label,
                          child: Icon(
                            widget.gridItem.icon,
                            size: iconSize,
                            color: widget.gridItem.color,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: widget.isDesktop ? 20.0 : 16.0),

                    // Text Content - Centered vertically
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.gridItem.label,
                            style: GoogleFonts.quicksand(
                              fontSize: widget.isDesktop ? 22.0 : widget.isTablet ? 20.0 : 18.0,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(height: widget.isDesktop ? 6.0 : 4.0),
                          // Removed "& guides" as requested
                          Text(
                            "Complete game rules",
                            style: GoogleFonts.quicksand(
                              fontSize: widget.isDesktop ? 14.0 : widget.isTablet ? 13.0 : 12.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon with Glow
                    Container(
                      padding: EdgeInsets.all(widget.isDesktop ? 10.0 : 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: widget.isDesktop ? 20.0 : 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}