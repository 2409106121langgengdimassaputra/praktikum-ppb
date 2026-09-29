import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ucpubg/main.dart'; 

void main() {
  testWidgets('Home page loads', (WidgetTester tester) async {
    await tester.pumpWidget(const TopUpApp());
    expect(find.text('TopUp UC PUBGM'), findsOneWidget);
  });
}