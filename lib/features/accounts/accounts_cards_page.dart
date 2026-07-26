import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import '../../shared/formatters/currency_formatter.dart';
import '../cards/card_model.dart';
import '../cards/card_store.dart';
import 'account_model.dart';
import 'account_store.dart';

class AccountsCardsPage extends StatefulWidget {
  const AccountsCardsPage({super.key});

  @override
  State<AccountsCardsPage> createState() => _AccountsCardsPageState();
}

class _AccountsCardsPageState extends State<AccountsCardsPage> {
  final accounts = AccountStore.instance;
  final cards = CardStore.instance;

  @override
  void initState() {
    super.initState();
    accounts.addListener(_refresh);
    cards.addListener(_refresh);
    accounts.load();
    cards.load();
  }

  @override
  void dispose() {
    accounts.removeListener(_refresh);
    cards.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _addAccount() async {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    var type = AccountType.checking;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nova conta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome', hintText: 'Ex.: Nubank')),
              const SizedBox(height: 12),
              DropdownButtonFormField<AccountType>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: AccountType.values.map((item) => DropdownMenuItem(value: item, child: Text(_accountTypeLabel(item)))).toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => type = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(controller: balanceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Saldo inicial', prefixText: 'R\$ ')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
          ],
        ),
      ),
    );
    if (saved != true) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    await accounts.add(AtlasAccount(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      type: type,
      initialBalance: CurrencyFormatter.parseBrl(balanceController.text) ?? 0,
    ));
  }

  Future<void> _addCard() async {
    final nameController = TextEditingController();
    final digitsController = TextEditingController();
    final limitController = TextEditingController();
    final closingController = TextEditingController();
    final dueController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo cartão'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome', hintText: 'Ex.: Nubank')),
              const SizedBox(height: 12),
              TextField(controller: digitsController, keyboardType: TextInputType.number, maxLength: 4, decoration: const InputDecoration(labelText: 'Últimos 4 dígitos')),
              TextField(controller: limitController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Limite', prefixText: 'R\$ ')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: closingController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fecha dia'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: dueController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Vence dia'))),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
        ],
      ),
    );
    if (saved != true) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    final closing = int.tryParse(closingController.text) ?? 1;
    final due = int.tryParse(dueController.text) ?? 10;
    await cards.add(AtlasCard(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      lastFourDigits: digitsController.text.trim(),
      closingDay: closing.clamp(1, 31),
      dueDay: due.clamp(1, 31),
      limit: CurrencyFormatter.parseBrl(limitController.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtlasColors.background,
      appBar: AppBar(
        backgroundColor: AtlasColors.background,
        foregroundColor: AtlasColors.white,
        title: const Text('Contas e cartões', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _SectionHeader(title: 'Contas', action: 'Adicionar', onTap: _addAccount),
          const SizedBox(height: 12),
          if (accounts.accounts.isEmpty)
            const _EmptyCard(text: 'Nenhuma conta cadastrada.')
          else
            ...accounts.accounts.map((account) => _SourceCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: account.name,
                  subtitle: _accountTypeLabel(account.type),
                  trailing: CurrencyFormatter.brl(account.initialBalance),
                )),
          const SizedBox(height: 28),
          _SectionHeader(title: 'Cartões', action: 'Adicionar', onTap: _addCard),
          const SizedBox(height: 12),
          if (cards.cards.isEmpty)
            const _EmptyCard(text: 'Nenhum cartão cadastrado.')
          else
            ...cards.cards.map((card) => _SourceCard(
                  icon: Icons.credit_card_rounded,
                  title: card.name,
                  subtitle: card.lastFourDigits.isEmpty ? 'Fecha dia ${card.closingDay} • vence dia ${card.dueDay}' : 'Final ${card.lastFourDigits} • vence dia ${card.dueDay}',
                  trailing: card.limit == null ? 'Sem limite' : CurrencyFormatter.brl(card.limit!),
                )),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action, required this.onTap});
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, style: const TextStyle(color: AtlasColors.white, fontSize: 20, fontWeight: FontWeight.w800))),
        TextButton.icon(onPressed: onTap, icon: const Icon(Icons.add_rounded), label: Text(action)),
      ]);
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.icon, required this.title, required this.subtitle, required this.trailing});
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AtlasColors.green.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: AtlasColors.green)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(color: AtlasColors.textMuted, fontSize: 12)),
          ])),
          Text(trailing, style: const TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(18)),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AtlasColors.textMuted)),
      );
}

String _accountTypeLabel(AccountType type) => switch (type) {
      AccountType.checking => 'Conta corrente',
      AccountType.savings => 'Poupança',
      AccountType.wallet => 'Carteira digital',
      AccountType.cash => 'Dinheiro',
    };
