import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/core/finance/financial_commitment.dart';

void main() {
  final dueDate = DateTime(2026, 9, 20);
  final referenceDate = DateTime(2026, 9, 25);

  test('new commitment is pending before its due date', () {
    const commitment = FinancialCommitment(
      id: 'c1',
      title: 'Internet',
      amount: 120,
      dueDate: DateTime(2026, 9, 20),
    );

    expect(commitment.status(DateTime(2026, 9, 19)), FinancialCommitmentStatus.pending);
  });

  test('unpaid commitment becomes overdue after due date', () {
    const commitment = FinancialCommitment(
      id: 'c1',
      title: 'Internet',
      amount: 120,
      dueDate: DateTime(2026, 9, 20),
    );

    expect(commitment.status(referenceDate), FinancialCommitmentStatus.overdue);
  });

  test('settled commitment is paid even after due date', () {
    const commitment = FinancialCommitment(
      id: 'c1',
      title: 'Internet',
      amount: 120,
      dueDate: DateTime(2026, 9, 20),
      settledTransactionId: 't1',
    );

    expect(commitment.status(referenceDate), FinancialCommitmentStatus.paid);
  });

  test('cancelled commitment remains cancelled', () {
    const commitment = FinancialCommitment(
      id: 'c1',
      title: 'Internet',
      amount: 120,
      dueDate: DateTime(2026, 9, 20),
      cancelled: true,
    );

    expect(commitment.status(referenceDate), FinancialCommitmentStatus.cancelled);
  });
}
