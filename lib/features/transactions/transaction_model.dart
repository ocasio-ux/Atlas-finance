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
    DateTime? transactionDate,
    this.category = TransactionCategory.other,
    this.sourceType,
    this.sourceId,
    this.destinationType,
    this.destinationId,
    this.repeat = TransactionRepeat.none,
    this.seriesId,
    this.installmentNumber,
    this.installmentCount,
  }) : transactionDate = transactionDate ?? createdAt;

  final String id;
  final TransactionType type;
  final double amount;
  final String description;

  /// When the movement actually happened.
  final DateTime transactionDate;

  /// When the record was created/edited in Atlas.
  final DateTime createdAt;

  final TransactionCategory category;
  final TransactionSourceType? sourceType;
  final String? sourceId;

  /// Used by transfers to identify where the money goes.
  final TransactionSourceType? destinationType;
  final String? destinationId;

  final TransactionRepeat repeat;
  final String? seriesId;
  final int? installmentNumber;
  final int? installmentCount;

  bool get isRecurring => repeat != TransactionRepeat.none;
  bool get isInstallment =>
      installmentNumber != null &&
      installmentCount != null &&
      installmentCount! > 1;

  bool get isTransfer =>
      type == TransactionType.transfer &&
      sourceId != null &&
      destinationId != null;

  AtlasTransaction copyWith({
    TransactionType? type,
    double? amount,
    String? description,
    DateTime? createdAt,
    DateTime? transactionDate,
    TransactionCategory? category,
    TransactionSourceType? sourceType,
    String? sourceId,
    TransactionSourceType? destinationType,
    String? destinationId,
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
    transactionDate: transactionDate ?? this.transactionDate,
    category: category ?? this.category,
    sourceType: sourceType ?? this.sourceType,
    sourceId: sourceId ?? this.sourceId,
    destinationType: destinationType ?? this.destinationType,
    destinationId: destinationId ?? this.destinationId,
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
    'transactionDate': transactionDate.toIso8601String(),
    'category': category.name,
    'sourceType': sourceType?.name,
    'sourceId': sourceId,
    'destinationType': destinationType?.name,
    'destinationId': destinationId,
    'repeat': repeat.name,
    'seriesId': seriesId,
    'installmentNumber': installmentNumber,
    'installmentCount': installmentCount,
  };

  factory AtlasTransaction.fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String?;
    final sourceTypeName = json['sourceType'] as String?;
    final destinationTypeName = json['destinationType'] as String?;
    final repeatName = json['repeat'] as String?;
    final createdAt = DateTime.parse(json['createdAt'] as String);
    final transactionDateRaw = json['transactionDate'] as String?;

    return AtlasTransaction(
      id: json['id'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      createdAt: createdAt,
      transactionDate: transactionDateRaw == null
          ? createdAt
          : DateTime.parse(transactionDateRaw),
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
      destinationType: destinationTypeName == null
          ? null
          : TransactionSourceType.values.firstWhere(
              (item) => item.name == destinationTypeName,
              orElse: () => TransactionSourceType.account,
            ),
      destinationId: json['destinationId'] as String?,
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
