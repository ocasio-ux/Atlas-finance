import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';

enum TransactionType { expense, income, transfer }

class NewTransactionPage extends StatefulWidget {
  const NewTransactionPage({super.key});

  @override
  State<NewTransactionPage> createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  TransactionType type = TransactionType.expense;
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

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
        title: const Text(
          'Nova movimentação',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            const _OptionTile(
              icon: Icons.category_outlined,
              title: 'Categoria',
              subtitle: 'Selecionar categoria',
            ),
            const SizedBox(height: 12),
            const _OptionTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Conta ou cartão',
              subtitle: 'Selecionar origem',
            ),
            const SizedBox(height: 12),
            const _OptionTile(
              icon: Icons.calendar_today_outlined,
              title: 'Data',
              subtitle: 'Hoje',
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  'Salvar movimentação',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onChanged});

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? selectedColor.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: selected ? selectedColor : AtlasColors.textMuted),
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
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AtlasColors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AtlasColors.green),
        filled: true,
        fillColor: AtlasColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AtlasColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                    Text(title, style: const TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AtlasColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AtlasColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}