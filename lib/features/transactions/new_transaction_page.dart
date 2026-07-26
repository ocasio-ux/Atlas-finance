import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import '../../shared/formatters/currency_formatter.dart';
import '../accounts/account_model.dart';
import '../accounts/account_store.dart';
import '../cards/card_store.dart';
import 'transaction_model.dart';
import 'transaction_store.dart';

class NewTransactionPage extends StatefulWidget {
  const NewTransactionPage({super.key, this.transaction});

  final AtlasTransaction? transaction;

  @override
  State<NewTransactionPage> createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  late TransactionType type;
  late TransactionCategory category;
  TransactionSourceType? sourceType;
  String? sourceId;
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  bool saving = false;

  bool get editing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    type = transaction?.type ?? TransactionType.expense;
    category = transaction?.category ?? TransactionCategory.other;
    sourceType = transaction?.sourceType;
    sourceId = transaction?.sourceId;
    if (transaction != null) {
      amountController.text = transaction.amount.toStringAsFixed(2).replaceAll('.', ',');
      descriptionController.text = transaction.description;
    }
    AccountStore.instance.load().then((_) => _refresh());
    CardStore.instance.load().then((_) => _refresh());
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final amount = CurrencyFormatter.parseBrl(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um valor válido.')),
      );
      return;
    }

    setState(() => saving = true);
    final existing = widget.transaction;
    final now = DateTime.now();
    final transaction = AtlasTransaction(
      id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
      type: type,
      amount: amount,
      description: descriptionController.text.trim().isEmpty
          ? _defaultDescription(type)
          : descriptionController.text.trim(),
      createdAt: existing?.createdAt ?? now,
      category: category,
      sourceType: sourceType,
      sourceId: sourceId,
    );

    if (editing) {
      await TransactionStore.instance.update(transaction);
    } else {
      await TransactionStore.instance.add(transaction);
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final existing = widget.transaction;
    if (existing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir movimentação?'),
        content: const Text('Essa ação remove a movimentação deste aparelho.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmed != true) return;
    await TransactionStore.instance.delete(existing.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _chooseCategory() async {
    final selected = await showModalBottomSheet<TransactionCategory>(
      context: context,
      backgroundColor: AtlasColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          children: TransactionCategory.values.map((item) => ListTile(
            leading: Icon(_categoryIcon(item), color: AtlasColors.green),
            title: Text(_categoryLabel(item), style: const TextStyle(color: AtlasColors.white)),
            trailing: item == category ? const Icon(Icons.check_rounded, color: AtlasColors.green) : null,
            onTap: () => Navigator.pop(context, item),
          )).toList(),
        ),
      ),
    );
    if (selected != null) setState(() => category = selected);
  }

  Future<void> _chooseSource() async {
    final accounts = AccountStore.instance.accounts;
    final cards = CardStore.instance.cards;
    final selected = await showModalBottomSheet<_SourceSelection>(
      context: context,
      backgroundColor: AtlasColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          children: [
            ListTile(
              leading: const Icon(Icons.remove_circle_outline, color: AtlasColors.textMuted),
              title: const Text('Sem conta ou cartão', style: TextStyle(color: AtlasColors.white)),
              onTap: () => Navigator.pop(context, const _SourceSelection(null, null)),
            ),
            if (accounts.isNotEmpty) const _SourceHeader('Contas'),
            ...accounts.map((account) => ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: AtlasColors.green),
              title: Text(account.name, style: const TextStyle(color: AtlasColors.white)),
              subtitle: Text(_accountTypeLabel(account.type), style: const TextStyle(color: AtlasColors.textMuted)),
              trailing: sourceType == TransactionSourceType.account && sourceId == account.id ? const Icon(Icons.check_rounded, color: AtlasColors.green) : null,
              onTap: () => Navigator.pop(context, _SourceSelection(TransactionSourceType.account, account.id)),
            )),
            if (cards.isNotEmpty) const _SourceHeader('Cartões'),
            ...cards.map((card) => ListTile(
              leading: const Icon(Icons.credit_card_rounded, color: AtlasColors.green),
              title: Text(card.name, style: const TextStyle(color: AtlasColors.white)),
              subtitle: Text(card.lastFourDigits.isEmpty ? 'Cartão' : 'Final ${card.lastFourDigits}', style: const TextStyle(color: AtlasColors.textMuted)),
              trailing: sourceType == TransactionSourceType.card && sourceId == card.id ? const Icon(Icons.check_rounded, color: AtlasColors.green) : null,
              onTap: () => Navigator.pop(context, _SourceSelection(TransactionSourceType.card, card.id)),
            )),
            if (accounts.isEmpty && cards.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Cadastre uma conta ou cartão para vinculá-lo às movimentações.', textAlign: TextAlign.center, style: TextStyle(color: AtlasColors.textMuted)),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        sourceType = selected.type;
        sourceId = selected.id;
      });
    }
  }

  String get _sourceLabel {
    if (sourceType == TransactionSourceType.account && sourceId != null) {
      return AccountStore.instance.findById(sourceId!)?.name ?? 'Conta não encontrada';
    }
    if (sourceType == TransactionSourceType.card && sourceId != null) {
      return CardStore.instance.findById(sourceId!)?.name ?? 'Cartão não encontrado';
    }
    return AccountStore.instance.accounts.isEmpty && CardStore.instance.cards.isEmpty
        ? 'Nenhum cadastrado ainda'
        : 'Não selecionado';
  }

  String _defaultDescription(TransactionType value) => switch (value) {
        TransactionType.expense => 'Despesa',
        TransactionType.income => 'Receita',
        TransactionType.transfer => 'Transferência',
      };

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtlasColors.background,
      appBar: AppBar(
        backgroundColor: AtlasColors.background,
        foregroundColor: AtlasColors.white,
        elevation: 0,
        title: Text(editing ? 'Editar movimentação' : 'Nova movimentação', style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [if (editing) IconButton(onPressed: _delete, tooltip: 'Excluir', icon: const Icon(Icons.delete_outline_rounded, color: AtlasColors.expense))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _TypeSelector(selected: type, onChanged: (value) => setState(() => type = value)),
            const SizedBox(height: 28),
            const Text('Valor', style: TextStyle(color: AtlasColors.textMuted, fontSize: 14)),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AtlasColors.white, fontSize: 38, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(prefixText: 'R\$ ', prefixStyle: TextStyle(color: AtlasColors.white, fontSize: 38, fontWeight: FontWeight.w700), hintText: '0,00', hintStyle: TextStyle(color: AtlasColors.textMuted), border: InputBorder.none),
            ),
            const SizedBox(height: 20),
            _AtlasField(controller: descriptionController, label: 'Descrição', hint: 'Ex.: Supermercado', icon: Icons.edit_outlined),
            const SizedBox(height: 12),
            _OptionTile(icon: _categoryIcon(category), title: 'Categoria', subtitle: _categoryLabel(category), onTap: _chooseCategory),
            const SizedBox(height: 12),
            _OptionTile(icon: Icons.account_balance_wallet_outlined, title: 'Conta ou cartão', subtitle: _sourceLabel, onTap: _chooseSource),
            const SizedBox(height: 12),
            const _OptionTile(icon: Icons.calendar_today_outlined, title: 'Data', subtitle: 'Hoje'),
            const SizedBox(height: 28),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: saving ? null : _save,
                icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_rounded),
                label: Text(saving ? 'Salvando...' : editing ? 'Salvar alterações' : 'Salvar movimentação', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(backgroundColor: AtlasColors.green, foregroundColor: AtlasColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceSelection {
  const _SourceSelection(this.type, this.id);
  final TransactionSourceType? type;
  final String? id;
}

class _SourceHeader extends StatelessWidget {
  const _SourceHeader(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
    child: Text(label, style: const TextStyle(color: AtlasColors.textMuted, fontWeight: FontWeight.w700)),
  );
}

String _accountTypeLabel(AccountType type) => switch (type) {
  AccountType.checking => 'Conta corrente',
  AccountType.savings => 'Poupança',
  AccountType.wallet => 'Carteira digital',
  AccountType.cash => 'Dinheiro',
};

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

IconData _categoryIcon(TransactionCategory category) => switch (category) {
  TransactionCategory.food => Icons.restaurant_outlined,
  TransactionCategory.transport => Icons.directions_car_outlined,
  TransactionCategory.housing => Icons.home_outlined,
  TransactionCategory.health => Icons.favorite_border_rounded,
  TransactionCategory.leisure => Icons.sports_esports_outlined,
  TransactionCategory.shopping => Icons.shopping_bag_outlined,
  TransactionCategory.salary => Icons.payments_outlined,
  TransactionCategory.education => Icons.school_outlined,
  TransactionCategory.other => Icons.category_outlined,
};

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onChanged});
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(18)),
    child: Row(children: [
      _TypeButton(label: 'Despesa', icon: Icons.arrow_downward_rounded, selected: selected == TransactionType.expense, selectedColor: AtlasColors.expense, onTap: () => onChanged(TransactionType.expense)),
      _TypeButton(label: 'Receita', icon: Icons.arrow_upward_rounded, selected: selected == TransactionType.income, selectedColor: AtlasColors.green, onTap: () => onChanged(TransactionType.income)),
      _TypeButton(label: 'Transferir', icon: Icons.swap_horiz_rounded, selected: selected == TransactionType.transfer, selectedColor: AtlasColors.green, onTap: () => onChanged(TransactionType.transfer)),
    ]),
  );
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({required this.label, required this.icon, required this.selected, required this.selectedColor, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(color: selected ? selectedColor.withValues(alpha: 0.18) : Colors.transparent, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [Icon(icon, size: 20, color: selected ? selectedColor : AtlasColors.textMuted), const SizedBox(height: 4), Text(label, style: TextStyle(color: selected ? AtlasColors.white : AtlasColors.textMuted, fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500))]),
    ),
  ));
}

class _AtlasField extends StatelessWidget {
  const _AtlasField({required this.controller, required this.label, required this.hint, required this.icon});
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  @override
  Widget build(BuildContext context) => TextField(controller: controller, style: const TextStyle(color: AtlasColors.white), decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon, color: AtlasColors.green)));
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.icon, required this.title, required this.subtitle, this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: AtlasColors.green.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: AtlasColors.green)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: AtlasColors.textMuted, fontSize: 13))])),
        if (onTap != null) const Icon(Icons.chevron_right_rounded, color: AtlasColors.textMuted),
      ]),
    ),
  );
}
