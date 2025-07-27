// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChallengeService {
  // Update this URL to match your backend server
  static const String baseUrl = 'http://192.168.8.102:8000';

  // Get authentication token from storage
  static Future<String?> _getAuthToken() async {
    try {
      // First try using FlutterSecureStorage (more secure)
      final storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'authToken');

      if (token != null && token.isNotEmpty) {
        print("Token found in secure storage");

        // Also save to SharedPreferences for redundancy
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getString('authToken') != token) {
          await prefs.setString('authToken', token);
        }

        return token;
      }

      // If not found in secure storage, try SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('authToken');

      if (token != null && token.isNotEmpty) {
        print("Token found in SharedPreferences");

        // Also save it to secure storage for next time
        await storage.write(key: 'authToken', value: token);
        return token;
      }

      // If we still don't have a token but the user is marked as signed in,
      // we need to handle this inconsistency
      bool isSignedIn = prefs.getBool('is_signed_in') ?? false;
      if (isSignedIn) {
        print(
            "User marked as signed in but no token found - inconsistent state");
        // Consider forcing re-authentication here
      }

      print("No authentication token found in any storage");
      return null;
    } catch (e) {
      print("Error retrieving auth token: $e");
      return null;
    }
  }

  // Create headers with authentication token
  static Map<String, String> _createHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  // Get available challenges for the user to join
  static Future<List<dynamic>> getAvailableChallenges() async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/challenges/'),
        headers: _createHeaders(token),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load challenges: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading challenges: $e');
    }
  }

  // Get challenges that the user has joined
  static Future<List<dynamic>> getUserChallenges() async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user-challenges/'),
        headers: _createHeaders(token),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load user challenges: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading user challenges: $e');
    }
  }

  // Join a challenge with selected habits
  static Future<bool> joinChallenge(int challengeId, List<int> habitIds) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/join-challenge/'),
        headers: _createHeaders(token),
        body: json.encode({
          'challenge_id': challengeId,
          'habit_ids': habitIds,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error joining challenge: $e');
    }
  }

  // Update habit completion status
  static Future<bool> updateHabitStatus(int habitId, bool isCompleted) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/update-habit-status/$habitId/'),
        headers: _createHeaders(token),
        body: json.encode({
          'is_completed': isCompleted,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating habit status: $e');
    }
  }
}
