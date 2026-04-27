// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:so_na_obra_app/main.dart';

void main() {
  testWidgets('Mostra a nav bar e navega entre abas', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(BottomNavigationBar).evaluate().isNotEmpty) break;
    }

    final bottomNav = find.byType(BottomNavigationBar);
    expect(bottomNav, findsOneWidget);

    expect(
      find.descendant(of: bottomNav, matching: find.text('Solicitações')),
      findsOneWidget,
    );
    expect(find.descendant(of: bottomNav, matching: find.text('Home Page')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('Criar')), findsOneWidget);
    expect(find.descendant(of: bottomNav, matching: find.text('Perfil')), findsOneWidget);

    final appBar = find.byType(AppBar);
    expect(appBar, findsOneWidget);
    expect(find.descendant(of: appBar, matching: find.text('Home Page')), findsOneWidget);

    final homeChatButton = find.byKey(const Key('home_top_chat_button'));
    expect(homeChatButton, findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.descendant(of: appBar, matching: find.text('Perfil')), findsOneWidget);

    await tester.tap(find.text('Criar'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.descendant(of: appBar, matching: find.text('Criar')), findsOneWidget);

    await tester.tap(find.text('Solicitações'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.descendant(of: appBar, matching: find.text('Solicitações')), findsOneWidget);
  });
}
