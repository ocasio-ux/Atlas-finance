import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import '../../shared/formatters/currency_formatter.dart';
import 'new_transaction_page.dart';
import 'transaction_model.dart';
import 'transaction_store.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final store = TransactionStore.instance;
  final searchController = TextEditingController();
  TransactionType? type;
  TransactionCategory? category;
  DateTimeRange? period;

  @override
  void initState() {
    super.initState();
    store.addListener(_refresh);
  }

  @override
  void dispose() {
    store.removeListener(_refresh);
    searchController.dispose();
    super.dispose();
  }

  void _refresh() => mounted ? setState(() {}) : null;

  List<AtlasTransaction> get filtered {
    final query = searchController.text.trim().toLowerCase();
    return store.transactions.where((item) {
      if (query.isNotEmpty && !item.description.toLowerCase().contains(query)) return false;
      if (type != null && item.type != type) return false;
      if (category != null && item.category != category) return false;
      if (period != null) {
        final start = DateTime(period!.start.year, period!.start.month, period!.start.day);
        final end = DateTime(period!.end.year, period!.end.month, period!.end.day, 23, 59, 59, 999);
        if (item.createdAt.isBefore(start) || item.createdAt.isAfter(end)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickPeriod() async {
    final value = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: period,
    );
    if (value != null) setState(() => period = value);
  }

  void _clear() {
    searchController.clear();
    setState(() {
      type = null;
      category = null;
      period = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = filtered;
    return Scaffold(
      backgroundColor: AtlasColors.background,
      appBar: AppBar(title: const Text('Histórico')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Buscar movimentação'),
            ),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _FilterMenu<TransactionType>(label: type == null ? 'Tipo' : _typeLabel(type!), value: type, values: TransactionType.values, labelFor: _typeLabel, onChanged: (value) => setState(() => type = value)),
              _FilterMenu<TransactionCategory>(label: category == null ? 'Categoria' : _categoryLabel(category!), value: category, values: TransactionCategory.values, labelFor: _categoryLabel, onChanged: (value) => setState(() => category = value)),
              FilterChip(label: Text(period == null ? 'Período' : '${_date(period!.start)} – ${_date(period!.end)}'), selected: period != null, onSelected: (_) => _pickPeriod()),
              if (type != null || category != null || period != null || searchController.text.isNotEmpty)
                ActionChip(label: const Text('Limpar'), avatar: const Icon(Icons.close_rounded, size: 18), onPressed: _clear),
            ]),
            const SizedBox(height: 22),
            Text('${items.length} movimentaç${items.length == 1 ? 'ão' : 'ões'}', style: const TextStyle(color: AtlasColors.textMuted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            if (items.isEmpty)
              const _EmptyHistory()
            else
              ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _HistoryTile(transaction: item))),
          ],
        ),
      ),
    );
  }
}

class _FilterMenu<T> extends StatelessWidget {
  const _FilterMenu({required this.label, required this.value, required this.values, required this.labelFor, required this.onChanged});
  final String label;
  final T? value;
  final List<T> values;
  final String Function(T) labelFor;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => PopupMenuButton<T?>(
        initialValue: value,
        onSelected: onChanged,
        itemBuilder: (_) => [PopupMenuItem<T?>(value: null, child: const Text('Todos')), ...values.map((item) => PopupMenuItem<T?>(value: item, child: Text(labelFor(item))))],
        child: Chip(label: Text(label), avatar: const Icon(Icons.tune_rounded, size: 18)),
      );
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.transaction});
  final AtlasTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final expense = transaction.type == TransactionType.expense;
    final income = transaction.type == TransactionType.income;
    final accent = expense ? AtlasColors.expense : AtlasColors.green;
    final prefix = expense ? '- ' : income ? '+ ' : '';
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => NewTransactionPage(transaction: transaction))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Icon(expense ? Icons.arrow_downward_rounded : income ? Icons.arrow_upward_rounded : Icons.swap_horiz_rounded, color: accent),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(transaction.description, style: const TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text('${_categoryLabel(transaction.category)} • ${_date(transaction.createdAt)}', style: const TextStyle(color: AtlasColors.textMuted, fontSize: 12))])),
          Text('$prefix${CurrencyFormatter.brl(transaction.amount)}', style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(22)), child: const Column(children: [Icon(Icons.search_off_rounded, color: AtlasColors.green, size: 34), SizedBox(height: 10), Text('Nada encontrado', style: TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Tente ajustar os filtros ou a busca.', style: TextStyle(color: AtlasColors.textMuted))]));
}

String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
String _typeLabel(TransactionType value) => switch (value) { TransactionType.expense => 'Despesas', TransactionType.income => 'Receitas', TransactionType.transfer => 'Transferências' };
String _categoryLabel(TransactionCategory value) => switch (value) { TransactionCategory.food => 'Alimentação', TransactionCategory.transport => 'Transporte', TransactionCategory.housing => 'Moradia', TransactionCategory.health => 'Saúde', TransactionCategory.leisure => 'Lazer', TransactionCategory.shopping => 'Compras', TransactionCategory.salary => 'Salário', TransactionCategory.education => 'Educação', TransactionCategory.other => 'Outros' };
