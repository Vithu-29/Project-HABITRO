import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum ThemePreference { light, dark, system }

enum FontSizePreference { small, medium, large }

class SettingsProvider extends ChangeNotifier {
  ThemePreference _themePref = ThemePreference.system;
  FontSizePreference _fontPref = FontSizePreference.medium;

  ThemePreference get themePref => _themePref;
  FontSizePreference get fontPref => _fontPref;

  ThemeMode get themeMode {
    switch (_themePref) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  double get fontScale {
    switch (_fontPref) {
      case FontSizePreference.small:
        return 0.8;
      case FontSizePreference.medium:
        return 1.0;
      case FontSizePreference.large:
        return 1.2;
    }
  }

  static const _themeKey = 'themePref';
  static const _fontKey = 'fontPref';

  Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_themeKey)) {
      final themeString = prefs.getString(_themeKey);
      _themePref = ThemePreference.values.firstWhere(
        (e) => e.toString().endsWith(themeString!),
        orElse: () => ThemePreference.system,
      );
    }

    if (prefs.containsKey(_fontKey)) {
      final fontString = prefs.getString(_fontKey);
      _fontPref = FontSizePreference.values.firstWhere(
        (e) => e.toString().endsWith(fontString!),
        orElse: () => FontSizePreference.medium,
      );
    }

    notifyListeners();
  }

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themePref.toString().split('.').last);
    await prefs.setString(_fontKey, _fontPref.toString().split('.').last);
  }

  Future<void> fetchFromBackend(String authToken) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/appearance/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final themeStr = data['theme_preference'] as String?;
      if (themeStr != null) {
        _themePref = ThemePreference.values.firstWhere(
          (e) => e.toString().endsWith(themeStr),
          orElse: () => ThemePreference.system,
        );
      }

      final fontStr = data['font_size_preference'] as String?;
      if (fontStr != null) {
        _fontPref = FontSizePreference.values.firstWhere(
          (e) => e.toString().endsWith(fontStr),
          orElse: () => FontSizePreference.medium,
        );
      }

      await _saveToLocal();
      notifyListeners();
    }
  }

  Future<void> updateTheme(ThemePreference newPref, String authToken) async {
    if (_themePref == newPref) return;

    _themePref = newPref;
    notifyListeners();
    await _saveToLocal();

    final url = Uri.parse('http://127.0.0.1:8000/api/appearance/');
    final body = json.encode({
      "theme_preference": newPref.toString().split('.').last,
    });

    await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );
  }

  Future<void> updateFontSize(FontSizePreference newPref, String authToken) async {
    if (_fontPref == newPref) return;

    _fontPref = newPref;
    notifyListeners();
    await _saveToLocal();

    final url = Uri.parse('http://127.0.0.1:8000/api/appearance/');
    final body = json.encode({
      "font_size_preference": newPref.toString().split('.').last,
    });

    await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );
  }
}
