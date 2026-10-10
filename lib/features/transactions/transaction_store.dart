import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        ..addAll(
          decoded.map(
            (item) => AtlasTransaction.fromJson(item as Map<String, dynamic>),
          ),
        );
      _sort();
    }
    _loaded = true;
    await _syncCloud();
    notifyListeners();
  }

  Future<void> add(AtlasTransaction transaction) async => addAll([transaction]);

  Future<void> addAll(Iterable<AtlasTransaction> transactions) async {
    _transactions.addAll(transactions);
    _sort();
    notifyListeners();
    await _persist();
    for (final transaction in transactions) await _writeCloud(transaction);
  }

  Future<void> update(AtlasTransaction transaction) async {
    final index = _transactions.indexWhere((item) => item.id == transaction.id);
    if (index == -1) return;
    _transactions[index] = transaction;
    _sort();
    notifyListeners();
    await _persist();
    await _writeCloud(transaction);
  }

  Future<void> delete(String transactionId) async {
    _transactions.removeWhere((item) => item.id == transactionId);
    notifyListeners();
    await _persist();
    await _deleteCloud(transactionId);
  }

  AtlasTransaction? findById(String transactionId) {
    for (final transaction in _transactions) {
      if (transaction.id == transactionId) return transaction;
    }
    return null;
  }

  void _sort() =>
      _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_transactions.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> clearAll() async {
    final ids = _transactions.map((item) => item.id).toList();
    _transactions.clear();
    notifyListeners();
    await _persist();
    for (final id in ids) await _deleteCloud(id);
  }

  CollectionReference<Map<String, dynamic>>? get _cloud {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null ? null : FirebaseFirestore.instance.collection('users/$uid/transactions');
  }

  Future<void> _syncCloud() async {
    final cloud = _cloud;
    if (cloud == null) return;
    try {
      final snapshot = await cloud.get();
      if (snapshot.docs.isEmpty && _transactions.isNotEmpty) {
        for (final transaction in _transactions) await _writeCloud(transaction);
        return;
      }
      _transactions
        ..clear()
        ..addAll(snapshot.docs.map((doc) => AtlasTransaction.fromJson(doc.data())));
      _sort();
    } catch (_) {}
  }

  Future<void> _writeCloud(AtlasTransaction transaction) async {
    try { await _cloud?.doc(transaction.id).set(Map<String, dynamic>.from(transaction.toJson())); } catch (_) {}
  }

  Future<void> _deleteCloud(String id) async {
    try { await _cloud?.doc(id).delete(); } catch (_) {}
  }
}
