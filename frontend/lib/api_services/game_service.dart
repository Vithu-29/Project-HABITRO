import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GameApiService {
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

  static Future<Map<String, dynamic>> startGame() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final url = Uri.parse('$baseUrl/game/start/');
    final response = await http.post(
      url,
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to start game: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> submitGameResult(
      int timeTaken, bool won) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final url = Uri.parse('$baseUrl/game/result/');
    final response = await http.post(
      url,
      headers: _headers(token),
      body: json.encode({'time_taken': timeTaken, 'won': won}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit result: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getGameStats() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final url = Uri.parse('$baseUrl/game/stats/');
    final response = await http.get(
      url,
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get stats: ${response.body}');
    }
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
}
