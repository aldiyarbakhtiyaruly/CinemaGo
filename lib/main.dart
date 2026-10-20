import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const CinemaGoApp());
}

class CinemaGoApp extends StatefulWidget {
  const CinemaGoApp({super.key});

  @override
  State<CinemaGoApp> createState() => _CinemaGoAppState();
}

class _CinemaGoAppState extends State<CinemaGoApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CinemaGo',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(themeMode: _themeMode, onThemeChanged: _changeTheme),
    );
  }
}
