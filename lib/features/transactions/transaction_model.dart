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

enum TransactionSourceType { account, card }

enum TransactionRepeat { none, monthly }

class AtlasTransaction {
  const AtlasTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.category = TransactionCategory.other,
    this.sourceType,
    this.sourceId,
    this.repeat = TransactionRepeat.none,
    this.seriesId,
    this.installmentNumber,
    this.installmentCount,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime createdAt;
  final TransactionCategory category;
  final TransactionSourceType? sourceType;
  final String? sourceId;
  final TransactionRepeat repeat;
  final String? seriesId;
  final int? installmentNumber;
  final int? installmentCount;

  bool get isRecurring => repeat != TransactionRepeat.none;
  bool get isInstallment =>
      installmentNumber != null &&
      installmentCount != null &&
      installmentCount! > 1;

  AtlasTransaction copyWith({
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? createdAt,
    TransactionCategory? category,
    TransactionSourceType? sourceType,
    String? sourceId,
    TransactionRepeat? repeat,
    String? seriesId,
    int? installmentNumber,
    int? installmentCount,
  }) => AtlasTransaction(
    id: id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    category: category ?? this.category,
    sourceType: sourceType ?? this.sourceType,
    sourceId: sourceId ?? this.sourceId,
    repeat: repeat ?? this.repeat,
    seriesId: seriesId ?? this.seriesId,
    installmentNumber: installmentNumber ?? this.installmentNumber,
    installmentCount: installmentCount ?? this.installmentCount,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'category': category.name,
    'sourceType': sourceType?.name,
    'sourceId': sourceId,
    'repeat': repeat.name,
    'seriesId': seriesId,
    'installmentNumber': installmentNumber,
    'installmentCount': installmentCount,
  };

  factory AtlasTransaction.fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String?;
    final sourceTypeName = json['sourceType'] as String?;
    final repeatName = json['repeat'] as String?;
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
      sourceType: sourceTypeName == null
          ? null
          : TransactionSourceType.values.firstWhere(
              (item) => item.name == sourceTypeName,
              orElse: () => TransactionSourceType.account,
            ),
      sourceId: json['sourceId'] as String?,
      repeat: repeatName == null
          ? TransactionRepeat.none
          : TransactionRepeat.values.firstWhere(
              (item) => item.name == repeatName,
              orElse: () => TransactionRepeat.none,
            ),
      seriesId: json['seriesId'] as String?,
      installmentNumber: (json['installmentNumber'] as num?)?.toInt(),
      installmentCount: (json['installmentCount'] as num?)?.toInt(),
    );
  }
}
