import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/app/app.dart';
import 'package:atlas_finance/features/home/home_page.dart';
import 'package:atlas_finance/features/transactions/new_transaction_page.dart';

void main() {
  testWidgets('Atlas starts with branded animated splash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AtlasApp());

    // The splash deliberately fades the wordmark/tagline in. The widgets are
    // present from the first frame even when their opacity starts at zero.
    expect(find.text('ATLAS'), findsOneWidget);
    expect(find.text('—  F I N A N C E  —'), findsOneWidget);
    expect(find.text('Seu dinheiro. Sob controle.'), findsOneWidget);

    // Advance into the animation without reaching the automatic navigation.
    await tester.pump(const Duration(milliseconds: 1800));

    expect(find.text('ATLAS'), findsOneWidget);
    expect(find.text('—  F I N A N C E  —'), findsOneWidget);
    expect(find.text('Seu dinheiro. Sob controle.'), findsOneWidget);
  });

  testWidgets('dashboard exposes planning and opens it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomePage()),
    );
    await tester.pump();

    expect(find.text('Defina limites e metas'), findsOneWidget);
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Planejamento'), findsOneWidget);
    expect(find.text('Orçamentos'), findsOneWidget);
    expect(find.text('Metas'), findsOneWidget);
  });

  testWidgets('dashboard opens the local profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.person_outline_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Perfil local'), findsOneWidget);
    expect(find.text('Armazenamento local'), findsOneWidget);
  });

  testWidgets('new transaction exposes a selectable date', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: NewTransactionPage()),
    );
    await tester.pump();

    expect(find.text('Data'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
  });
}
