import 'package:flutter/material.dart';

enum MovieCategory {
  action('Action', Icons.local_fire_department),
  comedy('Comedy', Icons.sentiment_very_satisfied),
  drama('Drama', Icons.theater_comedy),
  horror('Horror', Icons.dark_mode),
  animation('Animation', Icons.animation),
  sciFi('Sci-Fi', Icons.rocket_launch);

  const MovieCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

class Movie {
  Movie({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.cinema,
    required this.capacity,
    required List<String> attendees,
    required this.isOnline,
    this.description,
    this.isFavorite = false,
  }) : attendees = List.unmodifiable(attendees);

  Movie.empty()
    : id = DateTime.now().microsecondsSinceEpoch.toString(),
      title = '',
      category = MovieCategory.action,
      startsAt = DateTime.now().add(const Duration(days: 1)),
      cinema = '',
      capacity = 20,
      attendees = const [],
      isOnline = false,
      description = null,
      isFavorite = false;

  final String id;
  final String title;
  final MovieCategory category;
  final DateTime startsAt;
  final String cinema;
  final int capacity;
  final List<String> attendees;
  final bool isOnline;
  final String? description;
  final bool isFavorite;

  int get bookedSeats => attendees.length;

  int get freeSeats => capacity - bookedSeats;

  bool get isFull => freeSeats <= 0;

  bool get isPast => startsAt.isBefore(DateTime.now());

  bool contains(String name) => attendees.contains(name);

  ({int taken, int free}) get places => (taken: bookedSeats, free: freeSeats);

  Movie copyWith({
    String? id,
    String? title,
    MovieCategory? category,
    DateTime? startsAt,
    String? cinema,
    int? capacity,
    List<String>? attendees,
    bool? isOnline,
    String? description,
    bool? isFavorite,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      startsAt: startsAt ?? this.startsAt,
      cinema: cinema ?? this.cinema,
      capacity: capacity ?? this.capacity,
      attendees: attendees ?? this.attendees,
      isOnline: isOnline ?? this.isOnline,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
