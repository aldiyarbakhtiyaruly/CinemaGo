import 'package:flutter/material.dart';

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
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('CinemaGo'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_movies, size: 90, color: colors.primary),
            const SizedBox(height: 20),
            Text('Welcome to CinemaGo', style: textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(
              'Discover movies and book tickets',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
