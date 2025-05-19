import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AchievementService {
  static String get baseUrl => dotenv.get('BASE_URL');

  static Future<List<dynamic>> fetchUnlocked() async {
    final response = await http.get(Uri.parse('$baseUrl/achievements/unlocked/'));
    return _handleResponse(response);
  }

  static Future<List<dynamic>> fetchAll() async {
    final response = await http.get(Uri.parse('$baseUrl/achievements/all/'));
    return _handleResponse(response);
  }

  static List<dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load data: ${response.statusCode}');
  }
}