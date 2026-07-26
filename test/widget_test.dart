import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/app/app.dart';

void main() {
  testWidgets('Atlas opens splash and new transaction flow', (WidgetTester tester) async {
    await tester.pumpWidget(const AtlasApp());

    expect(find.text('ATLAS'), findsOneWidget);
    expect(find.text('Seu dinheiro. Sob controle.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Saldo total'), findsOneWidget);
    expect(find.text('Adicionar'), findsOneWidget);

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('Nova movimentação'), findsOneWidget);
    expect(find.text('Salvar movimentação'), findsOneWidget);
  });
}
