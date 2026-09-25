import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import '../../core/finance/financial_commitment.dart';
import '../../shared/formatters/currency_formatter.dart';
import '../accounts/account_model.dart';
import '../accounts/account_store.dart';
import '../transactions/transaction_model.dart';
import '../transactions/transaction_store.dart';
import 'planning_models.dart';
import 'planning_store.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  final planning = PlanningStore.instance;
  final transactions = TransactionStore.instance;
  final accounts = AccountStore.instance;

  @override
  void initState() {
    super.initState();
    planning.addListener(_refresh);
    transactions.addListener(_refresh);
    accounts.addListener(_refresh);
    planning.load();
    transactions.load();
    accounts.load();
  }

  @override
  void dispose() {
    planning.removeListener(_refresh);
    transactions.removeListener(_refresh);
    accounts.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  double _spentThisMonth(TransactionCategory category) {
    final now = DateTime.now();
    return transactions.transactions
        .where(
          (item) =>
              item.type == TransactionType.expense &&
              item.category == category &&
              item.createdAt.year == now.year &&
              item.createdAt.month == now.month,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> _addBudget() async {
    var category = TransactionCategory.food;
    final amount = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo orçamento'),
        content: StatefulBuilder(
          builder: (context, setLocalState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TransactionCategory>(
                initialValue: category,
                items: TransactionCategory.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(_categoryLabel(item)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setLocalState(() => category = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Limite mensal'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    final value = double.tryParse(amount.text.replaceAll(',', '.'));
    if (value == null || value <= 0) return;
    await planning.saveBudget(
      AtlasBudget(
        id: 'budget-${category.name}',
        category: category,
        monthlyLimit: value,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _addCommitment() async {
    final title = TextEditingController();
    final amount = TextEditingController();
    var dueDate = DateTime.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Novo compromisso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex.: Aluguel',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: const Text('Vencimento'),
                subtitle: Text(_dateLabel(dueDate)),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selected != null) {
                    setLocalState(() => dueDate = DateTime(
                      selected.year,
                      selected.month,
                      selected.day,
                      23,
                      59,
                      59,
                    ));
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;
    final value = double.tryParse(amount.text.replaceAll(',', '.'));
    if (title.text.trim().isEmpty || value == null || value <= 0) return;

    await planning.saveCommitment(
      FinancialCommitment(
        id: 'commitment-' + DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.text.trim(),
        amount: value,
        dueDate: dueDate,
      ),
    );
  }

  Future<void> _payCommitment(FinancialCommitment commitment) async {
    final status = commitment.status(DateTime.now());
    if (status == FinancialCommitmentStatus.paid ||
        status == FinancialCommitmentStatus.cancelled) {
      return;
    }

    await accounts.load();
    if (!mounted) return;

    if (accounts.accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre uma conta antes de registrar o pagamento.'),
        ),
      );
      return;
    }

    final accountId = await showModalBottomSheet<String>(
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
                'Pagar compromisso',
                style: TextStyle(
                  color: AtlasColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                commitment.title +
                    ' • ' +
                    CurrencyFormatter.brl(commitment.amount),
                style: const TextStyle(color: AtlasColors.textMuted),
              ),
            ),
            ...accounts.accounts.map(
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
                onTap: () => Navigator.pop(context, account.id),
              ),
            ),
          ],
        ),
      ),
    );

    if (accountId == null) return;

    final account = accounts.findById(accountId);
    if (account == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar pagamento'),
        content: Text(
          'Registrar ' +
              CurrencyFormatter.brl(commitment.amount) +
              ' como despesa em ' +
              account.name +
              '?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final transactionId =
        'commitment-payment-' + DateTime.now().microsecondsSinceEpoch.toString();
    final now = DateTime.now();
    final transaction = AtlasTransaction(
      id: transactionId,
      type: TransactionType.expense,
      amount: commitment.amount,
      description: 'Pagamento: ' + commitment.title,
      createdAt: now,
      transactionDate: now,
      category: TransactionCategory.other,
      sourceType: TransactionSourceType.account,
      sourceId: accountId,
    );

    await transactions.add(transaction);
    await planning.settleCommitment(
      commitment.id,
      transactionId: transactionId,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compromisso marcado como pago.')),
    );
  }

  Future<void> _addGoal() async {
    final name = TextEditingController();
    final target = TextEditingController();
    final savedAmount = TextEditingController(text: '0');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nome da meta'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: target,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Valor alvo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: savedAmount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Já guardado'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    final targetValue = double.tryParse(target.text.replaceAll(',', '.'));
    final currentValue =
        double.tryParse(savedAmount.text.replaceAll(',', '.')) ?? 0;
    if (name.text.trim().isEmpty || targetValue == null || targetValue <= 0) {
      return;
    }
    await planning.saveGoal(
      AtlasGoal(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.text.trim(),
        targetAmount: targetValue,
        savedAmount: currentValue.clamp(0, targetValue),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AtlasColors.background,
    appBar: AppBar(title: const Text('Planejamento')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Header(title: 'Orçamentos', action: 'Adicionar', onTap: _addBudget),
        const SizedBox(height: 12),
        if (planning.budgets.isEmpty)
          const _Empty(text: 'Crie limites mensais por categoria.')
        else
          ...planning.budgets.map((budget) {
            final spent = _spentThisMonth(budget.category);
            final progress = budget.monthlyLimit <= 0
                ? 0.0
                : (spent / budget.monthlyLimit).clamp(0.0, 1.0);
            return _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _categoryLabel(budget.category),
                          style: const TextStyle(
                            color: AtlasColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${CurrencyFormatter.brl(spent)} / ${CurrencyFormatter.brl(budget.monthlyLimit)}',
                        style: const TextStyle(color: AtlasColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: progress),
                  if (spent > budget.monthlyLimit) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Limite excedido em ${CurrencyFormatter.brl(spent - budget.monthlyLimit)}',
                      style: const TextStyle(
                        color: AtlasColors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        const SizedBox(height: 28),
        _Header(
          title: 'Compromissos',
          action: 'Adicionar',
          onTap: _addCommitment,
        ),
        const SizedBox(height: 12),
        if (planning.commitments.isEmpty)
          const _Empty(
            text: 'Cadastre contas e pagamentos futuros para o Atlas considerar no planejamento.',
          )
        else
          ...planning.commitments.map((commitment) {
            final status = commitment.status(DateTime.now());
            final statusColor = switch (status) {
              FinancialCommitmentStatus.overdue => AtlasColors.expense,
              FinancialCommitmentStatus.paid => AtlasColors.green,
              FinancialCommitmentStatus.cancelled => AtlasColors.textMuted,
              FinancialCommitmentStatus.pending => AtlasColors.green,
            };
            return _Card(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withValues(alpha: 0.16),
                    child: Icon(Icons.receipt_long_outlined, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commitment.title,
                          style: const TextStyle(
                            color: AtlasColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.brl(commitment.amount) +
                              ' • ' +
                              _dateLabel(commitment.dueDate),
                          style: const TextStyle(color: AtlasColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _commitmentStatusLabel(status),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'pay') {
                        await _payCommitment(commitment);
                      } else if (value == 'cancel') {
                        await planning.cancelCommitment(commitment.id);
                      } else if (value == 'delete') {
                        await planning.deleteCommitment(commitment.id);
                      }
                    },
                    itemBuilder: (context) => [
                      if (status != FinancialCommitmentStatus.paid &&
                          status != FinancialCommitmentStatus.cancelled)
                        const PopupMenuItem(
                          value: 'pay',
                          child: Text('Marcar como pago'),
                        ),
                      if (status != FinancialCommitmentStatus.paid &&
                          status != FinancialCommitmentStatus.cancelled)
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text('Cancelar compromisso'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Excluir'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 28),
        _Header(title: 'Metas', action: 'Adicionar', onTap: _addGoal),
        const SizedBox(height: 12),
        if (planning.goals.isEmpty)
          const _Empty(text: 'Crie uma meta e acompanhe seu progresso.')
        else
          ...planning.goals.map(
            (goal) => _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          style: const TextStyle(
                            color: AtlasColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${(goal.progress * 100).round()}%',
                        style: const TextStyle(
                          color: AtlasColors.green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${CurrencyFormatter.brl(goal.savedAmount)} de ${CurrencyFormatter.brl(goal.targetAmount)}',
                    style: const TextStyle(color: AtlasColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: goal.progress),
                  const SizedBox(height: 8),
                  Text(
                    'Faltam ${CurrencyFormatter.brl(goal.remaining)}',
                    style: const TextStyle(
                      color: AtlasColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.action,
    required this.onTap,
  });
  final String title;
  final String action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: AtlasColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      TextButton(onPressed: onTap, child: Text(action)),
    ],
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AtlasColors.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => _Card(
    child: Text(text, style: const TextStyle(color: AtlasColors.textMuted)),
  );
}

String _dateLabel(DateTime date) =>
    date.day.toString().padLeft(2, '0') +
    '/' +
    date.month.toString().padLeft(2, '0') +
    '/' +
    date.year.toString();

String _commitmentStatusLabel(FinancialCommitmentStatus status) =>
    switch (status) {
      FinancialCommitmentStatus.pending => 'Pendente',
      FinancialCommitmentStatus.paid => 'Pago',
      FinancialCommitmentStatus.overdue => 'Atrasado',
      FinancialCommitmentStatus.cancelled => 'Cancelado',
    };

String _accountTypeLabel(AccountType type) => switch (type) {
  AccountType.checking => 'Conta corrente',
  AccountType.savings => 'Poupança',
  AccountType.wallet => 'Carteira digital',
  AccountType.cash => 'Dinheiro',
};

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
