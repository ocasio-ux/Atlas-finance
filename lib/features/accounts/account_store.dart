import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        ..addAll(
          decoded.map(
            (item) => AtlasAccount.fromJson(item as Map<String, dynamic>),
          ),
        );
    }
    _loaded = true;
    await _syncCloud();
    notifyListeners();
  }

  Future<void> add(AtlasAccount account) async {
    _accounts.add(account);
    notifyListeners();
    await _persist();
    await _writeCloud(account);
  }

  Future<void> update(AtlasAccount account) async {
    final index = _accounts.indexWhere((item) => item.id == account.id);
    if (index == -1) return;
    _accounts[index] = account;
    notifyListeners();
    await _persist();
    await _writeCloud(account);
  }

  Future<void> delete(String id) async {
    _accounts.removeWhere((item) => item.id == id);
    notifyListeners();
    await _persist();
    await _deleteCloud(id);
  }

  AtlasAccount? findById(String id) {
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_accounts.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> clearAll() async {
    final ids = _accounts.map((item) => item.id).toList();
    _accounts.clear();
    notifyListeners();
    await _persist();
    for (final id in ids) await _deleteCloud(id);
  }

  CollectionReference<Map<String, dynamic>>? get _cloud {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null
        ? null
        : FirebaseFirestore.instance.collection('users/$uid/accounts');
  }

  Future<void> _syncCloud() async {
    final cloud = _cloud;
    if (cloud == null) return;
    try {
      final snapshot = await cloud.get();
      if (snapshot.docs.isEmpty && _accounts.isNotEmpty) {
        for (final account in _accounts) await _writeCloud(account);
        return;
      }
      _accounts
        ..clear()
        ..addAll(snapshot.docs.map((doc) => AtlasAccount.fromJson(doc.data())));
    } catch (_) {}
  }

  Future<void> _writeCloud(AtlasAccount account) async {
    try {
      await _cloud?.doc(account.id).set(Map<String, dynamic>.from(account.toJson()));
    } catch (_) {}
  }

  Future<void> _deleteCloud(String id) async {
    try {
      await _cloud?.doc(id).delete();
    } catch (_) {}
  }
}
