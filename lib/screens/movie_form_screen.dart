import 'package:flutter/material.dart';

import '../models/movie.dart';

class MovieFormScreen extends StatefulWidget {
  const MovieFormScreen({super.key, this.movie});

  final Movie? movie;

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _cinemaController;
  late final TextEditingController _capacityController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  late final FocusNode _titleFocus;
  late final FocusNode _cinemaFocus;
  late final FocusNode _capacityFocus;
  late final FocusNode _descriptionFocus;

  MovieCategory? _category;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isOnline = false;
  bool _saving = false;
  bool _allowExit = false;

  late final String _initialSnapshot;

  bool get _isEditing => widget.movie != null;
  bool get _dirty => _snapshot() != _initialSnapshot;

  @override
  void initState() {
    super.initState();

    final movie = widget.movie;

    _titleController = TextEditingController(text: movie?.title ?? '');
    _cinemaController = TextEditingController(text: movie?.cinema ?? '');
    _capacityController = TextEditingController(
      text: movie?.capacity.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: movie?.description ?? '',
    );
    _dateController = TextEditingController();
    _timeController = TextEditingController();

    _titleFocus = FocusNode();
    _cinemaFocus = FocusNode();
    _capacityFocus = FocusNode();
    _descriptionFocus = FocusNode();

    _category = movie?.category;
    _isOnline = movie?.isOnline ?? false;

    if (movie != null) {
      _selectedDate = DateTime(
        movie.startsAt.year,
        movie.startsAt.month,
        movie.startsAt.day,
      );
      _selectedTime = TimeOfDay.fromDateTime(movie.startsAt);
    }

    _updateDateTimeText();
    _initialSnapshot = _snapshot();

    for (final controller in [
      _titleController,
      _cinemaController,
      _capacityController,
      _descriptionController,
    ]) {
      controller.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  String _snapshot() {
    return [
      _titleController.text,
      _cinemaController.text,
      _capacityController.text,
      _descriptionController.text,
      _category?.name ?? '',
      _selectedDate?.toIso8601String() ?? '',
      _selectedTime?.hour.toString() ?? '',
      _selectedTime?.minute.toString() ?? '',
      _isOnline.toString(),
    ].join('\u001f');
  }

  void _updateDateTimeText() {
    final date = _selectedDate;
    final time = _selectedTime;

    _dateController.text = date == null
        ? ''
        : '${date.day}/${date.month}/${date.year}';

    _timeController.text = time == null
        ? ''
        : '${time.hour.toString().padLeft(2, '0')}:'
              '${time.minute.toString().padLeft(2, '0')}';
  }

  DateTime? _combinedDateTime() {
    final date = _selectedDate;
    final time = _selectedTime;

    if (date == null || time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDate() async {
    if (_saving) return;

    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedDate = picked;
      _updateDateTimeText();
    });

    _formKey.currentState?.validate();
  }

  Future<void> _pickTime() async {
    if (_saving) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedTime = picked;
      _updateDateTimeText();
    });

    _formKey.currentState?.validate();
  }

  Future<void> _save() async {
    if (_saving) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final startsAt = _combinedDateTime();
    final category = _category;

    if (startsAt == null || category == null) return;

    setState(() {
      _saving = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final existing = widget.movie;
    final description = _descriptionController.text.trim();

    final movie = Movie(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: category,
      startsAt: startsAt,
      cinema: _cinemaController.text.trim(),
      capacity: int.parse(_capacityController.text.trim()),
      attendees: existing?.attendees ?? const [],
      isOnline: _isOnline,
      description: description.isEmpty ? null : description,
      isFavorite: existing?.isFavorite ?? false,
    );

    setState(() {
      _allowExit = true;
    });

    Navigator.of(context).pop(movie);
  }

  Future<void> _confirmDiscard() async {
    if (_saving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Leave without saving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _allowExit = true;
    });

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cinemaController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();

    _titleFocus.dispose();
    _cinemaFocus.dispose();
    _capacityFocus.dispose();
    _descriptionFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Movie>(
      canPop: _allowExit || (!_dirty && !_saving),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _saving) return;
        _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Edit Movie' : 'Add Movie')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                _isEditing ? 'Edit movie session' : 'Create movie session',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                focusNode: _titleFocus,
                maxLength: 60,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Movie title',
                  prefixIcon: Icon(Icons.movie),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final title = (value ?? '').trim();
                  if (title.length < 3) {
                    return 'Minimum 3 characters';
                  }
                  if (title.length > 60) {
                    return 'Maximum 60 characters';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _cinemaFocus.requestFocus(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MovieCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final category in MovieCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _category = value;
                        });
                      },
                validator: (value) =>
                    value == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Online screening'),
                subtitle: const Text('Online screenings require a URL'),
                value: _isOnline,
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _isOnline = value;
                        });
                        _formKey.currentState?.validate();
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cinemaController,
                focusNode: _cinemaFocus,
                textInputAction: TextInputAction.next,
                keyboardType: _isOnline
                    ? TextInputType.url
                    : TextInputType.streetAddress,
                decoration: InputDecoration(
                  labelText: _isOnline ? 'Screening URL' : 'Cinema',
                  prefixIcon: Icon(_isOnline ? Icons.link : Icons.location_on),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();

                  if (text.isEmpty) {
                    return 'This field is required';
                  }

                  if (_isOnline) {
                    final uri = Uri.tryParse(text);

                    if (uri == null ||
                        !uri.hasAuthority ||
                        (uri.scheme != 'http' && uri.scheme != 'https')) {
                      return 'Enter a valid http:// or https:// URL';
                    }
                  }

                  return null;
                },
                onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                focusNode: _capacityFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final capacity = int.tryParse((value ?? '').trim());

                  if (capacity == null || capacity < 1 || capacity > 500) {
                    return 'Enter a number from 1 to 500';
                  }

                  final booked = widget.movie?.attendees.length ?? 0;

                  if (capacity < booked) {
                    return 'Cannot be below $booked bookings';
                  }

                  return null;
                },
                onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: _saving ? null : _pickDate,
                validator: (_) =>
                    _selectedDate == null ? 'Select a date' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                onTap: _saving ? null : _pickTime,
                validator: (_) {
                  if (_selectedTime == null) {
                    return 'Select a time';
                  }

                  final startsAt = _combinedDateTime();

                  if (!_isEditing &&
                      startsAt != null &&
                      !startsAt.isAfter(DateTime.now())) {
                    return 'Choose a future date and time';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Saving...' : 'Save session'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
