import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RewardService {
  static final String baseUrl = dotenv.get('BASE_URL');
  static final _storage = FlutterSecureStorage();

  static Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token', // Use 'Bearer $token' if using JWT
    };
  }

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'authToken'); // Corrected key
  }

  static Future<Map<String, dynamic>> getRewards() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/api/rewards/'),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get rewards: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> convertCoins(int amount) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final response = await http.post(
      Uri.parse('$baseUrl/api/convert/'),
      headers: _headers(token),
      body: json.encode({'amount': amount}),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> claimStreak() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final response = await http.post(
      Uri.parse('$baseUrl/api/claim-streak/'),
      headers: _headers(token),
    );
    return json.decode(response.body);
  }
}
