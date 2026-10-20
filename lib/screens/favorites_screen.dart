import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.movies,
    required this.onFavorite,
    required this.onMovieTap,
    required this.onExplore,
  });

  final List<Movie> movies;
  final ValueChanged<Movie> onFavorite;
  final ValueChanged<Movie> onMovieTap;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final favorites = movies.where((movie) => movie.isFavorite).toList();

    if (favorites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favorite movies yet',
        buttonText: 'Explore movies',
        onPressed: onExplore,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final movie = favorites[index];

              return MovieCard(
                movie: movie,
                onTap: () => onMovieTap(movie),
                onFavorite: () => onFavorite(movie),
              );
            },
          );
        }

        final columns = (constraints.maxWidth / 360).ceil().clamp(2, 6);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 145,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final movie = favorites[index];

            return MovieCard(
              movie: movie,
              onTap: () => onMovieTap(movie),
              onFavorite: () => onFavorite(movie),
            );
          },
        );
      },
    );
  }
}
