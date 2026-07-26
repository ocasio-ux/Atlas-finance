enum TransactionType { expense, income, transfer }

enum TransactionCategory {
  food,
  transport,
  housing,
  health,
  leisure,
  shopping,
  salary,
  education,
  other,
}

class AtlasTransaction {
  const AtlasTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.category = TransactionCategory.other,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime createdAt;
  final TransactionCategory category;

  AtlasTransaction copyWith({
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? createdAt,
    TransactionCategory? category,
  }) {
    return AtlasTransaction(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'category': category.name,
      };

  factory AtlasTransaction.fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String?;
    return AtlasTransaction(
      id: json['id'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: categoryName == null
          ? TransactionCategory.other
          : TransactionCategory.values.firstWhere(
              (item) => item.name == categoryName,
              orElse: () => TransactionCategory.other,
            ),
    );
  }
}
