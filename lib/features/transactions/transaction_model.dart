enum TransactionType { expense, income, transfer }

class AtlasTransaction {
  const AtlasTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AtlasTransaction.fromJson(Map<String, dynamic> json) {
    return AtlasTransaction(
      id: json['id'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
