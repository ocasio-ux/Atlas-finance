import '../transactions/transaction_model.dart';

class FinancialInsight {
  const FinancialInsight({required this.title, required this.message, required this.kind});
  final String title;
  final String message;
  final FinancialInsightKind kind;
}

enum FinancialInsightKind { positive, attention, neutral }

class FinancialInsightsEngine {
  const FinancialInsightsEngine();

  List<FinancialInsight> build({required Iterable<AtlasTransaction> transactions, DateTime? now}) {
    final today = now ?? DateTime.now();
    final currentStart = DateTime(today.year, today.month, 1);
    final previousStart = DateTime(today.year, today.month - 1, 1);
    final previousEnd = currentStart.subtract(const Duration(microseconds: 1));
    final all = transactions.toList(growable: false);

    double expensesBetween(DateTime start, DateTime end) => all
        .where((item) => item.type == TransactionType.expense && !item.createdAt.isBefore(start) && !item.createdAt.isAfter(end))
        .fold<double>(0, (sum, item) => sum + item.amount);

    final currentExpenses = expensesBetween(currentStart, today);
    final previousExpenses = expensesBetween(previousStart, previousEnd);
    final insights = <FinancialInsight>[];

    if (previousExpenses > 0) {
      final change = ((currentExpenses - previousExpenses) / previousExpenses) * 100;
      if (change.abs() >= 10) {
        insights.add(FinancialInsight(
          title: change > 0 ? 'Gastos em alta' : 'Gastos menores',
          message: 'Suas despesas do mês estão ${change.abs().toStringAsFixed(0)}% ${change > 0 ? 'acima' : 'abaixo'} do mês anterior.',
          kind: change > 0 ? FinancialInsightKind.attention : FinancialInsightKind.positive,
        ));
      }
    }

    final categoryTotals = <TransactionCategory, double>{};
    for (final item in all.where((item) => item.type == TransactionType.expense && !item.createdAt.isBefore(currentStart) && !item.createdAt.isAfter(today))) {
      categoryTotals.update(item.category, (value) => value + item.amount, ifAbsent: () => item.amount);
    }
    if (categoryTotals.isNotEmpty) {
      final top = categoryTotals.entries.reduce((a, b) => a.value >= b.value ? a : b);
      insights.add(FinancialInsight(title: 'Maior categoria', message: '${_categoryLabel(top.key)} concentra R\$ ${top.value.toStringAsFixed(2).replaceAll('.', ',')} das despesas deste mês.', kind: FinancialInsightKind.neutral));
    }

    final futureCommitments = all.where((item) => item.type == TransactionType.expense && item.createdAt.isAfter(today) && item.createdAt.year == today.year && item.createdAt.month == today.month).fold<double>(0, (sum, item) => sum + item.amount);
    if (futureCommitments > 0) {
      insights.add(FinancialInsight(title: 'Compromissos pela frente', message: 'Ainda há R\$ ${futureCommitments.toStringAsFixed(2).replaceAll('.', ',')} em despesas previstas até o fim do mês.', kind: FinancialInsightKind.attention));
    }

    if (insights.isEmpty) {
      insights.add(const FinancialInsight(title: 'Tudo acompanhado', message: 'Continue registrando movimentações para o Atlas encontrar padrões úteis.', kind: FinancialInsightKind.neutral));
    }
    return List.unmodifiable(insights);
  }
}

String _categoryLabel(TransactionCategory value) => switch (value) {
  TransactionCategory.food => 'Alimentação',
  TransactionCategory.transport => 'Transporte',
  TransactionCategory.housing => 'Moradia',
  TransactionCategory.health => 'Saúde',
  TransactionCategory.leisure => 'Lazer',
  TransactionCategory.shopping => 'Compras',
  TransactionCategory.salary => 'Salário',
  TransactionCategory.education => 'Educação',
  TransactionCategory.other => 'Outros',
};
