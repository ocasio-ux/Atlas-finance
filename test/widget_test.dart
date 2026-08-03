import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/app/app.dart';

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
}
