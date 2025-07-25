import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FriendChatService {
  static final String baseUrl = dotenv.get('BASE_URL');
  static final _storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'authToken');
  }

  static Future<int?> getCurrentUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');
  debugPrint('Read userId from shared preferences: $userId');
  return userId;
}

  static Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  static Future<List<dynamic>> getFriends() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/profile/list-friends/'),
      headers: _headers(token!),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> searchUser(String query) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/profile/search-user/'),
      headers: _headers(token!),
      body: jsonEncode({'query': query}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> addFriend(String friendId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/profile/add-friend/'),
      headers: _headers(token!),
      body: jsonEncode({'friend_id': friendId}),
    );
    return _handleResponse(response);
  }

  static Future<List<Map<String, dynamic>>> fetchMessages(String roomId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/profile/fetch-messages/'),
      headers: _headers(token!),
      body: jsonEncode({'room_id': roomId}),
    );
    final data = _handleResponse(response);
    final List<dynamic> messagesJson = data['messages'] as List<dynamic>;
    return messagesJson.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<Map<String, dynamic>> getOrCreateRoom(String friendId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/profile/get-or-create-room/'),
      headers: _headers(token!),
      body: jsonEncode({'friend_id': friendId}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> deleteMessage(int messageId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/profile/delete-messages/'),
      headers: _headers(token!),
      body: jsonEncode({'message_id': messageId}),
    );
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception('Session expired. Please re-login');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      try {
        final body = jsonDecode(response.body);
        final error =
            body['error'] ?? body['message'] ?? 'Unknown error occurred';
        throw Exception(error);
      } catch (_) {
        throw Exception('Unexpected response: ${response.body}');
      }
    }
  }
}
