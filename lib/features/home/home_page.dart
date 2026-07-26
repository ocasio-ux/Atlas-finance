import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import '../transactions/new_transaction_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openNewTransaction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NewTransactionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AtlasColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
          children: [
            const _Header(),
            const SizedBox(height: 30),
            const _BalanceCard(),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _MoneyCard(
                    title: 'Receitas',
                    value: 'R\$ 0,00',
                    icon: Icons.arrow_upward_rounded,
                    accent: AtlasColors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MoneyCard(
                    title: 'Despesas',
                    value: 'R\$ 0,00',
                    icon: Icons.arrow_downward_rounded,
                    accent: AtlasColors.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _SectionTitle(title: 'Seu Atlas', action: 'Ver tudo'),
            const SizedBox(height: 12),
            const _AtlasAiCard(),
            const SizedBox(height: 28),
            const _SectionTitle(title: 'Visão geral'),
            const SizedBox(height: 12),
            const _OverviewCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewTransaction(context),
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
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ATLAS',
                style: TextStyle(
                  color: AtlasColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Seu dinheiro, mais claro.',
                style: TextStyle(color: AtlasColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: AtlasColors.surface,
          child: Icon(Icons.person_outline_rounded, color: AtlasColors.white),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AtlasColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: AtlasColors.white, size: 20),
              SizedBox(width: 8),
              Text('Saldo total', style: TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'R\$ 0,00',
            style: TextStyle(color: AtlasColors.white, fontSize: 36, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text('Atualizado agora', style: TextStyle(color: Color(0xFFD7F9E9), fontSize: 12)),
        ],
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({required this.title, required this.value, required this.icon, required this.accent});

  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(color: AtlasColors.textMuted, fontSize: 13)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: accent, fontSize: 19, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});
  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(color: AtlasColors.white, fontSize: 19, fontWeight: FontWeight.w800))),
        if (action != null) Text(action!, style: const TextStyle(color: AtlasColors.green, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}

class _AtlasAiCard extends StatelessWidget {
  const _AtlasAiCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF12B879), AtlasColors.greenDark],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Color(0x33FFFFFF),
            child: Icon(Icons.auto_awesome_rounded, color: AtlasColors.white),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sua gerente', style: TextStyle(color: AtlasColors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Converse com o Atlas sobre suas finanças.', style: TextStyle(color: Color(0xFFE2FFF1), fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AtlasColors.white),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(22)),
      child: const Column(
        children: [
          _OverviewRow(icon: Icons.receipt_long_outlined, label: 'Movimentações', value: '0'),
          Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, color: Color(0xFF39423B))),
          _OverviewRow(icon: Icons.category_outlined, label: 'Categorias', value: 'Em breve'),
          Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, color: Color(0xFF39423B))),
          _OverviewRow(icon: Icons.insights_outlined, label: 'Insights do Atlas', value: 'Em breve'),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AtlasColors.green, size: 21),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w600))),
        Text(value, style: const TextStyle(color: AtlasColors.textMuted, fontSize: 13)),
      ],
    );
  }
}