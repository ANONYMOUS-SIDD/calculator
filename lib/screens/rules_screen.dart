import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/moder_app_bar.dart';

class ModernColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color onSurface = Color(0xFF1E293B);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}

class RulesScreen extends StatefulWidget {
  final String tag;
  final Color color;
  final IconData iconData;

  const RulesScreen({super.key, required this.tag, required this.color, required this.iconData});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  final Map<String, bool> _expandedSections = {};
  final Map<String, bool> _expandedSubSections = {};

  void _toggleSection(String key) {
    setState(() {
      _expandedSections[key] = !(_expandedSections[key] ?? false);
    });
  }

  void _toggleSubSection(String key) {
    setState(() {
      _expandedSubSections[key] = !(_expandedSubSections[key] ?? false);
    });
  }

  Widget _buildGameSection({required String sectionKey, required String title, required IconData icon, required Color primaryColor, required Color secondaryColor, required List<Map<String, dynamic>> subsections}) {
    final isExpanded = _expandedSections[sectionKey] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _toggleSection(sectionKey),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryColor.withOpacity(0.8), width: 1.5),
                        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Icon(icon, size: 18, color: primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: primaryColor.darken(0.3),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${subsections.length} sections',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: primaryColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Section count badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(
                        '${subsections.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: isExpanded ? 0.5 : 0,
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(color: Colors.grey.shade200, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: subsections.map((subsection) => _buildSubSection(
                  sectionKey: sectionKey,
                  subsectionKey: subsection['key'],
                  title: subsection['title'],
                  icon: subsection['icon'],
                  description: subsection['description'],
                  points: subsection['points'],
                  gradientColors: subsection['colors'],
                  primaryColor: primaryColor,
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubSection({required String sectionKey, required String subsectionKey, required String title, required IconData icon, required String description, required List<String> points, required List<Color> gradientColors, required Color primaryColor}) {
    final key = '$sectionKey-$subsectionKey';
    final isExpanded = _expandedSubSections[key] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: gradientColors.first.withOpacity(0.2), blurRadius: 4, spreadRadius: 0.3, offset: const Offset(0, 1))],
      ),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _toggleSubSection(key),
                borderRadius: BorderRadius.circular(9),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: gradientColors.first.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
                        ),
                        child: Icon(icon, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${points.length} points',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Point count badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6)
                        ),
                        child: Text(
                          '${points.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: isExpanded ? 0.5 : 0,
                        child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isExpanded) ...[
              Divider(color: Colors.grey.shade100, height: 1, indent: 10, endIndent: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: gradientColors.first.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: gradientColors.first.withOpacity(0.15), width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 14, color: gradientColors.first),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              description,
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                  color: Colors.grey.shade800
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (points.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...points.asMap().entries.map(
                            (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: gradientColors),
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: gradientColors.first.withOpacity(0.3), blurRadius: 3, offset: const Offset(0, 1))],
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                    entry.value,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      color: Colors.grey.shade700,
                                      height: 1.4,
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive calculations
    final bool isSmallScreen = screenWidth < 360;
    final bool isLargeScreen = screenWidth > 600;
    final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final double containerPadding = isSmallScreen ? 6.0 : 8.0;
    final double sectionPadding = isSmallScreen ? 10.0 : 12.0;
    final double titleFontSize = isSmallScreen ? 14.0 : isLargeScreen ? 18.0 : 16.0;
    final double iconSize = isSmallScreen ? 16.0 : 18.0;
    final double smallIconSize = isSmallScreen ? 14.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: ModernAppBar(title: "User Manual"),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(horizontalPadding),
          children: [
            // Main iOS Style Container
            Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // First iOS Container - Game Sections
                  Container(
                    margin: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.all(containerPadding),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            // Marriage Game Section
                            _buildGameSection(
                              sectionKey: 'marriage',
                              title: 'Marriage Game',
                              icon: Icons.favorite_rounded,
                              primaryColor: Colors.pink,
                              secondaryColor: Colors.redAccent,
                              subsections: [
                                {
                                  'key': 'setup',
                                  'title': 'Game Setup',
                                  'icon': Icons.settings_outlined,
                                  'description': 'Configure your Marriage game session with the right players and settings.',
                                  'points': ['Select between 3 to 6 players for your game', 'Set the per-point value for amount calculation', 'Choose from recent players or add new ones', 'Search existing players using the search function'],
                                  'colors': [Colors.purple.shade400, Colors.blue.shade600],
                                },
                                {
                                  'key': 'selection',
                                  'title': 'Player Selection',
                                  'icon': Icons.people_outline,
                                  'description': 'Quickly access and manage your player list for seamless game setup.',
                                  'points': ['Tap "Select Player" button to open player list', 'View recently played players at the top', 'Search for existing players by name', 'Add new players instantly with the add button'],
                                  'colors': [Colors.green.shade400, Colors.teal.shade400],
                                },
                                {
                                  'key': 'gameplay',
                                  'title': 'Gameplay Modes',
                                  'icon': Icons.remove_red_eye_outlined,
                                  'description': 'Track different game modes and combinations for each player during the match.',
                                  'points': ['Blind Mode: Player hasn\'t seen their maal cards', 'Seen Mode: Player has viewed their maal cards (input value)', 'Win Mode: Mark the player who won the match', 'Toggle Dublee (double) and Sequence combinations'],
                                  'colors': [Colors.orange.shade400, Colors.red.shade400],
                                },
                                {
                                  'key': 'calculate',
                                  'title': 'Calculate Results',
                                  'icon': Icons.calculate_outlined,
                                  'description': 'View comprehensive results with detailed breakdown of points and amounts.',
                                  'points': ['Click "Calculate" button to generate results table', 'Player section shows names, modes, and points', 'Points section displays wins (green) and losses (red)', 'Amount section shows money earned or lost'],
                                  'colors': [Colors.purple.shade400, Colors.pink.shade400],
                                },
                                {
                                  'key': 'save',
                                  'title': 'Save History',
                                  'icon': Icons.save_outlined,
                                  'description': 'Preserve your match data and start a new game session.',
                                  'points': ['Click "New Game" button at the bottom', 'A confirmation dialog will appear', 'Confirm to save match to history', 'History is only saved when you confirm'],
                                  'colors': [Colors.red.shade400, Colors.orange.shade400],
                                },
                              ],
                            ),

                            // Call Break Section
                            _buildGameSection(
                              sectionKey: 'callbreak',
                              title: 'Call Break Game',
                              icon: Icons.control_camera_rounded,
                              primaryColor: Colors.blue,
                              secondaryColor: Colors.purpleAccent,
                              subsections: [
                                {
                                  'key': 'init',
                                  'title': 'Initialize Game',
                                  'icon': Icons.play_circle_outline,
                                  'description': 'Set up your Call Break game with exactly 4 players.',
                                  'points': ['Tap the floating action button (FAB)', 'Select 4 players from existing database', 'Add new players if needed', 'All 4 players will be displayed on screen'],
                                  'colors': [Colors.blue.shade400, Colors.purple.shade400],
                                },
                                {
                                  'key': 'bidding',
                                  'title': 'Bidding Phase',
                                  'icon': Icons.format_list_numbered_rounded,
                                  'description': 'Set bids for each player at the start of every round.',
                                  'points': ['Click "Start Round 1" to begin first round', 'Select bid amount for each player', 'Confirm bids to display in table', 'Repeat for all 5 rounds'],
                                  'colors': [Colors.green.shade400, Colors.teal.shade400],
                                },
                                {
                                  'key': 'ot',
                                  'title': 'OT System',
                                  'icon': Icons.add_circle_outline,
                                  'description': 'Manage overtricks and undertricks after completing each round.',
                                  'points': ['Click "Finish Round" after round completion', 'OT buttons become active', 'Golo: Player failed to complete their bid', 'Tight: No extra tricks obtained', 'Numbers: Select extra tricks and confirm'],
                                  'colors': [Colors.orange.shade400, Colors.red.shade400],
                                },
                                {
                                  'key': 'edit',
                                  'title': 'Edit Bids',
                                  'icon': Icons.edit_outlined,
                                  'description': 'Correct mistakes by editing bids in the table.',
                                  'points': ['Long press on any bid in the table', 'Edit dialog will appear', 'Modify the bid value', 'Works for current and completed rounds'],
                                  'colors': [Colors.purple.shade400, Colors.pink.shade400],
                                },
                                {
                                  'key': 'complete',
                                  'title': 'Complete Game',
                                  'icon': Icons.check_circle_outline,
                                  'description': 'Finish all rounds and save the match history.',
                                  'points': ['Complete all 5 rounds with proper scoring', 'Table displays detailed values for each player', 'Click "New Game" to save match', 'Confirm to preserve history and start fresh'],
                                  'colors': [Colors.red.shade400, Colors.orange.shade400],
                                },
                              ],
                            ),

                            // Game History Section
                            _buildGameSection(
                              sectionKey: 'history',
                              title: 'Game History',
                              icon: Icons.history_rounded,
                              primaryColor: Colors.green,
                              secondaryColor: Colors.teal,
                              subsections: [
                                {
                                  'key': 'records',
                                  'title': 'View Records',
                                  'icon': Icons.list_alt_rounded,
                                  'description': 'Access your complete gaming history for both game types.',
                                  'points': ['Click on Game History section from home', 'View all Marriage and Call Break matches', 'Matches are sorted by date', 'Recent matches appear at the top'],
                                  'colors': [Colors.blue.shade400, Colors.purple.shade400],
                                },
                                {
                                  'key': 'details',
                                  'title': 'Match Details',
                                  'icon': Icons.visibility_outlined,
                                  'description': 'Dive deep into individual match statistics and performance.',
                                  'points': ['Tap on any match card to open details', 'View comprehensive player scores', 'See game modes and settings used', 'Analyze detailed statistics and breakdowns'],
                                  'colors': [Colors.green.shade400, Colors.teal.shade400],
                                },
                                {
                                  'key': 'search',
                                  'title': 'Quick Search',
                                  'icon': Icons.search_rounded,
                                  'description': 'Find players quickly using the search functionality.',
                                  'points': ['Click search bar on home screen', 'Type player name to search', 'View player profile from results', 'Access player statistics instantly'],
                                  'colors': [Colors.orange.shade400, Colors.red.shade400],
                                },
                              ],
                            ),

                            // Player Management Section
                            _buildGameSection(
                              sectionKey: 'players',
                              title: 'Player Management',
                              icon: Icons.people_alt_rounded,
                              primaryColor: Colors.purple,
                              secondaryColor: Colors.deepPurple,
                              subsections: [
                                {
                                  'key': 'add',
                                  'title': 'Add New Players',
                                  'icon': Icons.person_add_outlined,
                                  'description': 'Create new player profiles in your database.',
                                  'points': ['Navigate to Users screen', 'Tap floating action button (FAB)', 'Enter player name and details', 'Save to add player to database'],
                                  'colors': [Colors.blue.shade400, Colors.purple.shade400],
                                },
                                {
                                  'key': 'editplayer',
                                  'title': 'Edit Profiles',
                                  'icon': Icons.edit_note_rounded,
                                  'description': 'Modify existing player information and details.',
                                  'points': ['Long press on any player card', 'Edit dialog will appear', 'Modify player name or details', 'Save changes to update database'],
                                  'colors': [Colors.green.shade400, Colors.teal.shade400],
                                },
                                {
                                  'key': 'stats',
                                  'title': 'View Statistics',
                                  'icon': Icons.analytics_outlined,
                                  'description': 'Analyze player performance with detailed statistics.',
                                  'points': ['Click "Detail" button on player card', 'View today\'s matches by default', 'See Marriage and Call Break stats', 'Analyze win rates and performance'],
                                  'colors': [Colors.orange.shade400, Colors.red.shade400],
                                },
                                {
                                  'key': 'datefilter',
                                  'title': 'Date Range Filter',
                                  'icon': Icons.date_range_outlined,
                                  'description': 'Filter player statistics by custom date ranges.',
                                  'points': ['Long press on start date in calendar', 'Long press on end date to complete range', 'Click confirm to apply filter', 'View stats for selected period'],
                                  'colors': [Colors.purple.shade400, Colors.pink.shade400],
                                },
                                {
                                  'key': 'reset',
                                  'title': 'Reset Filters',
                                  'icon': Icons.refresh_rounded,
                                  'description': 'Clear date filters to view all-time statistics.',
                                  'points': ['Click reset button in stats dialog', 'Date filter will be cleared', 'View returns to default (today)', 'All-time stats become visible'],
                                  'colors': [Colors.red.shade400, Colors.orange.shade400],
                                },
                              ],
                            ),

                            // Pro Tips Section
                            _buildGameSection(
                              sectionKey: 'tips',
                              title: 'Pro Tips',
                              icon: Icons.lightbulb_outline_rounded,
                              primaryColor: Colors.indigo,
                              secondaryColor: Colors.blueAccent,
                              subsections: [
                                {
                                  'key': 'save',
                                  'title': 'Save Regularly',
                                  'icon': Icons.backup_outlined,
                                  'description': 'Always preserve your match data before starting new games.',
                                  'points': ['Use "New Game" button to save matches', 'History is only saved upon confirmation', 'Don\'t exit without saving', 'Regular saves prevent data loss'],
                                  'colors': [Colors.indigo.shade400, Colors.blueAccent.shade400],
                                },
                                {
                                  'key': 'bidding',
                                  'title': 'Smart Bidding',
                                  'icon': Icons.psychology_outlined,
                                  'description': 'Improve your Call Break strategy with smart bidding techniques.',
                                  'points': ['Analyze your hand strength carefully', 'Consider trump cards before bidding', 'Don\'t overbid with weak hands', 'Track opponents\' bidding patterns'],
                                  'colors': [Colors.indigo.shade400, Colors.blue.shade600],
                                },
                                {
                                  'key': 'longpress',
                                  'title': 'Long Press Actions',
                                  'icon': Icons.touch_app_outlined,
                                  'description': 'Master long press gestures for quick access to edit options.',
                                  'points': ['Long press on player cards to edit', 'Long press on bids to modify values', 'Long press on dates for range selection', 'Look for long press hints throughout app'],
                                  'colors': [Colors.blueAccent.shade400, Colors.indigo.shade600],
                                },
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Second iOS Container - Support Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: isSmallScreen ? 40.0 : 44.0,
                              height: isSmallScreen ? 40.0 : 44.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.deepOrange.withOpacity(0.8), width: 2),
                                boxShadow: [BoxShadow(color: Colors.deepOrange.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.orange.shade700, Colors.red.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                    Icons.support_agent_rounded,
                                    size: isSmallScreen ? 20.0 : 22.0,
                                    color: Colors.white
                                ),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                            Text(
                              'Need Help?',
                              style: GoogleFonts.quicksand(
                                  fontSize: isSmallScreen ? 14.0 : 16.0,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blue.shade900
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 2.0 : 4.0),
                            Text(
                              'We\'re here to assist you',
                              style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 10.0 : 11.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 10.0 : 12.0,
                                  vertical: isSmallScreen ? 8.0 : 10.0
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                          Icons.email_outlined,
                                          color: Colors.blue.shade800,
                                          size: isSmallScreen ? 12.0 : 14.0
                                      ),
                                      SizedBox(width: isSmallScreen ? 4.0 : 6.0),
                                      Flexible(
                                        child: SelectableText(
                                          'siddhanttimalsina2007@gmail.com',
                                          style: GoogleFonts.poppins(
                                              fontSize: isSmallScreen ? 9.0 : 10.0,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade800
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? 4.0 : 6.0),
                                  Text(
                                    'Tap to select and copy',
                                    style: GoogleFonts.poppins(
                                        fontSize: isSmallScreen ? 8.0 : 9.0,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                            Divider(color: Colors.grey.shade200, height: 1),
                            SizedBox(height: isSmallScreen ? 8.0 : 10.0),
                            Text(
                              '© 2024 All Rights Reserved',
                              style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 9.0 : 10.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade700
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 1.0 : 2.0),
                            Text(
                              'Developed by Siddhant Timalsina',
                              style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 8.0 : 9.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isSmallScreen ? 12.0 : 16.0),
          ],
        ),
      ),
    );
  }
}

// Extension to darken a color slightly since it's not a standard Color method
extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}