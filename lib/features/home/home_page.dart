import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import '../../shared/formatters/currency_formatter.dart';
import '../transactions/new_transaction_page.dart';
import '../transactions/transaction_model.dart';
import '../transactions/transaction_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final store = TransactionStore.instance;

  @override
  void initState() {
    super.initState();
    store.addListener(_refresh);
    store.load();
  }

  @override
  void dispose() {
    store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _openNewTransaction() async {
    await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const NewTransactionPage()));
  }

  Future<void> _openTransaction(AtlasTransaction transaction) async {
    await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => NewTransactionPage(transaction: transaction)));
  }

  @override
  Widget build(BuildContext context) {
    final recent = store.transactions.take(4).toList();
    return Scaffold(
      backgroundColor: AtlasColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
          children: [
            const _Header(),
            const SizedBox(height: 30),
            _BalanceCard(value: CurrencyFormatter.brl(store.balance)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _MoneyCard(title: 'Receitas', value: CurrencyFormatter.brl(store.income), icon: Icons.arrow_upward_rounded, accent: AtlasColors.green)),
              const SizedBox(width: 12),
              Expanded(child: _MoneyCard(title: 'Despesas', value: CurrencyFormatter.brl(store.expenses), icon: Icons.arrow_downward_rounded, accent: AtlasColors.expense)),
            ]),
            const SizedBox(height: 28),
            const _SectionTitle(title: 'Seu Atlas', action: 'Ver tudo'),
            const SizedBox(height: 12),
            const _AtlasAiCard(),
            const SizedBox(height: 28),
            _SectionTitle(title: 'Movimentações recentes', action: '${store.count} total'),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              const _EmptyTransactions()
            else
              ...recent.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TransactionTile(transaction: item, onTap: () => _openTransaction(item)),
                  )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewTransaction,
        backgroundColor: AtlasColors.green,
        foregroundColor: AtlasColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => const Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ATLAS', style: TextStyle(color: AtlasColors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 5)), SizedBox(height: 2), Text('Seu dinheiro, mais claro.', style: TextStyle(color: AtlasColors.textMuted, fontSize: 13))])), CircleAvatar(radius: 22, backgroundColor: AtlasColors.surface, child: Icon(Icons.person_outline_rounded, color: AtlasColors.white))]);
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.value});
  final String value;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: AtlasColors.heroGradient, borderRadius: BorderRadius.circular(28)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.account_balance_wallet_outlined, color: AtlasColors.white, size: 20), SizedBox(width: 8), Text('Saldo total', style: TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w600))]), const SizedBox(height: 16), Text(value, style: const TextStyle(color: AtlasColors.white, fontSize: 36, fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Dados salvos neste aparelho', style: TextStyle(color: Color(0xFFD7F9E9), fontSize: 12))]));
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({required this.title, required this.value, required this.icon, required this.accent});
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: accent.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: accent, size: 20)), const SizedBox(height: 18), Text(title, style: const TextStyle(color: AtlasColors.textMuted, fontSize: 13)), const SizedBox(height: 5), Text(value, style: TextStyle(color: accent, fontSize: 19, fontWeight: FontWeight.w800))]));
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});
  final String title;
  final String? action;
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: const TextStyle(color: AtlasColors.white, fontSize: 19, fontWeight: FontWeight.w800))), if (action != null) Text(action!, style: const TextStyle(color: AtlasColors.green, fontWeight: FontWeight.w700, fontSize: 13))]);
}

class _AtlasAiCard extends StatelessWidget {
  const _AtlasAiCard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF12B879), AtlasColors.greenDark]), borderRadius: BorderRadius.circular(26)), child: const Row(children: [CircleAvatar(radius: 25, backgroundColor: Color(0x33FFFFFF), child: Icon(Icons.auto_awesome_rounded, color: AtlasColors.white)), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Sua gerente', style: TextStyle(color: AtlasColors.white, fontSize: 17, fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Converse com o Atlas sobre suas finanças.', style: TextStyle(color: Color(0xFFE2FFF1), fontSize: 13))])), Icon(Icons.chevron_right_rounded, color: AtlasColors.white)]));
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(22)), child: const Column(children: [Icon(Icons.receipt_long_outlined, color: AtlasColors.green, size: 30), SizedBox(height: 10), Text('Nenhuma movimentação ainda', style: TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('Toque em Adicionar para registrar a primeira.', textAlign: TextAlign.center, style: TextStyle(color: AtlasColors.textMuted, fontSize: 13))]));
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.onTap});
  final AtlasTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final isIncome = transaction.type == TransactionType.income;
    final accent = isExpense ? AtlasColors.expense : AtlasColors.green;
    final icon = isExpense ? Icons.arrow_downward_rounded : isIncome ? Icons.arrow_upward_rounded : Icons.swap_horiz_rounded;
    final prefix = isExpense ? '- ' : isIncome ? '+ ' : '';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: accent.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: accent)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(transaction.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(_categoryLabel(transaction.category), style: const TextStyle(color: AtlasColors.textMuted, fontSize: 12))])),
          const SizedBox(width: 8),
          Text('$prefix${CurrencyFormatter.brl(transaction.amount)}', style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}

String _categoryLabel(TransactionCategory category) => switch (category) {
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
