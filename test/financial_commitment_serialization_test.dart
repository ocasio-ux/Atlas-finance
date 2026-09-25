import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/core/finance/financial_commitment.dart';

void main() {
  test('commitment serializes and restores its financial state', () {
    final original = FinancialCommitment(
      id: 'c1',
      title: 'Aluguel',
      amount: 1500,
      dueDate: DateTime(2026, 10, 5, 23, 59, 59),
      cancelled: true,
      settledTransactionId: 'tx-1',
    );

    final restored = FinancialCommitment.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.amount, original.amount);
    expect(restored.dueDate, original.dueDate);
    expect(restored.cancelled, isTrue);
    expect(restored.settledTransactionId, original.settledTransactionId);
  });
}
