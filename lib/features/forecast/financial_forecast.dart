import '../../core/finance/financial_commitment.dart';
import '../../core/finance/commitment_engine.dart';
import '../../core/finance/financial_ledger.dart';
import '../../core/finance/transaction_recurrence.dart';
import '../accounts/account_model.dart';
import '../cards/card_model.dart';
import '../transactions/transaction_model.dart';

class FinancialForecast {
  const FinancialForecast({
    required this.currentBalance,
    required this.expectedIncome,
    required this.expectedExpenses,
    required this.commitmentReserve,
    required this.projectedBalance,
    required this.commitments,
  });

  final double currentBalance;
  final double expectedIncome;
  final double expectedExpenses;
  final double commitmentReserve;
  final double projectedBalance;
  final List<AtlasTransaction> commitments;

  double get projectedAfterCommitments =>
      currentBalance + expectedIncome - expectedExpenses - commitmentReserve;
}

class FinancialForecastEngine {
  const FinancialForecastEngine();

  static const _recurrence = TransactionRecurrenceEngine();
  static const _commitments = FinancialCommitmentEngine();

  FinancialForecast forMonth({
    required Iterable<AtlasTransaction> transactions,
    Iterable<AtlasAccount> accounts = const [],
    Iterable<AtlasCard> cards = const [],
    Iterable<FinancialCommitment> financialCommitments = const [],
    required DateTime now,
  }) {
    final all = transactions.toList(growable: false);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    final ledger = FinancialLedger(
      accounts: accounts,
      cards: cards,
      transactions: all,
    );

    var currentBalance = accounts.isEmpty
        ? all
              .where((item) => !item.transactionDate.isAfter(now))
              .fold<double>(0, (sum, item) => sum + _signed(item))
        : ledger.consolidatedBalanceAt(now);

    for (final recurring in all.where((item) => item.isRecurring)) {
      final historical = _recurrence.occurrencesBetween(
        recurring,
        start: recurring.transactionDate.add(const Duration(seconds: 1)),
        end: now,
      );
      currentBalance += historical.fold<double>(
        0,
        (sum, item) => sum + _cashSigned(item, accounts),
      );
    }

    final future = all
        .where(
          (item) =>
              item.transactionDate.isAfter(now) &&
              !item.transactionDate.isAfter(monthEnd),
        )
        .toList();

    final recurring = all
        .where((item) => item.isRecurring)
        .expand(
          (item) => _recurrence.occurrencesBetween(
            item,
            start: now.add(const Duration(seconds: 1)),
            end: monthEnd,
          ),
        );

    final commitments = [...future, ...recurring]
      ..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    final expectedIncome = commitments
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expectedExpenses = commitments
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final commitmentReserve = _commitments.totalOutstandingThrough(
      financialCommitments,
      referenceDate: now,
      end: monthEnd,
    );

    return FinancialForecast(
      currentBalance: currentBalance,
      expectedIncome: expectedIncome,
      expectedExpenses: expectedExpenses,
      commitmentReserve: commitmentReserve,
      projectedBalance:
          currentBalance + expectedIncome - expectedExpenses - commitmentReserve,
      commitments: List.unmodifiable(commitments),
    );
  }

  double projectedAfterPurchase(FinancialForecast forecast, double amount) =>
      forecast.projectedBalance - amount;

  double _signed(AtlasTransaction item) => switch (item.type) {
    TransactionType.income => item.amount,
    TransactionType.expense => -item.amount,
    TransactionType.transfer => 0,
  };

  double _cashSigned(
    AtlasTransaction item,
    Iterable<AtlasAccount> accounts,
  ) {
    if (accounts.isEmpty) return _signed(item);

    final sourceIsAccount =
        item.sourceType == TransactionSourceType.account &&
        accounts.any((account) => account.id == item.sourceId);
    final destinationIsAccount =
        item.destinationType == TransactionSourceType.account &&
        accounts.any((account) => account.id == item.destinationId);

    return switch (item.type) {
      TransactionType.income => sourceIsAccount ? item.amount : 0,
      TransactionType.expense => sourceIsAccount ? -item.amount : 0,
      TransactionType.transfer => destinationIsAccount
          ? item.amount
          : sourceIsAccount
          ? -item.amount
          : 0,
    };
  }
}
