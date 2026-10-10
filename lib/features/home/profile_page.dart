import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import '../accounts/account_store.dart';
import '../cards/card_store.dart';
import '../planning/planning_store.dart';
import '../transactions/transaction_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _deleteData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar todos os dados?'),
        content: const Text(
          'Isso removerá contas, cartões, movimentações, metas e limites deste aparelho e da sua conta online. Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar tudo'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await Future.wait([
      AccountStore.instance.clearAll(),
      CardStore.instance.clearAll(),
      TransactionStore.instance.clearAll(),
      PlanningStore.instance.clearAll(),
    ]);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todos os dados foram apagados.')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AtlasColors.background,
    appBar: AppBar(title: const Text('Perfil')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 36,
          backgroundColor: AtlasColors.surface,
          child: Icon(Icons.person_outline_rounded, color: AtlasColors.green, size: 34),
        ),
        const SizedBox(height: 14),
        const Text(
          'Perfil local',
          textAlign: TextAlign.center,
          style: TextStyle(color: AtlasColors.white, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Seus dados permanecem neste aparelho.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AtlasColors.textMuted),
        ),
        const SizedBox(height: 28),
        const _InfoTile(icon: Icons.storage_outlined, title: 'Armazenamento local', subtitle: 'Ativo'),
        const SizedBox(height: 12),
        const _InfoTile(icon: Icons.cloud_off_outlined, title: 'Conta online', subtitle: 'Ainda não configurada'),
        const SizedBox(height: 28),
        const Text(
          'O Atlas já pode ser usado para registrar e acompanhar suas finanças sem criar uma conta.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AtlasColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: _deleteData,
          icon: const Icon(Icons.delete_sweep_outlined),
          label: const Text('Apagar meus dados'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
        ),
      ],
    ),
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(18)),
    child: Row(
      children: [
        Icon(icon, color: AtlasColors.green),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: AtlasColors.textMuted)),
            ],
          ),
        ),
      ],
    ),
  );
}
