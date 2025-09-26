import 'package:calculators/screens/home_screen.dart';
import 'package:calculators/screens/intro_screen.dart';
import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(), // initial route
      routes: {
        '/introScreen': (context) => const IntroScreen(),
        '/homeScreen': (context) => const HomeScreen(), // define your calculator screen here
      },
    );
  }
}
