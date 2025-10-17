// Core Flutter imports
// Controller imports
import 'package:calculators/controllers/player_controller.dart';
import 'package:calculators/controllers/user_list_controller.dart';
import 'package:calculators/model/game_history_models.dart';
import 'package:calculators/model/marriage_game_history.dart';
// Model imports
import 'package:calculators/model/user_model.dart';
// Repository imports
import 'package:calculators/repositories/history_repository.dart';
// Screen imports
import 'package:calculators/screens/splash_screen.dart';
import 'package:flutter/material.dart';
// State management imports
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// Local storage imports
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  /// Ensure Flutter framework is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  /// Start the application with the initialization wrapper
  runApp(const AppInitializationWidget());
}

/// Widget to handle asynchronous initialization for Hive & GetX
/// This ensures all dependencies are properly set up before app starts
class AppInitializationWidget extends StatelessWidget {
  const AppInitializationWidget({super.key});

  /// Initialize all application dependencies including:
  /// - Hive database setup and adapter registration
  /// - Data migration handling
  /// - Controller initialization
  /// - Repository setup
  Future<void> _initialize() async {
    try {
      // Initialize Hive Flutter
      await Hive.initFlutter();

      // Register Hive adapters for data persistence
      _registerHiveAdapters();

      // Handle data migration for schema changes
      await _handleDataMigration();

      // Open all required Hive boxes
      await _openHiveBoxes();

      // Initialize history repository
      await HistoryRepository.init();

      // Initialize application controllers
      _initializeControllers();
    } catch (e) {
      // If initialization fails, attempt clean start
      await _forceCleanStart();
    }
  }

  /// Register all Hive type adapters for data serialization
  void _registerHiveAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CallBreakGameHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PlayerOverallStatsAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(RoundHistoryDataAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(MarriageGameHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(MarriagePlayerHistoryAdapter());
    }
  }

  /// Open all required Hive boxes for data storage
  Future<void> _openHiveBoxes() async {
    await Hive.openBox<User>('usersBox');
    await Hive.openBox('callBreakGames');
    await Hive.openBox<CallBreakGameHistory>('callBreakGameHistory');
    await Hive.openBox<PlayerOverallStats>('playerStats');
    await Hive.openBox<MarriageGameHistory>('marriageGameHistory');
  }

  /// Initialize GetX controllers for state management
  void _initializeControllers() {
    Get.put(PlayerController());
    Get.put(UserListController());
  }

  /// Handle data migration by detecting schema conflicts
  /// Clears old data only when incompatible schema is detected
  Future<void> _handleDataMigration() async {
    try {
      // Attempt to open boxes to check for schema compatibility
      await Hive.openBox<CallBreakGameHistory>('callBreakGameHistory');
      await Hive.openBox<PlayerOverallStats>('playerStats');
    } catch (e) {
      // Clear incompatible data on schema conflict
      try {
        await Hive.deleteBoxFromDisk('callBreakGameHistory');
        await Hive.deleteBoxFromDisk('playerStats');
      } catch (deleteError) {
        // Ignore deletion errors for non-existent boxes
      }
    }
  }

  /// Force clean start as last resort when normal initialization fails
  /// Deletes all existing data and recreates boxes
  Future<void> _forceCleanStart() async {
    try {
      await Hive.deleteBoxFromDisk('callBreakGameHistory');
      await Hive.deleteBoxFromDisk('playerStats');
      await Hive.openBox<CallBreakGameHistory>('callBreakGameHistory');
      await Hive.openBox<PlayerOverallStats>('playerStats');
    } catch (e) {
      // Re-throw error if clean start also fails
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialize(),
      builder: (context, snapshot) {
        // Show error screen if initialization fails
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 20),
                    const Text(
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
                        // Restart the app on retry
                        runApp(const AppInitializationWidget());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Show splash screen during initialization
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
        }

        // Return main app once initialization is complete
        return const MyApp();
      },
    );
  }
}

/// Main application widget
/// Sets up theme and initial screen
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
