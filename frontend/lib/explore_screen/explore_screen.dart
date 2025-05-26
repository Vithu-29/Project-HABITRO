import 'package:flutter/material.dart';
import 'package:frontend/api_services/article_service.dart';
import 'package:frontend/components/standard_app_bar.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(appBarTitle: "Explore"),
      body: const ExplorePage(),
    );
  }
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  ExplorePageState createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  final ArticleService _articleService = ArticleService();
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'All';
  List<dynamic> articles = [];
  bool isLoading = true;

  final List<String> categories = [
    'All',
    'Personal Development',
    'Productivity',
    'Technology',
    'Health and Fitness',
    'Mental Well-Being',
  ];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      final data = await _articleService.getArticles(
        category: selectedCategory,
        search: _searchController.text,
      );
      setState(() {
        articles = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => isLoading = false);
    }
  }

  void _navigateToArticleDetail(int articleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(articleId: articleId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 16),
              Expanded(child: _buildArticleList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      ),
      onChanged: (value) => _loadArticles(),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selectedCategory == category,
              onSelected: (selected) => setState(() {
                selectedCategory = selected ? category : 'All';
                _loadArticles();
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticleList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (articles.isEmpty) return const Center(child: Text('No articles found'));

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return InkWell(
          onTap: () => _navigateToArticleDetail(article['id']),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (article['image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        article['image'],
                        width: 100,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(article['category'] ?? '',
                            style: TextStyle(color: Colors.grey[600])),
                        Text(article['title'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${article['date']} • ${article['views']} views',
                            style: TextStyle(color: Colors.grey[600])),
                      ]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

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
      debugPrint(e.toString());
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article?['image'] != null)
                      Image.network(article!['image']),
                    const SizedBox(height: 16),
                    Text(article?['title'] ?? '',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('${article?['date']} • ${article?['views']} views'),
                    const SizedBox(height: 16),
                    Text(article?['content'] ?? ''),
                  ],
                ),
              ),
            ),
    );
  }
}