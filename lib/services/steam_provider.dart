import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SteamProvider with ChangeNotifier {
  String? _steamId;
  static const String _steamIdKey = 'selectedStemId';

  String? get steamId => _steamId;

  SteamProvider() {
    loadSharedPreferencesData();
  }

  Future<void> loadSharedPreferencesData() async {
    final prefs = await SharedPreferences.getInstance();
    _steamId = prefs.getString(_steamIdKey);
    notifyListeners();
  }

  Future<void> setSteamId(String newSteamId) async {
    _steamId = newSteamId;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_steamIdKey, newSteamId);
  }
}
