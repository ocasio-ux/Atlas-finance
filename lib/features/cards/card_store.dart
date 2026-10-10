import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    await _syncCloud();
    notifyListeners();
  }

  Future<void> add(AtlasCard card) async {
    _cards.add(card);
    notifyListeners();
    await _persist();
    await _writeCloud(card);
  }

  Future<void> update(AtlasCard card) async {
    final index = _cards.indexWhere((item) => item.id == card.id);
    if (index == -1) return;
    _cards[index] = card;
    notifyListeners();
    await _persist();
    await _writeCloud(card);
  }

  Future<void> delete(String id) async {
    _cards.removeWhere((item) => item.id == id);
    notifyListeners();
    await _persist();
    await _deleteCloud(id);
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

  Future<void> clearAll() async {
    final ids = _cards.map((item) => item.id).toList();
    _cards.clear();
    notifyListeners();
    await _persist();
    for (final id in ids) await _deleteCloud(id);
  }

  CollectionReference<Map<String, dynamic>>? get _cloud {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null ? null : FirebaseFirestore.instance.collection('users/$uid/cards');
  }

  Future<void> _syncCloud() async {
    final cloud = _cloud;
    if (cloud == null) return;
    try {
      final snapshot = await cloud.get();
      if (snapshot.docs.isEmpty && _cards.isNotEmpty) {
        for (final card in _cards) await _writeCloud(card);
        return;
      }
      _cards
        ..clear()
        ..addAll(snapshot.docs.map((doc) => AtlasCard.fromJson(doc.data())));
    } catch (_) {}
  }

  Future<void> _writeCloud(AtlasCard card) async {
    try { await _cloud?.doc(card.id).set(Map<String, dynamic>.from(card.toJson())); } catch (_) {}
  }

  Future<void> _deleteCloud(String id) async {
    try { await _cloud?.doc(id).delete(); } catch (_) {}
  }
}
