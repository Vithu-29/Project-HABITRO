import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ArticleService {
  static final String baseUrl = dotenv.get('BASE_URL');
  static final _storage = FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'authToken');
    if (token == null) throw Exception('Authentication required');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception('Session expired. Please re-login');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body)['error'] ??
          'Request failed (${response.statusCode})';
      throw Exception(error);
    }
  }

  Future<List<dynamic>> getArticles({String? category, String? search}) async {
    try {
      final uri = Uri.parse('$baseUrl/article/').replace(
        queryParameters: {
          if (category != null && category != 'All') 'category': category,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      return _handleResponse(response) as List;
    } catch (e) {
      throw Exception('Article fetch failed: $e');
    }
  }

  Future<Map<String, dynamic>> getArticleDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/article/$id/'),
        headers: await _getHeaders(),
      );

      return _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Article details fetch failed: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/article/categories/'),
        headers: await _getHeaders(),
      );
      final data = _handleResponse(response);
      return (data as List).map((e) => e.toString()).toList();
    } catch (e) {
      throw Exception('Category fetch failed: $e');
    }
  }
}
