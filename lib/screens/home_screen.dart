import 'package:flutter/material.dart';

import '../data/seed_movies.dart';
import '../models/movie.dart';
import '../models/profile.dart';

import 'favorites_screen.dart';
import 'movie_detail_screen.dart';
import 'movie_form_screen.dart';
import 'movies_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Movie> _movies = createSeedMovies();

  Profile _profile = const Profile.empty();

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleFavorite(Movie movie) {
    final index = _movies.indexWhere((item) => item.id == movie.id);

    if (index == -1) return;

    setState(() {
      _movies[index] = _movies[index].copyWith(
        isFavorite: !_movies[index].isFavorite,
      );
    });
  }

  void _updateMovie(Movie updatedMovie) {
    final index = _movies.indexWhere((item) => item.id == updatedMovie.id);

    if (index == -1) return;

    setState(() {
      _movies[index] = updatedMovie;
    });
  }

  Future<void> _addMovie() async {
    final movie = await Navigator.of(context).push<Movie>(
      MaterialPageRoute(builder: (context) => const MovieFormScreen()),
    );

    if (!mounted || movie == null) return;

    setState(() {
      _movies.add(movie);
    });
  }

  Future<void> _editMovie(Movie movie) async {
    final updated = await Navigator.of(context).push<Movie>(
      MaterialPageRoute(builder: (context) => MovieFormScreen(movie: movie)),
    );

    if (!mounted || updated == null) return;

    _updateMovie(updated);
  }

  Future<void> _deleteMovie(Movie movie) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete movie?'),
          content: Text('Do you want to delete "${movie.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _movies.removeWhere((item) => item.id == movie.id);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${movie.title} deleted')));
  }

  void _openMovie(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (detailContext) {
          return MovieDetailScreen(
            movie: movie,
            profileName: _profile.name,
            onBookingChanged: _updateMovie,
            onOpenProfile: () {
              _changeTab(2);
            },
            onEdit: (selectedMovie) {
              Navigator.of(detailContext).pop();
              _editMovie(selectedMovie);
            },
            onDelete: (selectedMovie) {
              Navigator.of(detailContext).pop();
              _deleteMovie(selectedMovie);
            },
          );
        },
      ),
    );
  }

  void _showAbout() {
    Navigator.of(context).pop();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('About CinemaGo'),
          content: const Text(
            'CinemaGo is a Flutter movie booking app.\n\n'
            'Features:\n'
            '- Browse movies\n'
            '- Search and filter\n'
            '- Book tickets\n'
            '- Manage favorites\n'
            '- Create and edit sessions\n'
            '- Dark mode\n\n'
            'Version: 1.0.0',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetData() async {
    Navigator.of(context).pop();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset data?'),
          content: const Text(
            'All changes, favorites and bookings will '
            'be removed. The original 12 sessions '
            'will be restored.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _movies = createSeedMovies();
      _profile = const Profile.empty();
      _selectedIndex = 0;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Data reset successfully')));
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
      ProfileScreen(
        profile: _profile,
        movies: _movies,
        themeMode: widget.themeMode,
        onSave: (updatedProfile) {
          setState(() {
            _profile = updatedProfile;
          });
        },
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('CinemaGo'), centerTitle: true),

      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Center(
                  child: Text(
                    'CinemaGo',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: _showAbout,
              ),

              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset data'),
                onTap: _resetData,
              ),
            ],
          ),
        ),
      ),

      body: IndexedStack(index: _selectedIndex, children: screens),

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _addMovie,
              child: const Icon(Icons.add),
            )
          : null,

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
