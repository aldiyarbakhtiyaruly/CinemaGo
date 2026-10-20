import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../models/profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.movies,
    required this.themeMode,
    required this.onSave,
    required this.onThemeChanged,
  });

  final Profile profile;
  final List<Movie> movies;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onSave;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;

  final _formKey = GlobalKey<FormState>();

  final RegExp _groupPattern = RegExp(r'^[A-Za-z0-9-]{2,20}$');

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.profile.name);

    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.profile.name != widget.profile.name) {
      _nameController.text = widget.profile.name;
    }

    if (oldWidget.profile.group != widget.profile.group) {
      _groupController.text = widget.profile.group;
    }
  }

  void _saveProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final updated = widget.profile.copyWith(
      name: _nameController.text.trim(),
      group: _groupController.text.trim(),
    );

    widget.onSave(updated);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved successfully')));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final name = widget.profile.name.trim();

    final bookings = name.isEmpty
        ? 0
        : widget.movies.where((movie) => movie.contains(name)).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Icon(Icons.account_circle, size: 90, color: theme.colorScheme.primary),

        const SizedBox(height: 12),

        Center(child: Text('My Profile', style: theme.textTheme.headlineSmall)),

        const SizedBox(height: 20),

        Card(
          child: ListTile(
            leading: const Icon(Icons.confirmation_number),
            title: Text('$bookings bookings'),
            subtitle: const Text('Your movie reservations'),
          ),
        ),

        const SizedBox(height: 20),

        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final name = (value ?? '').trim();

                  if (name.isEmpty) {
                    return 'Enter your name';
                  }

                  if (name.length < 2) {
                    return 'Minimum 2 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _groupController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Your group',
                  prefixIcon: Icon(Icons.groups),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final group = (value ?? '').trim();

                  if (group.isNotEmpty && !_groupPattern.hasMatch(group)) {
                    return 'Use 2-20 letters, numbers or hyphens';
                  }

                  return null;
                },
                onFieldSubmitted: (_) => _saveProfile(),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        Text('Appearance', style: theme.textTheme.titleLarge),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Light'),
              selected: widget.themeMode == ThemeMode.light,
              onSelected: (_) {
                widget.onThemeChanged(ThemeMode.light);
              },
            ),
            ChoiceChip(
              label: const Text('Dark'),
              selected: widget.themeMode == ThemeMode.dark,
              onSelected: (_) {
                widget.onThemeChanged(ThemeMode.dark);
              },
            ),
            ChoiceChip(
              label: const Text('System'),
              selected: widget.themeMode == ThemeMode.system,
              onSelected: (_) {
                widget.onThemeChanged(ThemeMode.system);
              },
            ),
          ],
        ),
      ],
    );
  }
}
