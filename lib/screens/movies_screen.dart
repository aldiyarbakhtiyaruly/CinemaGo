import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/empty_state.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({
    super.key,
    required this.movies,
    required this.onFavorite,
    required this.onMovieTap,
  });

  final List<Movie> movies;
  final ValueChanged<Movie> onFavorite;
  final ValueChanged<Movie> onMovieTap;

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _search = '';
  MovieCategory? _selectedCategory;
  bool _showPast = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Movie> get _filteredMovies {
    final result = widget.movies.where((movie) {
      final matchesSearch = movie.title.toLowerCase().contains(
        _search.toLowerCase(),
      );

      final matchesCategory =
          _selectedCategory == null || movie.category == _selectedCategory;

      final matchesDate = _showPast || !movie.isPast;

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();

    result.sort((a, b) {
      if (a.isPast != b.isPast) {
        return a.isPast ? 1 : -1;
      }
      return a.startsAt.compareTo(b.startsAt);
    });

    return result;
  }

  void _clearFilters() {
    setState(() {
      _search = '';
      _selectedCategory = null;
      _showPast = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movies = _filteredMovies;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _search = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search movies...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _search = '';
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
              ),
              for (final category in MovieCategory.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category.label),
                    selected: _selectedCategory == category,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Include past'),
                selected: _showPast,
                onSelected: (value) {
                  setState(() {
                    _showPast = value;
                  });
                },
              ),
              const Spacer(),
              Text('${movies.length} movies'),
            ],
          ),
        ),
        Expanded(
          child: movies.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No matching movies',
                  buttonText: 'Clear filters',
                  onPressed: _clearFilters,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    if (width < 600) {
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: movies.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final movie = movies[index];

                          return MovieCard(
                            movie: movie,
                            onTap: () => widget.onMovieTap(movie),
                            onFavorite: () => widget.onFavorite(movie),
                          );
                        },
                      );
                    }

                    final columns = (width / 360).ceil().clamp(2, 6);

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 145,
                      ),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];

                        return MovieCard(
                          movie: movie,
                          onTap: () => widget.onMovieTap(movie),
                          onFavorite: () => widget.onFavorite(movie),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
