import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/core/finance/commitment_engine.dart';
import 'package:atlas_finance/core/finance/financial_commitment.dart';

void main() {
  const engine = FinancialCommitmentEngine();
  final referenceDate = DateTime(2026, 9, 25);

  final commitments = <FinancialCommitment>[
    const FinancialCommitment(
      id: 'c1',
      title: 'Internet',
      amount: 120,
      dueDate: DateTime(2026, 9, 20),
    ),
    const FinancialCommitment(
      id: 'c2',
      title: 'Aluguel',
      amount: 1500,
      dueDate: DateTime(2026, 9, 30),
    ),
    const FinancialCommitment(
      id: 'c3',
      title: 'Academia',
      amount: 100,
      dueDate: DateTime(2026, 9, 10),
      settledTransactionId: 't3',
    ),
    const FinancialCommitment(
      id: 'c4',
      title: 'Assinatura cancelada',
      amount: 50,
      dueDate: DateTime(2026, 9, 28),
      cancelled: true,
    ),
    const FinancialCommitment(
      id: 'c5',
      title: 'Seguro futuro',
      amount: 900,
      dueDate: DateTime(2026, 10, 5),
    ),
  ];

  test('separates pending and overdue commitments', () {
    expect(
      engine.pending(commitments, referenceDate: referenceDate).map((c) => c.id),
      ['c2', 'c5'],
    );
    expect(
      engine.overdue(commitments, referenceDate: referenceDate).map((c) => c.id),
      ['c1'],
    );
  });

  test('calculates pending and overdue totals', () {
    expect(engine.totalPending(commitments, referenceDate: referenceDate), 2400);
    expect(engine.totalOverdue(commitments, referenceDate: referenceDate), 120);
  });

  test('finds unsettled commitments due inside a period', () {
    final result = engine.dueBetween(
      commitments,
      start: DateTime(2026, 9, 20),
      end: DateTime(2026, 9, 30),
    );

    expect(result.map((c) => c.id), ['c2']);
    expect(
      engine.totalDueBetween(
        commitments,
        start: DateTime(2026, 9, 20),
        end: DateTime(2026, 9, 30),
      ),
      1500,
    );
  });

  test('calculates outstanding commitments through a forecast date', () {
    expect(
      engine.totalOutstandingThrough(
        commitments,
        referenceDate: referenceDate,
        end: DateTime(2026, 9, 30),
      ),
      1620,
    );

    expect(
      engine.totalOutstandingThrough(
        commitments,
        referenceDate: referenceDate,
        end: DateTime(2026, 10, 31),
      ),
      2520,
    );
  });

  test('returns an empty period when end is before start', () {
    expect(
      engine.dueBetween(
        commitments,
        start: DateTime(2026, 9, 30),
        end: DateTime(2026, 9, 20),
      ),
      isEmpty,
    );
  });
}
