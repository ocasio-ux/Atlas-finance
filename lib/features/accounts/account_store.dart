import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_model.dart';

class AccountStore extends ChangeNotifier {
  AccountStore._();
  static final AccountStore instance = AccountStore._();
  static const _storageKey = 'atlas_accounts_v1';

  final List<AtlasAccount> _accounts = [];
  bool _loaded = false;

  List<AtlasAccount> get accounts => List.unmodifiable(_accounts);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _accounts
        ..clear()
        ..addAll(decoded.map((item) => AtlasAccount.fromJson(item as Map<String, dynamic>)));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(AtlasAccount account) async {
    _accounts.add(account);
    notifyListeners();
    await _persist();
  }

  Future<void> update(AtlasAccount account) async {
    final index = _accounts.indexWhere((item) => item.id == account.id);
    if (index == -1) return;
    _accounts[index] = account;
    notifyListeners();
    await _persist();
  }

  Future<void> delete(String id) async {
    _accounts.removeWhere((item) => item.id == id);
    notifyListeners();
    await _persist();
  }

  AtlasAccount? findById(String id) {
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_accounts.map((item) => item.toJson()).toList()));
  }
}
