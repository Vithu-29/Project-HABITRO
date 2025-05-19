import 'dart:convert';
import 'package:frontend/models/quiz_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class QuizApiService {
  static final String baseUrl =
      dotenv.get('BASE_URL'); // Update with your backend URL

  static Future<QuizResponse> fetchQuizzes() async {
    final url = Uri.parse('$baseUrl/quiz/get-quiz/');
    final response = await http.get(url);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      return QuizResponse.fromJson(data);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to load quizzes');
    }
  }


  static Future<void> updateProgress({
    required int currentQuestionIndex,
  }) async {
    final url = Uri.parse('$baseUrl/quiz/update-progress/');

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
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
    final url = Uri.parse('$baseUrl/quiz/add-coins/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'coins': coins}),
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to add coins');
    }
  }
}
