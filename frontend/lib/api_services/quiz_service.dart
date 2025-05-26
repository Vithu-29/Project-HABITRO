import 'dart:convert';
import 'package:frontend/models/quiz_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class QuizApiService {
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

  static Future<QuizResponse> fetchQuizzes() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final url = Uri.parse('$baseUrl/quiz/get-quiz/');
    final response = await http.get(
      url,
      headers: _headers(token),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return QuizResponse.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to load quizzes');
    }
  }

  static Future<void> updateProgress({
    required int currentQuestionIndex,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final url = Uri.parse('$baseUrl/quiz/update-progress/');

    final response = await http.patch(
      url,
      headers: _headers(token),
      body: json.encode({'current_question_index': currentQuestionIndex}),
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to update progress');
    }
  }


  static Future<void> addCoins({
    required int coins,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final url = Uri.parse('$baseUrl/quiz/add-coins/');

    final response = await http.post(
      url,
      headers: _headers(token),
      body: json.encode({'coins': coins}),
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to add coins');
    }
  }
}
