import 'package:flutter/material.dart';

import 'models/movie.dart';
import 'navigation/routes.dart';
import 'screens/home_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/movie_form_screen.dart';

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
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) =>
            HomeScreen(themeMode: _themeMode, onThemeChanged: _changeTheme),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.detail:
            final args = settings.arguments;

            if (args is MovieDetailArgs) {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (context) => MovieDetailScreen(
                  movie: args.movie,
                  profileName: args.profileName,
                  onBookingChanged: args.onBookingChanged,
                  onOpenProfile: args.onOpenProfile,
                  onEdit: args.onEdit,
                  onDelete: args.onDelete,
                ),
              );
            }

          case Routes.form:
            final args = settings.arguments;

            if (args is MovieFormArgs) {
              return MaterialPageRoute<Movie>(
                settings: settings,
                builder: (context) => MovieFormScreen(movie: args.movie),
              );
            }
        }

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => const UnknownRouteScreen(),
        );
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => const UnknownRouteScreen(),
        );
      },
    );
  }
}

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            const Text('This page does not exist'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Back to home'),
            ),
          ],
        ),
      ),
    );
  }
}
