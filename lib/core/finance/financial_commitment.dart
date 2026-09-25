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

  FinancialCommitment copyWith({
    String? title,
    double? amount,
    DateTime? dueDate,
    bool? cancelled,
    String? settledTransactionId,
  }) => FinancialCommitment(
    id: id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    dueDate: dueDate ?? this.dueDate,
    cancelled: cancelled ?? this.cancelled,
    settledTransactionId: settledTransactionId ?? this.settledTransactionId,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'dueDate': dueDate.toIso8601String(),
    'cancelled': cancelled,
    'settledTransactionId': settledTransactionId,
  };

  factory FinancialCommitment.fromJson(Map<String, dynamic> json) =>
      FinancialCommitment(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Compromisso',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        dueDate:
            DateTime.tryParse(json['dueDate'] as String? ?? '') ??
            DateTime.now(),
        cancelled: json['cancelled'] as bool? ?? false,
        settledTransactionId: json['settledTransactionId'] as String?,
      );
}
