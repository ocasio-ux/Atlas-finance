import 'package:flutter_test/flutter_test.dart';
import 'package:atlas_finance/app/app.dart';

void main() {
  testWidgets('Atlas app starts on branded splash', (tester) async {
    await tester.pumpWidget(const AtlasApp());
    await tester.pump();

    expect(find.text('ATLAS'), findsOneWidget);
    expect(find.text('FINANCE'), findsOneWidget);
    expect(find.text('Seu dinheiro. Sob controle.'), findsOneWidget);
  });
}
