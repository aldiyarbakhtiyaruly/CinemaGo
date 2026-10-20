import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinemago/main.dart';

void main() {
  testWidgets('CinemaGo welcome screen test', (tester) async {
    await tester.pumpWidget(const CinemaGoApp());

    expect(find.text('CinemaGo'), findsOneWidget);
    expect(find.text('Welcome to CinemaGo'), findsOneWidget);
    expect(find.byIcon(Icons.local_movies), findsOneWidget);
  });
}
