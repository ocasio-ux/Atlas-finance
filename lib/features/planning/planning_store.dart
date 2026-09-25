import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/finance/financial_commitment.dart';
import '../transactions/transaction_model.dart';
import 'planning_models.dart';

class PlanningStore extends ChangeNotifier {
  PlanningStore._();

  static final PlanningStore instance = PlanningStore._();
  static const _budgetsKey = 'atlas_budgets_v1';
  static const _goalsKey = 'atlas_goals_v1';
  static const _commitmentsKey = 'atlas_commitments_v1';

  final List<AtlasBudget> _budgets = [];
  final List<AtlasGoal> _goals = [];
  final List<FinancialCommitment> _commitments = [];
  bool _loaded = false;

  List<AtlasBudget> get budgets => List.unmodifiable(_budgets);
  List<AtlasGoal> get goals => List.unmodifiable(_goals);
  List<FinancialCommitment> get commitments => List.unmodifiable(_commitments);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _budgets
      ..clear()
      ..addAll(_decodeList(prefs.getString(_budgetsKey), AtlasBudget.fromJson));
    _goals
      ..clear()
      ..addAll(_decodeList(prefs.getString(_goalsKey), AtlasGoal.fromJson));
    _commitments
      ..clear()
      ..addAll(
        _decodeList(
          prefs.getString(_commitmentsKey),
          FinancialCommitment.fromJson,
        ),
      );
    _loaded = true;
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
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((item) => item.id == id);
    notifyListeners();
    await _persistBudgets();
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
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((item) => item.id == id);
    notifyListeners();
    await _persistGoals();
  }

  Future<void> saveCommitment(FinancialCommitment commitment) async {
    final index = _commitments.indexWhere((item) => item.id == commitment.id);
    if (index == -1) {
      _commitments.add(commitment);
    } else {
      _commitments[index] = commitment;
    }
    _sortCommitments();
    notifyListeners();
    await _persistCommitments();
  }

  Future<void> deleteCommitment(String id) async {
    _commitments.removeWhere((item) => item.id == id);
    notifyListeners();
    await _persistCommitments();
  }

  Future<void> cancelCommitment(String id) async {
    final index = _commitments.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _commitments[index] = _commitments[index].copyWith(cancelled: true);
    notifyListeners();
    await _persistCommitments();
  }

  Future<void> settleCommitment(
    String id, {
    required String transactionId,
  }) async {
    final index = _commitments.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final commitment = _commitments[index];
    if (commitment.cancelled || commitment.settledTransactionId != null) {
      return;
    }

    _commitments[index] = commitment.copyWith(
      settledTransactionId: transactionId,
    );
    notifyListeners();
    await _persistCommitments();
  }

  void _sortCommitments() {
    _commitments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
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

  Future<void> _persistCommitments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _commitmentsKey,
      jsonEncode(_commitments.map((item) => item.toJson()).toList()),
    );
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
