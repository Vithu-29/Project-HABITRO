import 'dart:convert';
import 'package:http/http.dart' as http;

class ArticleService {
  static const String baseUrl = 'http://192.168.8.100:8000/api/articles/';

  Future<List<dynamic>> getArticles({String? category, String? search}) async {
    try {
      final Uri uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          if (category != null && category != 'All') 'category': category,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      }
      throw Exception('Failed to load articles');
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }

  Future<Map<String, dynamic>> getArticleDetails(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$id/'));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to load article details');
    } catch (e) {
      throw Exception('Error fetching article: $e');
    }
  }
}