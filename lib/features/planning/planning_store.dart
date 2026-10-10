import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../transactions/transaction_model.dart';
import 'planning_models.dart';

class PlanningStore extends ChangeNotifier {
  PlanningStore._();

  static final PlanningStore instance = PlanningStore._();
  static const _budgetsKey = 'atlas_budgets_v1';
  static const _goalsKey = 'atlas_goals_v1';

  final List<AtlasBudget> _budgets = [];
  final List<AtlasGoal> _goals = [];
  bool _loaded = false;

  List<AtlasBudget> get budgets => List.unmodifiable(_budgets);
  List<AtlasGoal> get goals => List.unmodifiable(_goals);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _budgets
      ..clear()
      ..addAll(_decodeList(prefs.getString(_budgetsKey), AtlasBudget.fromJson));
    _goals
      ..clear()
      ..addAll(_decodeList(prefs.getString(_goalsKey), AtlasGoal.fromJson));
    _loaded = true;
    await _syncCloud();
    notifyListeners();
  }

  AtlasBudget? budgetFor(TransactionCategory category) {
    for (final budget in _budgets) {
      if (budget.category == category) return budget;
    }
    return null;
  }

  Future<void> saveBudget(AtlasBudget budget) async {
    final index = _budgets.indexWhere(
      (item) => item.category == budget.category,
    );
    if (index == -1) {
      _budgets.add(budget);
    } else {
      _budgets[index] = budget;
    }
    notifyListeners();
    await _persistBudgets();
    await _writeBudget(budget);
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((item) => item.id == id);
    notifyListeners();
    await _persistBudgets();
    await _deleteCloud('budgets', id);
  }

  Future<void> saveGoal(AtlasGoal goal) async {
    final index = _goals.indexWhere((item) => item.id == goal.id);
    if (index == -1) {
      _goals.add(goal);
    } else {
      _goals[index] = goal;
    }
    notifyListeners();
    await _persistGoals();
    await _writeGoal(goal);
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((item) => item.id == id);
    notifyListeners();
    await _persistGoals();
    await _deleteCloud('goals', id);
  }

  Future<void> _persistBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _budgetsKey,
      jsonEncode(_budgets.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _persistGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _goalsKey,
      jsonEncode(_goals.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> clearAll() async {
    final budgetIds = _budgets.map((item) => item.id).toList();
    final goalIds = _goals.map((item) => item.id).toList();
    _budgets.clear();
    _goals.clear();
    notifyListeners();
    await _persistBudgets();
    await _persistGoals();
    for (final id in budgetIds) await _deleteCloud('budgets', id);
    for (final id in goalIds) await _deleteCloud('goals', id);
  }

  CollectionReference<Map<String, dynamic>>? _cloud(String collection) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null
        ? null
        : FirebaseFirestore.instance.collection('users/$uid/$collection');
  }

  Future<void> _syncCloud() async {
    final budgets = _cloud('budgets');
    final goals = _cloud('goals');
    if (budgets == null || goals == null) return;
    try {
      final budgetSnapshot = await budgets.get();
      final goalSnapshot = await goals.get();
      if (budgetSnapshot.docs.isEmpty && _budgets.isNotEmpty) {
        for (final budget in _budgets) await _writeBudget(budget);
      } else {
        _budgets
          ..clear()
          ..addAll(budgetSnapshot.docs.map((doc) => AtlasBudget.fromJson(doc.data())));
      }
      if (goalSnapshot.docs.isEmpty && _goals.isNotEmpty) {
        for (final goal in _goals) await _writeGoal(goal);
      } else {
        _goals
          ..clear()
          ..addAll(goalSnapshot.docs.map((doc) => AtlasGoal.fromJson(doc.data())));
      }
    } catch (_) {}
  }

  Future<void> _writeBudget(AtlasBudget budget) async {
    try { await _cloud('budgets')?.doc(budget.id).set(Map<String, dynamic>.from(budget.toJson())); } catch (_) {}
  }

  Future<void> _writeGoal(AtlasGoal goal) async {
    try { await _cloud('goals')?.doc(goal.id).set(Map<String, dynamic>.from(goal.toJson())); } catch (_) {}
  }

  Future<void> _deleteCloud(String collection, String id) async {
    try { await _cloud(collection)?.doc(id).delete(); } catch (_) {}
  }

  List<T> _decodeList<T>(String? raw, T Function(Map<String, dynamic>) decode) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final values = jsonDecode(raw) as List<dynamic>;
      return values
          .map((item) => decode(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Preserve existing storage on malformed/unknown data instead of
      // overwriting it during load. A future migration can recover it.
      return const [];
    }
  }
}
