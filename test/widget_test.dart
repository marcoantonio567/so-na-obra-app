// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:so_na_obra_app/screens/carteira/carteira_page.dart';
import 'package:so_na_obra_app/utils/formatters.dart';
import 'package:so_na_obra_app/main.dart';

void main() {
  test('parseMoneyInput aceita formatos comuns em reais', () {
    expect(parseMoneyInput('50,00'), 50);
    expect(parseMoneyInput('R\$ 1.234,56'), 1234.56);
    expect(parseMoneyInput('1,234.56'), 1234.56);
    expect(parseMoneyInput('1.234'), 1234);
    expect(parseMoneyInput('180.75'), 180.75);
  });

  testWidgets('Sacar debita o valor informado do saldo', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CarteiraPage(userId: 'local_user')),
      ),
    );

    await tester.pump();
    expect(find.text('R\$ 180,75'), findsOneWidget);

    await tester.tap(find.text('Sacar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '50,00');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('R\$ 130,75'), findsOneWidget);
    expect(find.text('Saque de R\$ 50,00 solicitado.'), findsOneWidget);
  });

  testWidgets('Mostra a nav bar e navega entre abas', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());

    expect(find.text('Login'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Marco');
    await tester.enterText(find.byType(TextFormField).at(1), '1234');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

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
    expect(
      find.descendant(of: bottomNav, matching: find.text('Home Page')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: bottomNav, matching: find.text('Criar')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: bottomNav, matching: find.text('Carteira')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: bottomNav, matching: find.text('Perfil')),
      findsOneWidget,
    );

    final appBar = find.byType(AppBar);
    expect(appBar, findsOneWidget);
    expect(
      find.descendant(of: appBar, matching: find.text('Home Page')),
      findsOneWidget,
    );

    final homeChatButton = find.byKey(const Key('home_top_chat_button'));
    expect(homeChatButton, findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.descendant(of: appBar, matching: find.text('Perfil')),
      findsOneWidget,
    );

    await tester.tap(find.text('Criar'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.descendant(of: appBar, matching: find.text('Criar')),
      findsOneWidget,
    );

    await tester.tap(find.text('Carteira'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.descendant(of: appBar, matching: find.text('Carteira')),
      findsOneWidget,
    );

    await tester.tap(find.text('Solicitações'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.descendant(of: appBar, matching: find.text('Solicitações')),
      findsOneWidget,
    );
  });
}
