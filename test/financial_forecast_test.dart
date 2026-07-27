import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/features/forecast/financial_forecast.dart';
import 'package:atlas_finance/features/transactions/transaction_model.dart';

void main() {
  const engine = FinancialForecastEngine();
  final now = DateTime(2026, 7, 15, 12);

  AtlasTransaction transaction(String id, TransactionType type, double amount, DateTime date) => AtlasTransaction(
        id: id,
        type: type,
        amount: amount,
        description: id,
        createdAt: date,
      );

  test('projects remaining month without counting transfers as income or expense', () {
    final forecast = engine.forMonth(transactions: [
      transaction('salary', TransactionType.income, 3000, DateTime(2026, 7, 5)),
      transaction('rent', TransactionType.expense, 1000, DateTime(2026, 7, 10)),
      transaction('card', TransactionType.expense, 500, DateTime(2026, 7, 20)),
      transaction('bonus', TransactionType.income, 200, DateTime(2026, 7, 25)),
      transaction('transfer', TransactionType.transfer, 800, DateTime(2026, 7, 26)),
      transaction('next month', TransactionType.expense, 999, DateTime(2026, 8, 1)),
    ], now: now);

    expect(forecast.currentBalance, 2000);
    expect(forecast.expectedIncome, 200);
    expect(forecast.expectedExpenses, 500);
    expect(forecast.projectedBalance, 1700);
    expect(forecast.commitments.length, 3);
    expect(engine.projectedAfterPurchase(forecast, 300), 1400);
  });
}
