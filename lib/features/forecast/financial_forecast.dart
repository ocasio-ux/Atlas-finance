import '../transactions/transaction_model.dart';

class FinancialForecast {
  const FinancialForecast({
    required this.currentBalance,
    required this.expectedIncome,
    required this.expectedExpenses,
    required this.projectedBalance,
    required this.commitments,
  });

  final double currentBalance;
  final double expectedIncome;
  final double expectedExpenses;
  final double projectedBalance;
  final List<AtlasTransaction> commitments;
}

class FinancialForecastEngine {
  const FinancialForecastEngine();

  FinancialForecast forMonth({
    required Iterable<AtlasTransaction> transactions,
    required DateTime now,
  }) {
    final all = transactions.toList(growable: false);
    final currentBalance = all
        .where((item) => !item.createdAt.isAfter(now))
        .fold<double>(0, (sum, item) => sum + _signed(item));

    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    final future =
        all
            .where(
              (item) =>
                  item.createdAt.isAfter(now) &&
                  !item.createdAt.isAfter(monthEnd),
            )
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final expectedIncome = future
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expectedExpenses = future
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);

    return FinancialForecast(
      currentBalance: currentBalance,
      expectedIncome: expectedIncome,
      expectedExpenses: expectedExpenses,
      projectedBalance: currentBalance + expectedIncome - expectedExpenses,
      commitments: List.unmodifiable(future),
    );
  }

  double projectedAfterPurchase(FinancialForecast forecast, double amount) =>
      forecast.projectedBalance - amount;

  double _signed(AtlasTransaction item) => switch (item.type) {
    TransactionType.income => item.amount,
    TransactionType.expense => -item.amount,
    TransactionType.transfer => 0,
  };
}
