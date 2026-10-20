import 'package:flutter/material.dart';

import '../data/seed_movies.dart';
import '../models/movie.dart';
import '../models/profile.dart';

import 'favorites_screen.dart';
import 'movie_detail_screen.dart';
import 'movie_form_screen.dart';
import 'movies_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Movie> _movies = createSeedMovies();

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

  void _openMovie(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => MovieDetailScreen(
          movie: movie,
          profileName: _profile.name,
          onBookingChanged: _updateMovie,
          onOpenProfile: () => _changeTab(2),
          onEdit: (selectedMovie) {
            Navigator.of(context).pop();
            _editMovie(selectedMovie);
          },
        ),
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
      ProfileScreen(
        profile: _profile,
        onSave: (updatedProfile) {
          setState(() {
            _profile = updatedProfile;
          });
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('CinemaGo'), centerTitle: true),
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.profile, required this.onSave});

  final Profile profile;
  final ValueChanged<Profile> onSave;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.profile.name);

    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updated = widget.profile.copyWith(
      name: _nameController.text.trim(),
      group: _groupController.text.trim(),
    );

    widget.onSave(updated);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.account_circle, size: 80),
        const SizedBox(height: 20),

        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Your name',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _groupController,
          decoration: const InputDecoration(
            labelText: 'Your group',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        FilledButton(
          onPressed: _saveProfile,
          child: const Text('Save profile'),
        ),
      ],
    );
  }
}
