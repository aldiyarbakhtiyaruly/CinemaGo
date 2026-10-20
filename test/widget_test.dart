import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinemago/main.dart';

void main() {
  testWidgets('CinemaGo shows three tabs', (tester) async {
    await tester.pumpWidget(const CinemaGoApp());

    expect(find.text('CinemaGo'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
