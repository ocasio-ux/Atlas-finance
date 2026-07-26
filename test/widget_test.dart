import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/app/app.dart';

void main() {
  testWidgets('Atlas starts with branded splash', (WidgetTester tester) async {
    await tester.pumpWidget(const AtlasApp());
    await tester.pump();

    expect(find.text('ATLAS'), findsOneWidget);
    expect(find.text('FINANCE'), findsOneWidget);
    expect(find.text('Seu dinheiro. Sob controle.'), findsOneWidget);
  });
}
