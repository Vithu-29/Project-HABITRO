import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GameApiService {
  static final String baseUrl = dotenv.get('BASE_URL');

  static Future<Map<String, dynamic>> startGame() async {
    final url = Uri.parse('$baseUrl/game/start/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to start game: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> submitGameResult(
      int timeTaken, bool won) async {
    final url = Uri.parse('$baseUrl/game/result/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'time_taken': timeTaken, 'won': won}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit result: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getGameStats() async {
    final url = Uri.parse('$baseUrl/game/stats/');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get stats: ${response.body}');
    }
  }

}