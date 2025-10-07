// lib/main.dart (Updated - Preserves History)

// Required for PlayerController setup
import 'package:calculators/controllers/player_controller.dart';
// ADD THESE IMPORTS
import 'package:calculators/model/game_history_models.dart';
import 'package:calculators/model/user_model.dart';
import 'package:calculators/repositories/history_repository.dart';
import 'package:calculators/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // 1. Ensure Flutter framework is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Start the application with the initialization wrapper
  runApp(const AppInitializationWidget());
}

// -------------------------------------------------------------
// WIDGET TO HANDLE ASYNCHRONOUS INITIALIZATION (CRITICAL FOR HIVE & GETX)
// -------------------------------------------------------------
class AppInitializationWidget extends StatelessWidget {
  const AppInitializationWidget({super.key});

  // Function to encapsulate all setup that must complete before the app runs
  Future<void> _initialize() async {
    try {
      // 1. Initialize Hive Flutter and Register Adapters
      await Hive.initFlutter();

      // Register existing User adapter
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserAdapter());
      }

      // REGISTER NEW HISTORY ADAPTERS - ADD THESE LINES
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CallBreakGameHistoryAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(PlayerOverallStatsAdapter());
      }
      // ADD THIS NEW ADAPTER REGISTRATION
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(RoundHistoryDataAdapter());
      }

      // 2. SMART DATA MIGRATION - Only clear if there's a schema conflict
      await _handleDataMigration();

      // 3. Open the critical boxes - ADD THE NEW BOXES
      await Hive.openBox<User>('usersBox');
      await Hive.openBox('callBreakGames');
      await Hive.openBox<CallBreakGameHistory>('callBreakGameHistory'); // ADD THIS
      await Hive.openBox<PlayerOverallStats>('playerStats'); // ADD THIS

      // 4. INITIALIZE HISTORY REPOSITORY - ADD THIS LINE
      await HistoryRepository.init();

      final userBox = Hive.box<User>('usersBox');
      const int defaultPlayerCount = 4; // Target game size

      // 5. Initial data check: Ensure we have enough users to start a game
      if (userBox.isEmpty) {
        // Add default users if the box is completely empty
        for (int i = 1; i <= defaultPlayerCount; i++) {
          // Creating the default users
          userBox.add(User(username: 'Guest Player $i', profileImagePath: null, wins: 0, rank: i));
        }
      }

      // Initialize the PlayerController
      Get.put(PlayerController());
    } catch (e) {
      debugPrint('CRITICAL ERROR during initialization: $e');
      // If there's still an error, try one more time with clean data
      await _forceCleanStart();
    }
  }

  // Smart data migration - only clears data if there's a schema conflict
  Future<void> _handleDataMigration() async {
    try {
      // Try to open boxes normally first
      await Hive.openBox<CallBreakGameHistory>('callBreakGameHistory');
      await Hive.openBox<PlayerOverallStats>('playerStats');
      debugPrint('✅ Existing data loaded successfully');
    } catch (e) {
      // If there's an error, it's likely a schema conflict - clear and retry
      debugPrint('🔄 Schema conflict detected, clearing old data: $e');
      try {
        await Hive.deleteBoxFromDisk('callBreakGameHistory');
        await Hive.deleteBoxFromDisk('playerStats');
        debugPrint('✅ Cleared incompatible old data');
      } catch (deleteError) {
        debugPrint('ℹ️ No boxes to delete or error deleting: $deleteError');
      }
    }
  }

  // Force clean start as last resort
  Future<void> _forceCleanStart() async {
    debugPrint('🔄 Attempting force clean start...');
    try {
      await Hive.deleteBoxFromDisk('callBreakGameHistory');
      await Hive.deleteBoxFromDisk('playerStats');
      await Hive.openBox<CallBreakGameHistory>('callBreakGameHistory');
      await Hive.openBox<PlayerOverallStats>('playerStats');
      debugPrint('✅ Force clean start completed');
    } catch (e) {
      debugPrint('❌ Even force clean start failed: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialize(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      'App failed to load',
                      style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(fontSize: 14, color: Colors.red.shade300),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Restart the app
                        runApp(const AppInitializationWidget());
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              backgroundColor: Color(0xFF1A243F),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 20),
                    Text('Loading Calculator App...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
          );
        }

        return const MyApp();
      },
    );
  }
}

// -------------------------------------------------------------
// YOUR EXISTING MYAPP WIDGET
// -------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator App',
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue, scaffoldBackgroundColor: const Color(0xFF1A243F)),
      home: const SplashScreen(),
    );
  }
}
