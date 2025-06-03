import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AchievementService {
  static final String baseUrl = dotenv.get('BASE_URL');
  static final _storage = FlutterSecureStorage();

  static Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'authToken');
  }

  static Future<List<dynamic>> fetchUnlocked() async {
    final token = await _getToken();
    if (token == null) throw Exception('Authentication required');

    final response = await http.get(
      Uri.parse('$baseUrl/achievements/unlocked/'),
      headers: _headers(token),
    );

    return _handleResponse(response);
  }

  static Future<List<dynamic>> fetchAll() async {
    final token = await _getToken();
    if (token == null) throw Exception('Authentication required');

    final response = await http.get(
      Uri.parse('$baseUrl/achievements/all/'),
      headers: _headers(token),
    );

    return _handleResponse(response);
  }

  static List<dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
    throw Exception('Session expired. Please re-login');
  }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body)['error'] ?? 
                  'Failed to load data (${response.statusCode})';
      throw Exception(error);
    }
  }
}