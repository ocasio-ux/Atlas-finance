import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/features/forecast/financial_forecast.dart';
import 'package:atlas_finance/features/transactions/transaction_model.dart';

void main() {
  const engine = FinancialForecastEngine();
  final now = DateTime(2026, 7, 15, 12);

  AtlasTransaction transaction(
    String id,
    TransactionType type,
    double amount,
    DateTime date,
  ) => AtlasTransaction(
    id: id,
    type: type,
    amount: amount,
    description: id,
    createdAt: date,
  );

  test('stops monthly recurrence after its end date', () {
    final recurring = AtlasTransaction(
      id: 'course',
      type: TransactionType.expense,
      amount: 200,
      description: 'Curso',
      createdAt: DateTime(2026, 6, 10),
      transactionDate: DateTime(2026, 6, 10),
      repeat: TransactionRepeat.monthly,
      repeatEndDate: DateTime(2026, 8, 10),
    );

    final forecast = engine.forMonth(
      transactions: [recurring],
      now: DateTime(2026, 7, 15),
    );

    expect(forecast.expectedExpenses, 200);

    final september = engine.forMonth(
      transactions: [recurring],
      now: DateTime(2026, 9, 1),
    );
    expect(september.expectedExpenses, 0);
  });

  test('includes monthly recurring commitments in the forecast', () {
    final recurring = AtlasTransaction(
      id: 'gym',
      type: TransactionType.expense,
      amount: 99.90,
      description: 'Academia',
      createdAt: DateTime(2026, 6, 10),
      transactionDate: DateTime(2026, 6, 10),
      repeat: TransactionRepeat.monthly,
    );

    final forecast = engine.forMonth(
      transactions: [
        recurring,
        transaction(
          'salary',
          TransactionType.income,
          3000,
          DateTime(2026, 7, 20),
        ),
      ],
      now: DateTime(2026, 7, 15, 12),
    );

    expect(forecast.currentBalance, closeTo(-199.80, 0.001));
    expect(forecast.expectedIncome, 3000);
    expect(forecast.expectedExpenses, closeTo(99.90, 0.001));
    expect(forecast.commitments.map((item) => item.description), [
      'Academia',
      'salary',
    ]);
    expect(forecast.commitments.first.transactionDate, DateTime(2026, 7, 10));
  });

  test('uses transaction date rather than record creation date for current balance', () {
    final future = AtlasTransaction(
      id: 'future',
      type: TransactionType.expense,
      amount: 500,
      description: 'Futuro',
      createdAt: DateTime(2026, 7, 15, 12),
      transactionDate: DateTime(2026, 7, 20),
    );

    final forecast = engine.forMonth(
      transactions: [future],
      now: DateTime(2026, 7, 15, 12),
    );

    expect(forecast.currentBalance, 0);
    expect(forecast.expectedExpenses, 500);
  });

  test(
    'projects remaining month without counting transfers as income or expense',
    () {
      final forecast = engine.forMonth(
        transactions: [
          transaction(
            'salary',
            TransactionType.income,
            3000,
            DateTime(2026, 7, 5),
          ),
          transaction(
            'rent',
            TransactionType.expense,
            1000,
            DateTime(2026, 7, 10),
          ),
          transaction(
            'card',
            TransactionType.expense,
            500,
            DateTime(2026, 7, 20),
          ),
          transaction(
            'bonus',
            TransactionType.income,
            200,
            DateTime(2026, 7, 25),
          ),
          transaction(
            'transfer',
            TransactionType.transfer,
            800,
            DateTime(2026, 7, 26),
          ),
          transaction(
            'next month',
            TransactionType.expense,
            999,
            DateTime(2026, 8, 1),
          ),
        ],
        now: now,
      );

      expect(forecast.currentBalance, 2000);
      expect(forecast.expectedIncome, 200);
      expect(forecast.expectedExpenses, 500);
      expect(forecast.projectedBalance, 1700);
      expect(forecast.commitments.length, 3);
      expect(engine.projectedAfterPurchase(forecast, 300), 1400);
    },
  );
}
