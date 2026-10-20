import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const CinemaGoApp());
}

class CinemaGoApp extends StatelessWidget {
  const CinemaGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CinemaGo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      ),
      home: const HomeScreen(),
    );
  }
}
