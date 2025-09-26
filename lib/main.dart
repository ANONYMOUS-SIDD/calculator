import 'package:calculators/model/user_model.dart'; // Import your Hive initialization function
import 'package:calculators/screens/home_screen.dart';
import 'package:calculators/screens/intro_screen.dart';
// Use package imports for all your screens
import 'package:calculators/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import hive_flutter

void main() async {
  // 🛑 1. CRITICAL: Initialize Flutter Bindings
  // This must be called before any async/native code (like Hive init) runs.
  WidgetsFlutterBinding.ensureInitialized();

  // 🛑 2. INITIALIZE HIVE
  try {
    await initHive();

    // Optional: Add a default user if the box is empty for a good first-run experience
    final userBox = Hive.box<User>('usersBox');
    if (userBox.isEmpty) {
      userBox.add(User.defaultUser());
    }
  } catch (e) {
    // Log any initialization error
    print('Error initializing Hive: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator App',
      // Using a global dark theme helps match your home_screen design
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        // Optional: Define a base color for the dark theme if you wish
        scaffoldBackgroundColor: const Color(0xFF1A243F),
      ),
      // Using the widget directly is fine, but ensure it's the correct instance
      home: const SplashScreen(),
      routes: {
        '/introScreen': (context) => const IntroScreen(),
        '/homeScreen': (context) => const HomeScreen(),
        // Note: Detail screens (Marriage, Users, etc.) use Navigator.push
        // with PageRouteBuilder, so they don't need to be defined here.
      },
    );
  }
}
