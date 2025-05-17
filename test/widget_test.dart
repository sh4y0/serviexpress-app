// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serviexpress_app/presentation/pages/serviexpress.dart';

void main() {
  testWidgets('ServiExpressApp has title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Serviexpress());

    // Verify that our app has a title.
    expect(find.text('ServiExpress'), findsOneWidget);
  });

  testWidgets('ServiExpressApp has theme', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Serviexpress());

    // Verify that our app has a theme.
    expect(find.byType(ThemeData), findsOneWidget);
  });
}
