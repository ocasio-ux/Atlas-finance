import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/app/app.dart';

void main() {
  testWidgets('Atlas renders its initial dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const AtlasApp());

    expect(find.text('Atlas'), findsOneWidget);
    expect(find.text('Saldo total'), findsOneWidget);
    expect(find.text('Visão geral'), findsOneWidget);
  });
}
