import '../models/movie.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class MovieDetailArgs {
  const MovieDetailArgs({
    required this.movie,
    required this.profileName,
    required this.onBookingChanged,
    required this.onOpenProfile,
    required this.onEdit,
    required this.onDelete,
  });

  final Movie movie;
  final String profileName;

  final void Function(Movie) onBookingChanged;
  final void Function() onOpenProfile;
  final void Function(Movie) onEdit;
  final void Function(Movie) onDelete;
}

class MovieFormArgs {
  const MovieFormArgs({this.movie});

  final Movie? movie;
}
