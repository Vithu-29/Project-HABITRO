import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RewardService {
  static final String baseUrl = dotenv.get('BASE_URL');

  static Future<Map<String, dynamic>> getRewards() async {
    final response = await http.get(Uri.parse('$baseUrl/api/rewards/'));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> convertCoins(int amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/convert/'),
      body: json.encode({'amount': amount}),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> claimStreak() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/claim-streak/'),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(response.body);
  }
}