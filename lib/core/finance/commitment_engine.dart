import 'financial_commitment.dart';

class FinancialCommitmentEngine {
  const FinancialCommitmentEngine();

  List<FinancialCommitment> pending(
    Iterable<FinancialCommitment> commitments, {
    required DateTime referenceDate,
  }) {
    return commitments
        .where(
          (commitment) =>
              commitment.status(referenceDate) ==
              FinancialCommitmentStatus.pending,
        )
        .toList(growable: false);
  }

  List<FinancialCommitment> overdue(
    Iterable<FinancialCommitment> commitments, {
    required DateTime referenceDate,
  }) {
    return commitments
        .where(
          (commitment) =>
              commitment.status(referenceDate) ==
              FinancialCommitmentStatus.overdue,
        )
        .toList(growable: false);
  }

  List<FinancialCommitment> dueBetween(
    Iterable<FinancialCommitment> commitments, {
    required DateTime start,
    required DateTime end,
  }) {
    if (end.isBefore(start)) {
      return const [];
    }

    return commitments
        .where(
          (commitment) =>
              !commitment.cancelled &&
              commitment.settledTransactionId == null &&
              !commitment.dueDate.isBefore(start) &&
              !commitment.dueDate.isAfter(end),
        )
        .toList(growable: false);
  }

  double totalPending(
    Iterable<FinancialCommitment> commitments, {
    required DateTime referenceDate,
  }) {
    return _sum(pending(commitments, referenceDate: referenceDate));
  }

  double totalOverdue(
    Iterable<FinancialCommitment> commitments, {
    required DateTime referenceDate,
  }) {
    return _sum(overdue(commitments, referenceDate: referenceDate));
  }

  double totalDueBetween(
    Iterable<FinancialCommitment> commitments, {
    required DateTime start,
    required DateTime end,
  }) {
    return _sum(dueBetween(commitments, start: start, end: end));
  }

  double _sum(Iterable<FinancialCommitment> commitments) {
    return commitments.fold<double>(
      0,
      (total, commitment) => total + commitment.amount,
    );
  }
}
