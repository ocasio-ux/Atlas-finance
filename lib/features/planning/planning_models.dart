import '../transactions/transaction_model.dart';

class AtlasBudget {
  const AtlasBudget({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    required this.createdAt,
  });

  final String id;
  final TransactionCategory category;
  final double monthlyLimit;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'category': category.name,
    'monthlyLimit': monthlyLimit,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AtlasBudget.fromJson(Map<String, dynamic> json) => AtlasBudget(
    id: json['id'] as String,
    category: TransactionCategory.values.firstWhere(
      (value) => value.name == json['category'],
      orElse: () => TransactionCategory.other,
    ),
    monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class AtlasGoal {
  const AtlasGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.createdAt,
    this.targetDate,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime createdAt;
  final DateTime? targetDate;

  double get progress =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0, 1);
  double get remaining =>
      (targetAmount - savedAmount).clamp(0, double.infinity);

  AtlasGoal copyWith({
    double? savedAmount,
    String? name,
    double? targetAmount,
    DateTime? targetDate,
  }) => AtlasGoal(
    id: id,
    name: name ?? this.name,
    targetAmount: targetAmount ?? this.targetAmount,
    savedAmount: savedAmount ?? this.savedAmount,
    createdAt: createdAt,
    targetDate: targetDate ?? this.targetDate,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'savedAmount': savedAmount,
    'createdAt': createdAt.toIso8601String(),
    'targetDate': targetDate?.toIso8601String(),
  };

  factory AtlasGoal.fromJson(Map<String, dynamic> json) => AtlasGoal(
    id: json['id'] as String,
    name: json['name'] as String? ?? 'Meta',
    targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
    savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    targetDate: DateTime.tryParse(json['targetDate'] as String? ?? ''),
  );
}
