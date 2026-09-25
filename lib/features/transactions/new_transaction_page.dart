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
  TransactionSourceType? destinationType;
  String? destinationId;
  late DateTime transactionDate;
  int installmentCount = 1;
  late TransactionRepeat repeat;
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
    destinationType = transaction?.destinationType;
    destinationId = transaction?.destinationId;
    transactionDate = transaction?.transactionDate ?? DateTime.now();
    repeat = transaction?.repeat ?? TransactionRepeat.none;
    if (transaction != null) {
      amountController.text = transaction.amount
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      descriptionController.text = transaction.description;
    }
    AccountStore.instance.load().then((_) => _refresh());
    CardStore.instance.load().then((_) => _refresh());
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final totalAmount = CurrencyFormatter.parseBrl(amountController.text);
    if (totalAmount == null || totalAmount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Digite um valor válido.')));
      return;
    }

    if (installmentCount > 1 &&
        (type != TransactionType.expense ||
            sourceType != TransactionSourceType.card)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parcelamento está disponível para compras no cartão.')),
      );
      return;
    }

    setState(() => saving = true);
    final existing = widget.transaction;
    if (repeat != TransactionRepeat.none && type == TransactionType.transfer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transferências não podem ser recorrentes.')),
      );
      setState(() => saving = false);
      return;
    }
    final now = DateTime.now();

    if (!editing && installmentCount > 1) {
      final seriesId = now.microsecondsSinceEpoch.toString();
      final totalCents = (totalAmount * 100).round();
      final baseCents = totalCents ~/ installmentCount;
      final remainder = totalCents % installmentCount;
      final installmentTransactions = List.generate(installmentCount, (index) {
        final cents = baseCents + (index < remainder ? 1 : 0);
        final date = _addMonths(transactionDate, index);
        return AtlasTransaction(
          id: '${seriesId}_${index + 1}',
          type: TransactionType.expense,
          amount: cents / 100,
          description: descriptionController.text.trim().isEmpty
              ? 'Compra parcelada'
              : descriptionController.text.trim(),
          createdAt: now,
          transactionDate: date,
          category: category,
          sourceType: sourceType,
          sourceId: sourceId,
          repeat: TransactionRepeat.none,
          seriesId: seriesId,
          installmentNumber: index + 1,
          installmentCount: installmentCount,
        );
      });

      await TransactionStore.instance.addAll(installmentTransactions);
    } else {
      final transaction = AtlasTransaction(
        id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
        type: type,
        amount: totalAmount,
        description: descriptionController.text.trim().isEmpty
            ? _defaultDescription(type)
            : descriptionController.text.trim(),
        createdAt: existing?.createdAt ?? now,
        transactionDate: transactionDate,
        category: category,
        sourceType: sourceType,
        sourceId: sourceId,
        destinationType: destinationType,
        destinationId: destinationId,
        installmentNumber: existing?.installmentNumber,
        installmentCount: existing?.installmentCount,
        seriesId: existing?.seriesId,
        repeat: repeat,
        cardInvoiceEndDate: existing?.cardInvoiceEndDate,
      );

      if (editing) {
        await TransactionStore.instance.update(transaction);
      } else {
        await TransactionStore.instance.add(transaction);
      }
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await TransactionStore.instance.delete(existing.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  DateTime _addMonths(DateTime date, int months) {
    final targetMonth = date.month - 1 + months;
    final year = date.year + targetMonth ~/ 12;
    final month = targetMonth % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(
      year,
      month,
      date.day.clamp(1, lastDay),
      date.hour,
      date.minute,
      date.second,
    );
  }

  Future<void> _chooseInstallments() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AtlasColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                'Parcelamento',
                style: TextStyle(color: AtlasColors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            ...List.generate(12, (index) => index + 1).map(
              (count) => ListTile(
                title: Text(
                  count == 1 ? 'À vista' : '$count vezes',
                  style: const TextStyle(color: AtlasColors.white),
                ),
                trailing: count == installmentCount
                    ? const Icon(Icons.check_rounded, color: AtlasColors.green)
                    : null,
                onTap: () => Navigator.pop(context, count),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => installmentCount = selected);
  }

  Future<void> _chooseRepeat() async {
    final selected = await showModalBottomSheet<TransactionRepeat>(
      context: context,
      backgroundColor: AtlasColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                'Repetição',
                style: TextStyle(
                  color: AtlasColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              title: const Text('Não repetir', style: TextStyle(color: AtlasColors.white)),
              trailing: repeat == TransactionRepeat.none
                  ? const Icon(Icons.check_rounded, color: AtlasColors.green)
                  : null,
              onTap: () => Navigator.pop(context, TransactionRepeat.none),
            ),
            ListTile(
              title: const Text('Todo mês', style: TextStyle(color: AtlasColors.white)),
              trailing: repeat == TransactionRepeat.monthly
                  ? const Icon(Icons.check_rounded, color: AtlasColors.green)
                  : null,
              onTap: () => Navigator.pop(context, TransactionRepeat.monthly),
            ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => repeat = selected);
  }

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: transactionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data da movimentação',
      cancelText: 'Cancelar',
      confirmText: 'Selecionar',
    );
    if (selected == null) return;
    setState(() {
      transactionDate = DateTime(selected.year, selected.month, selected.day, transactionDate.hour, transactionDate.minute, transactionDate.second);
    });
  }

  String _formattedTransactionDate() {
    final now = DateTime.now();
    final date = DateTime(transactionDate.year, transactionDate.month, transactionDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = date.difference(today).inDays;
    if (difference == 0) return 'Hoje';
    if (difference == -1) return 'Ontem';
    if (difference == 1) return 'Amanhã';
    return '${transactionDate.day.toString().padLeft(2, '0')}/${transactionDate.month.toString().padLeft(2, '0')}/${transactionDate.year}';
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
          children: TransactionCategory.values
              .map(
                (item) => ListTile(
                  leading: Icon(_categoryIcon(item), color: AtlasColors.green),
                  title: Text(
                    _categoryLabel(item),
                    style: const TextStyle(color: AtlasColors.white),
                  ),
                  trailing: item == category
                      ? const Icon(
                          Icons.check_rounded,
                          color: AtlasColors.green,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, item),
                ),
              )
              .toList(),
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
              leading: const Icon(
                Icons.remove_circle_outline,
                color: AtlasColors.textMuted,
              ),
              title: const Text(
                'Sem conta ou cartão',
                style: TextStyle(color: AtlasColors.white),
              ),
              onTap: () =>
                  Navigator.pop(context, const _SourceSelection(null, null)),
            ),
            if (accounts.isNotEmpty) const _SourceHeader('Contas'),
            ...accounts.map(
              (account) => ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AtlasColors.green,
                ),
                title: Text(
                  account.name,
                  style: const TextStyle(color: AtlasColors.white),
                ),
                subtitle: Text(
                  _accountTypeLabel(account.type),
                  style: const TextStyle(color: AtlasColors.textMuted),
                ),
                trailing:
                    sourceType == TransactionSourceType.account &&
                        sourceId == account.id
                    ? const Icon(Icons.check_rounded, color: AtlasColors.green)
                    : null,
                onTap: () => Navigator.pop(
                  context,
                  _SourceSelection(TransactionSourceType.account, account.id),
                ),
              ),
            ),
            if (cards.isNotEmpty) const _SourceHeader('Cartões'),
            ...cards.map(
              (card) => ListTile(
                leading: const Icon(
                  Icons.credit_card_rounded,
                  color: AtlasColors.green,
                ),
                title: Text(
                  card.name,
                  style: const TextStyle(color: AtlasColors.white),
                ),
                subtitle: Text(
                  card.lastFourDigits.isEmpty
                      ? 'Cartão'
                      : 'Final ${card.lastFourDigits}',
                  style: const TextStyle(color: AtlasColors.textMuted),
                ),
                trailing:
                    sourceType == TransactionSourceType.card &&
                        sourceId == card.id
                    ? const Icon(Icons.check_rounded, color: AtlasColors.green)
                    : null,
                onTap: () => Navigator.pop(
                  context,
                  _SourceSelection(TransactionSourceType.card, card.id),
                ),
              ),
            ),
            if (accounts.isEmpty && cards.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Cadastre uma conta ou cartão para vinculá-lo às movimentações.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AtlasColors.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        sourceType = selected.type;
        sourceId = selected.id;
        if (selected.type != TransactionSourceType.card) {
          installmentCount = 1;
        }
      });
    }
  }

  String get _destinationLabel {
    if (destinationType == TransactionSourceType.account && destinationId != null) {
      return AccountStore.instance.findById(destinationId!)?.name ??
          'Conta não encontrada';
    }
    if (destinationType == TransactionSourceType.card && destinationId != null) {
      return CardStore.instance.findById(destinationId!)?.name ??
          'Cartão não encontrado';
    }
    return 'Não selecionado';
  }

  Future<void> _chooseDestination() async {
    final accounts = AccountStore.instance.accounts;
    final selected = await showModalBottomSheet<_SourceSelection>(
      context: context,
      backgroundColor: AtlasColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          children: [
            if (accounts.isNotEmpty) const _SourceHeader('Contas'),
            ...accounts.where((account) => account.id != sourceId).map(
              (account) => ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AtlasColors.green,
                ),
                title: Text(
                  account.name,
                  style: const TextStyle(color: AtlasColors.white),
                ),
                subtitle: Text(
                  _accountTypeLabel(account.type),
                  style: const TextStyle(color: AtlasColors.textMuted),
                ),
                trailing: destinationType == TransactionSourceType.account &&
                        destinationId == account.id
                    ? const Icon(Icons.check_rounded, color: AtlasColors.green)
                    : null,
                onTap: () => Navigator.pop(
                  context,
                  _SourceSelection(
                    TransactionSourceType.account,
                    account.id,
                  ),
                ),
              ),
            ),
            if (accounts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Cadastre uma segunda conta para fazer uma transferência.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AtlasColors.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        destinationType = selected.type;
        destinationId = selected.id;
      });
    }
  }

  String get _sourceLabel {
    if (sourceType == TransactionSourceType.account && sourceId != null) {
      return AccountStore.instance.findById(sourceId!)?.name ??
          'Conta não encontrada';
    }
    if (sourceType == TransactionSourceType.card && sourceId != null) {
      return CardStore.instance.findById(sourceId!)?.name ??
          'Cartão não encontrado';
    }
    return AccountStore.instance.accounts.isEmpty &&
            CardStore.instance.cards.isEmpty
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
        title: Text(
          editing ? 'Editar movimentação' : 'Nova movimentação',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (editing)
            IconButton(
              onPressed: _delete,
              tooltip: 'Excluir',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AtlasColors.expense,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _TypeSelector(
              selected: type,
              onChanged: (value) => setState(() => type = value),
            ),
            const SizedBox(height: 28),
            const Text(
              'Valor',
              style: TextStyle(color: AtlasColors.textMuted, fontSize: 14),
            ),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                color: AtlasColors.white,
                fontSize: 38,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(
                  color: AtlasColors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                ),
                hintText: '0,00',
                hintStyle: TextStyle(color: AtlasColors.textMuted),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),
            _AtlasField(
              controller: descriptionController,
              label: 'Descrição',
              hint: 'Ex.: Supermercado',
              icon: Icons.edit_outlined,
            ),
            const SizedBox(height: 12),
            _OptionTile(
              icon: _categoryIcon(category),
              title: 'Categoria',
              subtitle: _categoryLabel(category),
              onTap: _chooseCategory,
            ),
            const SizedBox(height: 12),
            _OptionTile(
              icon: Icons.account_balance_wallet_outlined,
              title: type == TransactionType.transfer ? 'Origem' : 'Conta ou cartão',
              subtitle: _sourceLabel,
              onTap: _chooseSource,
            ),
            if (type == TransactionType.transfer) ...[
              const SizedBox(height: 12),
              _OptionTile(
                icon: Icons.swap_horiz_rounded,
                title: 'Destino',
                subtitle: _destinationLabel,
                onTap: _chooseDestination,
              ),
            ],
            if (type != TransactionType.transfer && installmentCount == 1) ...[
              const SizedBox(height: 12),
              _OptionTile(
                icon: Icons.repeat_rounded,
                title: 'Repetição',
                subtitle: repeat == TransactionRepeat.monthly ? 'Todo mês' : 'Não repetir',
                onTap: _chooseRepeat,
              ),
            ],
            if (!editing &&
                type == TransactionType.expense &&
                sourceType == TransactionSourceType.card) ...[
              const SizedBox(height: 12),
              _OptionTile(
                icon: Icons.credit_card_outlined,
                title: 'Parcelamento',
                subtitle: installmentCount == 1
                    ? 'À vista'
                    : '$installmentCount vezes • primeira parcela hoje',
                onTap: _chooseInstallments,
              ),
            ],
            const SizedBox(height: 12),
            _OptionTile(
              icon: Icons.calendar_today_outlined,
              title: 'Data',
              subtitle: _formattedTransactionDate(),
              onTap: _chooseDate,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  saving
                      ? 'Salvando...'
                      : editing
                      ? 'Salvar alterações'
                      : 'Salvar movimentação',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AtlasColors.green,
                  foregroundColor: AtlasColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
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
    child: Text(
      label,
      style: const TextStyle(
        color: AtlasColors.textMuted,
        fontWeight: FontWeight.w700,
      ),
    ),
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
    decoration: BoxDecoration(
      color: AtlasColors.surface,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        _TypeButton(
          label: 'Despesa',
          icon: Icons.arrow_downward_rounded,
          selected: selected == TransactionType.expense,
          selectedColor: AtlasColors.expense,
          onTap: () => onChanged(TransactionType.expense),
        ),
        _TypeButton(
          label: 'Receita',
          icon: Icons.arrow_upward_rounded,
          selected: selected == TransactionType.income,
          selectedColor: AtlasColors.green,
          onTap: () => onChanged(TransactionType.income),
        ),
        _TypeButton(
          label: 'Transferir',
          icon: Icons.swap_horiz_rounded,
          selected: selected == TransactionType.transfer,
          selectedColor: AtlasColors.green,
          onTap: () => onChanged(TransactionType.transfer),
        ),
      ],
    ),
  );
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? selectedColor : AtlasColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? AtlasColors.white : AtlasColors.textMuted,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AtlasField extends StatelessWidget {
  const _AtlasField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: const TextStyle(color: AtlasColors.white),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AtlasColors.green),
    ),
  );
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
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
      decoration: BoxDecoration(
        color: AtlasColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AtlasColors.green.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AtlasColors.green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AtlasColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AtlasColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.chevron_right_rounded,
              color: AtlasColors.textMuted,
            ),
        ],
      ),
    ),
  );
}
