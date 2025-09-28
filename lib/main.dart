// lib/main.dart (Fixed to start with an empty PlayerController)

// Required for PlayerController setup
import 'package:calculators/controllers/player_controller.dart';
import 'package:calculators/model/user_model.dart';
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
      // 1. Initialize Hive Flutter and Register Adapter
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserAdapter());
      }

      // 2. Open the critical box
      await Hive.openBox<User>('usersBox');

      final userBox = Hive.box<User>('usersBox');
      const int defaultPlayerCount = 4; // Target game size

      // 3. Initial data check: Ensure we have enough users to start a game
      if (userBox.isEmpty) {
        // Add default users if the box is completely empty
        for (int i = 1; i <= defaultPlayerCount; i++) {
          // Creating the default users
          userBox.add(User(username: 'Guest Player $i', profileImagePath: null, wins: 0, rank: i));
        }
      }

      // 🔥 FIX APPLIED HERE: Initialize the PlayerController, but DO NOT
      // automatically populate the player list from Hive. The list must remain
      // empty initially, relying on the user to click "Select Players."

      // We still use Get.put() to create the controller instance and register it.
      // The controller's internal list (players) will start empty as designed.
      Get.put(PlayerController());

      // Removed the following lines which forced loading the top 4 players:
      /*
      final allUsers = userBox.values.toList();
      final usersToStartGame = allUsers.take(defaultPlayerCount).toList();
      final initialPlayers = usersToStartGame.map((user) { ... }).toList();
      Get.put(PlayerController()).initializePlayers(initialPlayers);
      */
    } catch (e) {
      debugPrint('CRITICAL ERROR during initialization: $e');
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
                child: Text('App failed to load. Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
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
