enum AccountType { checking, savings, wallet, cash }

class AtlasAccount {
  const AtlasAccount({
    required this.id,
    required this.name,
    required this.type,
    this.initialBalance = 0,
  });

  final String id;
  final String name;
  final AccountType type;
  final double initialBalance;

  AtlasAccount copyWith({String? name, AccountType? type, double? initialBalance}) => AtlasAccount(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        initialBalance: initialBalance ?? this.initialBalance,
      );

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'type': type.name, 'initialBalance': initialBalance};

  factory AtlasAccount.fromJson(Map<String, dynamic> json) => AtlasAccount(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Conta',
        type: AccountType.values.firstWhere((item) => item.name == json['type'], orElse: () => AccountType.checking),
        initialBalance: (json['initialBalance'] as num?)?.toDouble() ?? 0,
      );
}
