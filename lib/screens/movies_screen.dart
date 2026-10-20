import 'package:flutter/material.dart';

import '../models/movie.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key, required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: movies.isEmpty
          ? const Center(child: Text('No movies available'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(movie.category.icon)),
                    title: Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(movie.category.label),
                        Text(movie.cinema),
                        Text('${movie.freeSeats} seats available'),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
