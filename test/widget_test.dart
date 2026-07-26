import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/main.dart';

void main() {
  testWidgets('Atlas opens new transaction flow', (WidgetTester tester) async {
    await tester.pumpWidget(const AtlasApp());

    expect(find.text('ATLAS'), findsOneWidget);
    expect(find.text('Saldo total'), findsOneWidget);
    expect(find.text('Adicionar'), findsOneWidget);

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('Nova movimentação'), findsOneWidget);
    expect(find.text('Salvar movimentação'), findsOneWidget);
  });
}