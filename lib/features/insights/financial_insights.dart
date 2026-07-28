import '../transactions/transaction_model.dart';

class CategoryInsight {
  const CategoryInsight({required this.category, required this.amount, required this.share});
  final TransactionCategory category;
  final double amount;
  final double share;
}

class FinancialInsights {
  const FinancialInsights({required this.income, required this.expenses, required this.net, required this.savingsRate, required this.topCategories});
  final double income;
  final double expenses;
  final double net;
  final double savingsRate;
  final List<CategoryInsight> topCategories;
}

class FinancialInsightsEngine {
  const FinancialInsightsEngine();

  FinancialInsights forMonth({required Iterable<AtlasTransaction> transactions, required DateTime month}) {
    final items = transactions.where((item) => item.createdAt.year == month.year && item.createdAt.month == month.month).toList(growable: false);
    final income = items.where((item) => item.type == TransactionType.income).fold<double>(0, (sum, item) => sum + item.amount);
    final expenses = items.where((item) => item.type == TransactionType.expense).fold<double>(0, (sum, item) => sum + item.amount);
    final byCategory = <TransactionCategory, double>{};
    for (final item in items.where((item) => item.type == TransactionType.expense)) {
      byCategory[item.category] = (byCategory[item.category] ?? 0) + item.amount;
    }
    final categories = byCategory.entries.map((entry) => CategoryInsight(category: entry.key, amount: entry.value, share: expenses == 0 ? 0 : entry.value / expenses)).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return FinancialInsights(
      income: income,
      expenses: expenses,
      net: income - expenses,
      savingsRate: income == 0 ? 0 : (income - expenses) / income,
      topCategories: List.unmodifiable(categories.take(5)),
    );
  }
}
