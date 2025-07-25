// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AIService {
  //***********************************************************************************************************//
  static final String baseurl = dotenv.get('BASE_URL');
  static final _storage = FlutterSecureStorage();

  static Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token', // Use 'Bearer $token' if using JWT
    };
  }

  static Future<String?> _getToken() async {
    try {
      // First try secure storage
      String? token = await _storage.read(key: 'authToken');

      if (token != null && token.isNotEmpty) {
        return token;
      }

      // If not found, try SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('authToken');

      if (token != null && token.isNotEmpty) {
        // Save to secure storage for next time
        await _storage.write(key: 'authToken', value: token);
        return token;
      }

      print("No token found in any storage");
      return null;
    } catch (e) {
      print("Error retrieving token: $e");
      return null;
    }
  }

  //send the entered habit to analyze good or bad
  static Future<String> analyzeHabit(String habit) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final response = await http.post(
        Uri.parse(
          "$baseurl/api/analyze_habit/",
        ),
        headers: _headers(token),
        body: json.encode({"habit": habit}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return data['classification'];
      } else {
        return "error";
      }
    } catch (e) {
      print("Error: $e");
      return "error";
    }
  }

  //***********************************************************************************************************//
  // send the gathered responses to ai(initial + regenerate)

  static Future<List<Map<String, dynamic>>> sendToAI(
    Map<String, dynamic> responses, {
    bool regenerate = false,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final finalRequest = {...responses, "regenerate": regenerate};

      print("Sending to backend (DEBUG):");
      print(json.encode(finalRequest));

      final response = await http.post(
        Uri.parse("$baseurl/api/analyze_responses/"),
        headers: _headers(token),
        body: json.encode(finalRequest),
      );

      if (response.statusCode == 200) {
        print("Data sent to AI successfully!");
        final data = json.decode(response.body);
        List<dynamic> tasks = data['tasks'];

        return tasks
            .map(
              (task) => {
                'task': task['task'],
                'isCompleted': task['isCompleted'] ?? false,
              },
            )
            .toList();
      } else {
        print("Failed to send data to AI. Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        return [];
      }
    } catch (error) {
      print("Error in sendToAI: $error");
      return [];
    }
  }

  //***********************************************************************************************************//

  // Method to send the habit data to Django backend and get questions

  static Future<List<String>> generateDynamicQuestions(
    String habit,
    String habitType,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final response = await http.post(
        Uri.parse(
          "$baseurl/api/generate_dynamic_questions/",
        ),
        headers: _headers(token),
        body: json.encode({
          'habit': habit,
          'habit_type': habitType, // Send the habit type ('good' or 'bad')
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('dynamic_questions')) {
          return List<String>.from(responseData['dynamic_questions']);
        }
      }
    } catch (error) {
      print('Error in generating questions: $error');
    }
    return [];
  }

  //***********************************************************************************************************//

  // save the tasks in the database

  static Future<Map<String, dynamic>> saveTasks(
      {required String habitName,
      required String habitType,
      required List<Map<String, dynamic>> tasks,
      required int duration // List<Map<String, dynamic>> tasks
      }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final response = await http.post(
        Uri.parse("$baseurl/api/save_tasks/"),
        headers: _headers(token),
        body: json.encode({
          "habit_name": habitName,
          "habit_type": habitType,
          "tasks": tasks,
          "duration": duration,
        }),
      );

      print("Response status: ${response.statusCode}"); // Should be 201
      print("Response body: ${response.body}"); // Check for errors

      if (response.statusCode == 201) {
        return jsonDecode(
            response.body); // ✅ Returns the full JSON including habit_id
      } else {
        throw Exception('Failed to save tasks: ${response.body}');
      }
    } catch (e) {
      print("Error saving tasks: $e");
      throw Exception('Error saving tasks');
    }
  }

  ////////////////////////////////////fetch habits for today////////////////////////////////////////////////////////////////

  Future<List<Habit>> fetchHabitsWithTodayTasks() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final response = await http.get(
        Uri.parse('$baseurl/api/habits-today/'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((json) => Habit.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load habits');
      }
    } catch (e) {
      print('Error fetching habits: $e');
      throw Exception('Failed to load habits');
    }
  }

  ///////////////////  update task status //////////////////////////////////////////////////////
  Future<void> updateTaskStatus(String taskId, bool isCompleted) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    await http.post(
      Uri.parse(
        '$baseurl/api/task/$taskId/update_task_status/',
      ),
      headers: _headers(token),
      body: json.encode({'isCompleted': isCompleted}),
    );
  }

  // Method to fetch habits
  static Future<List<Map<String, dynamic>>> getHabits() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final response = await http.get(
        Uri.parse("$baseurl/api/get_habits/"),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load habits');
      }
    } catch (e) {
      print("Error fetching habits: $e");
      throw Exception('Failed to load habits');
    }
  }

  //////////////////////////////////////////////////////////////////////

  // Update stats method to support filtering
  static Future<Map<String, dynamic>> getCompletionStats(
    String range, {
    String? habitType,
    String? habitId,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      // Build URL with query parameters
      String url = "$baseurl/api/task_completion_stats/?range=$range";

      if (habitType != null) {
        url += "&habit_type=$habitType";
      }
      if (habitId != null) {
        url += "&habit_id=$habitId";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'stats': data['stats'],
          'labels': data['labels'],
          'taskCounts': data['taskCounts'],
        };
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching completion stats: $e");
      throw Exception('Failed to load completion stats');
    }
  }

  ////////////////////////////////////////coins related ///////////////////////
  // Add these methods to your AIService class

  static Future<int> getCoinBalance() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final response = await http.get(
        Uri.parse('$baseurl/api/coins/balance/'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['balance'];
      }
      throw Exception('Failed to get coin balance');
    } catch (e) {
      print('Error getting coins: $e');
      throw Exception('Failed to load coin balance');
    }
  }

  static Future<int> addCoins(
    int amount,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final response = await http.post(
        Uri.parse('$baseurl/api/coins/add/'),
        headers: _headers(token),
        body: json.encode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['new_balance'];
      }
      throw Exception('Failed to add coins');
    } catch (e) {
      //print('Error adding coins: $e');
      throw Exception('Failed to add coins');
    }
  }

  // static Future<int> deductCoins(
  //   int amount, {
  //   String reason = 'purchase',
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseurl/api/coins/deduct/'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer YOUR_AUTH_TOKEN',
  //       },
  //       body: json.encode({'amount': amount, 'reason': reason}),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       return data['new_balance'];
  //     }
  //     throw Exception('Failed to deduct coins');
  //   } catch (e) {
  //     print('Error deducting coins: $e');
  //     throw Exception('Failed to deduct coins');
  //   }
  // }

  ////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////
  // static Future<Map<String, dynamic>> registerUser({
  //   required String username,
  //   required String email,
  //   required String password,
  // }) async {
  //   final url = Uri.parse('$baseurl/api/register/');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({
  //       'username': username,
  //       'email': email,
  //       'password': password,
  //     }),
  //   );

  //   if (response.statusCode == 201) {
  //     return {'success': true, 'data': json.decode(response.body)};
  //   } else {
  //     final errorData = json.decode(response.body);
  //     return {
  //       'success': false,
  //       'error': errorData['error'] ?? 'Registration failed.',
  //     };
  //   }
  // }

  // static Future<Map<String, dynamic>> loginUser(
  //   String username,
  //   String password,
  // ) async {
  //   final url = Uri.parse('$baseurl/api/login/');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({'username': username, 'password': password}),
  //   );

  //   if (response.statusCode == 200) {
  //     return {'success': true, 'data': json.decode(response.body)};
  //   } else {
  //     final errorData = json.decode(response.body);
  //     return {'success': false, 'error': errorData['error'] ?? 'Login failed.'};
  //   }
  // }

  static Future<int> deductCoins(int amount) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    try {
      final response = await http.post(
        Uri.parse('$baseurl/api/coins/deduct/'),
        headers: _headers(token),
        body: json.encode({
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['new_balance'];
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body)['error'];
        throw Exception(error);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      }
      throw Exception('Failed to deduct coins');
    } catch (e) {
      print('Error deducting coins: $e');
      throw Exception('Failed to deduct coins: ${e.toString()}');
    }
  }

  Future<void> deleteHabit(String habitId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.delete(
        Uri.parse("$baseurl/api/habits/delete/$habitId/"),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Habit not found');
      } else {
        // Try to parse error message from response
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to delete habit');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete habit: ${e.toString()}');
    }
  }

  // Update reminder settings in backend
  static Future<bool> updateReminderSettings({
    required String habitId,
    required bool wantsReminder,
    String? reminderTime,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.post(
        Uri.parse('$baseurl/api/update_reminder_settings/'),
        headers: _headers(token),
        body: json.encode({
          'habit_id': habitId,
          'wants_reminder': wantsReminder,
          'reminder_time': reminderTime,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update reminder settings: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating reminder settings: $e');
      return false;
    }
  }
}

//***********************************************************************************************************//
