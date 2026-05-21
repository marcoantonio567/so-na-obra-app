import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local_database.dart';

class PinRecebimentoSaveResult {
  const PinRecebimentoSaveResult({
    required this.pin,
    required this.savedPersistently,
    this.message,
  });

  final String pin;
  final bool savedPersistently;
  final String? message;
}

class PinRecebimentoStore {
  PinRecebimentoStore({required this.userId});

  static final Map<String, String> _memCache = {};

  final String userId;

  String get _prefsKey => 'pin_recebimento:$userId';

  Future<String?> carregar() async {
    final prefsPin = await _lerPrefs();
    if (prefsPin != null || kIsWeb) {
      return prefsPin ?? _memCache[userId];
    }

    final dbPin = await _lerBanco();
    if (dbPin != null) await _salvarPrefs(dbPin);
    return dbPin;
  }

  Future<PinRecebimentoSaveResult> gerarESalvar() async {
    final novo = _gerarPin();
    final savedPersistently = await _salvarPrefs(novo);
    String? message;

    if (kIsWeb && !savedPersistently) {
      _memCache[userId] = novo;
      message =
          'No navegador, não foi possível salvar nos dados do site. Verifique se o Edge está bloqueando cookies/dados do site (ou modo InPrivate).';
    }

    if (!kIsWeb) {
      try {
        await LocalDatabase.instance.salvarPinRecebimento(
          userId: userId,
          pin: novo,
        );
      } catch (_) {}
    }

    return PinRecebimentoSaveResult(
      pin: novo,
      savedPersistently: savedPersistently,
      message: message,
    );
  }

  Future<String?> _lerPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pin = prefs.getString(_prefsKey);
      return (pin ?? '').trim().isEmpty ? null : pin;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _salvarPrefs(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.setString(_prefsKey, pin);
    } catch (_) {
      return false;
    }
  }

  Future<String?> _lerBanco() async {
    try {
      final pin = await LocalDatabase.instance.obterPinRecebimento(
        userId: userId,
      );
      return (pin ?? '').trim().isEmpty ? null : pin;
    } catch (_) {
      return null;
    }
  }

  String _gerarPin() {
    Random rng;
    try {
      rng = Random.secure();
    } catch (_) {
      rng = Random();
    }
    return rng.nextInt(1000000).toString().padLeft(6, '0');
  }
}
