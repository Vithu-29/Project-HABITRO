import 'package:flutter/material.dart';
import 'package:frontend/api_services/article_service.dart';
import 'package:frontend/components/article_shimmer.dart';
import 'package:frontend/components/standard_app_bar.dart';
import 'package:frontend/explore_screen/article_detail_screen.dart';
import 'package:frontend/theme.dart';

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
  List<String> categories = ['All'];
  bool isLoading = true;
  bool isCategoryLoading = true;

  static List<dynamic>? cachedArticles;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadArticles();
  }

  Future<void> _loadCategories() async {
    try {
      final backendCategories = await _articleService.getCategories();
      setState(() {
        categories = ['All', ...backendCategories];
        isCategoryLoading = false;
      });
    } catch (e) {
      debugPrint("Category fetch error: $e");
      setState(() => isCategoryLoading = false);
    }
  }

  Future<void> _loadArticles({bool forceReload = false}) async {
    if (!forceReload &&
        cachedArticles != null &&
        selectedCategory == 'All' &&
        _searchController.text.isEmpty) {
      setState(() {
        articles = cachedArticles!;
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = await _articleService.getArticles(
        category: selectedCategory,
        search: _searchController.text,
      );
      setState(() {
        articles = data;
        if (selectedCategory == 'All' && _searchController.text.isEmpty) {
          cachedArticles = data;
        }
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
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
            );
          },
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
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 0.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 0.1),
        ),
      ),
      onChanged: (value) => _loadArticles(forceReload: true),
    );
  }

  Widget _buildCategoryChips() {
    if (isCategoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return ChoiceChip(
            label: Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            selected: isSelected,
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor: const Color(0xFFD9D9D9),
            checkmarkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() => selectedCategory = category);
                _loadArticles(forceReload: true);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildArticleList() {
    if (isLoading) {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => const ArticleShimmerCard(),
      );
    }

    if (articles.isEmpty) {
      return const Center(child: Text('No articles found'));
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return InkWell(
          onTap: () => _navigateToArticleDetail(article['id']),
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                          article['category'] ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.greyText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article['title'],
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold,color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${article?['date']}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.greyText),
                            ),
                            const Spacer(),
                            Text(
                              '${article?['views']} views',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.greyText),
                            ),
                          ],
                        ),
                      ],
                    ),
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
