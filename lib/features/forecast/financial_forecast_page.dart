import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import '../../shared/formatters/currency_formatter.dart';
import '../transactions/transaction_model.dart';
import '../transactions/transaction_store.dart';
import 'financial_forecast.dart';

class FinancialForecastPage extends StatelessWidget {
  const FinancialForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TransactionStore.instance;
    final forecast = const FinancialForecastEngine().forMonth(
      transactions: store.transactions,
      now: DateTime.now(),
    );
    return Scaffold(
      backgroundColor: AtlasColors.background,
      appBar: AppBar(title: const Text('Previsão financeira')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          _Hero(forecast: forecast),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _Metric(label: 'A receber', value: forecast.expectedIncome, accent: AtlasColors.green)),
            const SizedBox(width: 12),
            Expanded(child: _Metric(label: 'A pagar', value: forecast.expectedExpenses, accent: AtlasColors.expense)),
          ]),
          const SizedBox(height: 28),
          const Text('Até o fim do mês', style: TextStyle(color: AtlasColors.white, fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (forecast.commitments.isEmpty)
            const _Empty()
          else
            ...forecast.commitments.map((item) => _Commitment(transaction: item)),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.forecast});
  final FinancialForecast forecast;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(gradient: AtlasColors.heroGradient, borderRadius: BorderRadius.circular(28)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Saldo projetado', style: TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Text(CurrencyFormatter.brl(forecast.projectedBalance), style: const TextStyle(color: AtlasColors.white, fontSize: 34, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text('Saldo atual: ${CurrencyFormatter.brl(forecast.currentBalance)}', style: const TextStyle(color: Color(0xFFD7F9E9), fontSize: 12)),
    ]),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.accent});
  final String label;
  final double value;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AtlasColors.textMuted, fontSize: 12)),
      const SizedBox(height: 6),
      Text(CurrencyFormatter.brl(value), style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w800)),
    ]),
  );
}

class _Commitment extends StatelessWidget {
  const _Commitment({required this.transaction});
  final AtlasTransaction transaction;
  @override
  Widget build(BuildContext context) {
    final expense = transaction.type == TransactionType.expense;
    final accent = expense ? AtlasColors.expense : AtlasColors.green;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Icon(expense ? Icons.south_east_rounded : Icons.north_east_rounded, color: accent),
        const SizedBox(width: 12),
        Expanded(child: Text(transaction.description, style: const TextStyle(color: AtlasColors.white, fontWeight: FontWeight.w700))),
        Text(CurrencyFormatter.brl(transaction.amount), style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: AtlasColors.surface, borderRadius: BorderRadius.circular(20)),
    child: const Text('Nenhum compromisso futuro registrado para este mês.', textAlign: TextAlign.center, style: TextStyle(color: AtlasColors.textMuted)),
  );
}
