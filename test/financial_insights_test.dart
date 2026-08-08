import 'package:flutter_test/flutter_test.dart';
import 'package:atlas_finance/features/insights/financial_insights.dart';
import 'package:atlas_finance/features/transactions/transaction_model.dart';

void main() {
  test('reports spending increase and future commitments', () {
    final now = DateTime(2026, 8, 15, 12);
    final transactions = [
      AtlasTransaction(
        id: 'previous',
        type: TransactionType.expense,
        amount: 100,
        description: 'Previous',
        createdAt: DateTime(2026, 7, 10),
        category: TransactionCategory.food,
      ),
      AtlasTransaction(
        id: 'current',
        type: TransactionType.expense,
        amount: 150,
        description: 'Current',
        createdAt: DateTime(2026, 8, 5),
        category: TransactionCategory.food,
      ),
      AtlasTransaction(
        id: 'future',
        type: TransactionType.expense,
        amount: 50,
        description: 'Future',
        createdAt: DateTime(2026, 8, 25),
        category: TransactionCategory.transport,
      ),
    ];

    final insights = const FinancialInsightsEngine().build(
      transactions: transactions,
      now: now,
    );

    expect(insights.any((item) => item.title == 'Gastos em alta'), isTrue);
    expect(insights.any((item) => item.title == 'Maior categoria'), isTrue);
    expect(insights.any((item) => item.title == 'Compromissos pela frente'), isTrue);
  });

  test('returns a neutral insight when there is no activity', () {
    final insights = const FinancialInsightsEngine().build(
      transactions: const [],
      now: DateTime(2026, 8, 15),
    );

    expect(insights, hasLength(1));
    expect(insights.single.kind, FinancialInsightKind.neutral);
  });
}
