enum FinancialCommitmentStatus { pending, paid, overdue, cancelled }

class FinancialCommitment {
  const FinancialCommitment({required this.id, required this.title, required this.amount, required this.dueDate, this.cancelled = false, this.settledTransactionId});

  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool cancelled;
  final String? settledTransactionId;

  FinancialCommitmentStatus status(DateTime referenceDate) {
    if (cancelled) return FinancialCommitmentStatus.cancelled;
    if (settledTransactionId != null) return FinancialCommitmentStatus.paid;
    if (referenceDate.isAfter(dueDate)) return FinancialCommitmentStatus.overdue;
    return FinancialCommitmentStatus.pending;
  }
}
