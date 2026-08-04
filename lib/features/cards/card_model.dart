class AtlasCard {
  const AtlasCard({
    required this.id,
    required this.name,
    required this.lastFourDigits,
    required this.closingDay,
    required this.dueDay,
    this.limit,
  });

  final String id;
  final String name;
  final String lastFourDigits;
  final int closingDay;
  final int dueDay;
  final double? limit;

  AtlasCard copyWith({
    String? name,
    String? lastFourDigits,
    int? closingDay,
    int? dueDay,
    double? limit,
  }) => AtlasCard(
    id: id,
    name: name ?? this.name,
    lastFourDigits: lastFourDigits ?? this.lastFourDigits,
    closingDay: closingDay ?? this.closingDay,
    dueDay: dueDay ?? this.dueDay,
    limit: limit ?? this.limit,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'lastFourDigits': lastFourDigits,
    'closingDay': closingDay,
    'dueDay': dueDay,
    'limit': limit,
  };

  factory AtlasCard.fromJson(Map<String, dynamic> json) => AtlasCard(
    id: json['id'] as String,
    name: json['name'] as String? ?? 'Cartão',
    lastFourDigits: json['lastFourDigits'] as String? ?? '',
    closingDay: json['closingDay'] as int? ?? 1,
    dueDay: json['dueDay'] as int? ?? 10,
    limit: (json['limit'] as num?)?.toDouble(),
  );
}
