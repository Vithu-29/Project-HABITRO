import 'package:flutter/material.dart';
import 'package:frontend/api_services/article_service.dart';
import 'package:frontend/components/standard_app_bar.dart';
import 'package:frontend/theme.dart';

class ArticleDetailScreen extends StatefulWidget {
  final int articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ArticleService _articleService = ArticleService();
  Map<String, dynamic>? article;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticleDetails();
  }

  Future<void> _loadArticleDetails() async {
    try {
      final data = await _articleService.getArticleDetails(widget.articleId);
      setState(() {
        article = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading article: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        appBarTitle: "Article",
        showBackButton: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article?['image'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(article!['image']),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('${article?['date']}',
                              style: TextStyle(color: AppColors.greyText)),
                          const Spacer(),
                          Text('${article?['views']} views',
                              style: TextStyle(color: AppColors.greyText)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article?['title'] ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        article?['content'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
