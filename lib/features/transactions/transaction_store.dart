import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'transaction_model.dart';

class TransactionStore extends ChangeNotifier {
  TransactionStore._();

  static final TransactionStore instance = TransactionStore._();
  static const _storageKey = 'atlas_transactions_v1';

  final List<AtlasTransaction> _transactions = [];
  bool _loaded = false;

  List<AtlasTransaction> get transactions => List.unmodifiable(_transactions);
  int get count => _transactions.length;

  double get income => _transactions
      .where((item) => item.type == TransactionType.income)
      .fold(0, (sum, item) => sum + item.amount);

  double get expenses => _transactions
      .where((item) => item.type == TransactionType.expense)
      .fold(0, (sum, item) => sum + item.amount);

  double get balance => income - expenses;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _transactions
        ..clear()
        ..addAll(decoded.map((item) => AtlasTransaction.fromJson(item as Map<String, dynamic>)));
      _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(AtlasTransaction transaction) async {
    _transactions.insert(0, transaction);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_transactions.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }
}
