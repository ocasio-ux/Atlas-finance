import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_model.dart';

class CardStore extends ChangeNotifier {
  CardStore._();
  static final CardStore instance = CardStore._();
  static const _storageKey = 'atlas_cards_v1';

  final List<AtlasCard> _cards = [];
  bool _loaded = false;

  List<AtlasCard> get cards => List.unmodifiable(_cards);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _cards
        ..clear()
        ..addAll(
          decoded.map(
            (item) => AtlasCard.fromJson(item as Map<String, dynamic>),
          ),
        );
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(AtlasCard card) async {
    _cards.add(card);
    notifyListeners();
    await _persist();
  }

  Future<void> update(AtlasCard card) async {
    final index = _cards.indexWhere((item) => item.id == card.id);
    if (index == -1) return;
    _cards[index] = card;
    notifyListeners();
    await _persist();
  }

  Future<void> delete(String id) async {
    _cards.removeWhere((item) => item.id == id);
    notifyListeners();
    await _persist();
  }

  AtlasCard? findById(String id) {
    for (final card in _cards) {
      if (card.id == id) return card;
    }
    return null;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_cards.map((item) => item.toJson()).toList()),
    );
  }
}
