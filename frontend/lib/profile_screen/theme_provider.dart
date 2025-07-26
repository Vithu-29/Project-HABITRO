import 'package:flutter/material.dart';
import 'package:frontend/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Enum to define font size options
enum FontSizeOption { small, normal, large }

extension FontSizeOptionExtension on FontSizeOption {
  String get label {
    switch (this) {
      case FontSizeOption.small:
        return 'Small';
      case FontSizeOption.normal:
        return 'Normal';
      case FontSizeOption.large:
        return 'Large';
    }
  }

  static FontSizeOption fromString(String value) {
    return FontSizeOption.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FontSizeOption.normal,
    );
  }
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  FontSizeOption _fontSize = FontSizeOption.normal;

  final String _apiUrl = 'http://192.168.8.132:8000/api/settings/font-size/';
  String? _authToken;

  bool get isDarkMode => _isDarkMode;
  FontSizeOption get fontSize => _fontSize;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  double get fontScaleFactor {
    switch (_fontSize) {
      case FontSizeOption.small:
        return 0.85;
      case FontSizeOption.normal:
        return 1.0;
      case FontSizeOption.large:
        return 1.15;
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void setFontSize(FontSizeOption newSize) async {
    _fontSize = newSize;
    notifyListeners(); // update UI immediately

    // Save to Django backend
    if (_authToken != null) {
      await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Token $_authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'font_size': newSize.name}),
      );
    }
  }

  Future<void> fetchFontSize() async {
    if (_authToken == null) return;

    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Authorization': 'Token $_authToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String font = data['font_size'];
        _fontSize = FontSizeOptionExtension.fromString(font);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching font size: $e");
    }
  }
}
