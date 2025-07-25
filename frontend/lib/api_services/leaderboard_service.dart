// lib/services/leaderboard_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LeaderboardService {
  static final String baseUrl = dotenv.get('BASE_URL');
  final _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> getLeaderboard(String period) async {
    final token = await _storage.read(key: 'authToken');
    final response = await http.get(
      Uri.parse('$baseUrl/profile/leaderboard/?period=$period'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load leaderboard data');
    }
  }
}