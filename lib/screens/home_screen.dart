import 'package:flutter/material.dart';

import '../data/seed_movies.dart';
import '../models/movie.dart';
import 'movies_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Movie> _movies = createSeedMovies();

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleFavorite(Movie movie) {
    setState(() {
      final index = _movies.indexWhere((item) => item.id == movie.id);

      if (index == -1) return;

      _movies[index] = movie.copyWith(isFavorite: !movie.isFavorite);
    });
  }

  void _openMovie(Movie movie) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${movie.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      MoviesScreen(
        movies: _movies,
        onFavorite: _toggleFavorite,
        onMovieTap: _openMovie,
      ),
      FavoritesScreen(
        movies: _movies,
        onFavorite: _toggleFavorite,
        onMovieTap: _openMovie,
        onExplore: () => _changeTab(0),
      ),
      const ProfilePlaceholderScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('CinemaGo'), centerTitle: true),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _changeTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Movies',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile screen coming soon'));
  }
}
