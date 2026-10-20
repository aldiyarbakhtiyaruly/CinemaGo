import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/movie.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.profileName,
    required this.onBookingChanged,
    required this.onOpenProfile,
    required this.onEdit,
    required this.onDelete,
  });

  final Movie movie;
  final String profileName;
  final ValueChanged<Movie> onBookingChanged;
  final VoidCallback onOpenProfile;
  final ValueChanged<Movie> onEdit;
  final ValueChanged<Movie> onDelete;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late DateTime _now;
  late Timer _timer;
  late Movie _movie;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _now = DateTime.now();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _handleBooking() async {
    final name = widget.profileName.trim();

    if (name.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Please enter your name in Profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              if (!mounted) return;
              widget.onOpenProfile();
              Navigator.of(context).pop();
            },
          ),
        ),
      );
      return;
    }

    final alreadyBooked = _movie.contains(name);

    if (!alreadyBooked && (_movie.isFull || _movie.isPast)) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(alreadyBooked ? 'Cancel booking?' : 'Book ticket?'),
        content: Text(
          alreadyBooked
              ? 'Cancel your booking for ${_movie.title}?'
              : 'Book a ticket for ${_movie.title}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    final attendees = List<String>.from(_movie.attendees);

    if (alreadyBooked) {
      attendees.remove(name);
    } else {
      attendees.add(name);
    }

    final updated = _movie.copyWith(attendees: attendees);

    setState(() {
      _movie = updated;
    });

    widget.onBookingChanged(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alreadyBooked ? 'Booking cancelled' : 'Ticket booked successfully',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = _movie;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final countdown = calculateCountdown(movie.startsAt, _now);
    final name = widget.profileName.trim();
    final booked = name.isNotEmpty && movie.contains(name);
    final canBook = booked || (!movie.isFull && !movie.isPast);
    final (:taken, :free) = movie.places;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Movie Details'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    widget.onEdit(movie);
                  case 'delete':
                    widget.onDelete(movie);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        'assets/cinema_banner.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return ColoredBox(
                            color: colors.primaryContainer,
                            child: Center(
                              child: Icon(
                                Icons.movie,
                                size: 90,
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Chip(
                        avatar: Icon(movie.category.icon),
                        label: Text(movie.category.label),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          countdownText(countdown),
                          textAlign: TextAlign.end,
                          style: textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(movie.title, style: textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 8),
                      Expanded(child: Text(movie.cinema)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined),
                      const SizedBox(width: 8),
                      Text(formatDate(movie.startsAt)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _stat('Capacity', movie.capacity),
                          _stat('Booked', taken),
                          _stat('Available', free),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TabBar(
                    tabs: [
                      const Tab(text: 'About'),
                      Tab(text: 'Attendees ($taken)'),
                    ],
                  ),
                  SizedBox(
                    height: 230,
                    child: TabBarView(
                      children: [_buildAbout(movie), _buildAttendees(movie)],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: canBook ? _handleBooking : null,
                    icon: Icon(
                      booked ? Icons.event_busy : Icons.confirmation_number,
                    ),
                    label: Text(
                      booked
                          ? 'Cancel booking'
                          : movie.isFull
                          ? 'Sold out'
                          : movie.isPast
                          ? 'Session ended'
                          : 'Book ticket',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, int value) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text('$value', style: textTheme.titleLarge),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }

  Widget _buildAbout(Movie movie) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this movie',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(movie.description ?? 'No description available.'),
          const SizedBox(height: 12),
          Text(movie.isOnline ? 'Online session' : 'Cinema screening'),
        ],
      ),
    );
  }

  Widget _buildAttendees(Movie movie) {
    if (movie.attendees.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        message: 'Nobody has booked yet',
      );
    }

    return ListView.builder(
      itemCount: movie.attendees.length,
      itemBuilder: (context, index) {
        final name = movie.attendees[index];
        final isYou =
            widget.profileName.trim().isNotEmpty &&
            name == widget.profileName.trim();

        return ListTile(
          leading: CircleAvatar(
            child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
          ),
          title: Text(
            isYou ? '$name (You)' : name,
            style: TextStyle(
              fontWeight: isYou ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      },
    );
  }
}
