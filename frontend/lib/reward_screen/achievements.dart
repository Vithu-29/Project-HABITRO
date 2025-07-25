// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frontend/api_services/achievement_service.dart';
import 'package:frontend/reward_screen/achievements_page.dart';

class Achievements extends StatefulWidget {
  final VoidCallback? onRefresh;
  final bool showViewAll;
  const Achievements({super.key, this.onRefresh, this.showViewAll = true});

  @override
  State<Achievements> createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  List achievements = [];

  @override
  void initState() {
    super.initState();
    _fetchAchievements();
  }

  Future<void> _fetchAchievements() async {
    try {
      final data = await AchievementService.fetchUnlocked();
      setState(() => achievements = data);
    } catch (e) {
      debugPrint("Error fetching achievements: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasUnclaimed = achievements
        .any((a) => a['unlocked'] == true && a['is_collected'] == false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              if (widget.showViewAll)
                Stack(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AchievementsPage(
                              onAchievementClaimed: () {
                                _fetchAchievements();
                                if (widget.onRefresh != null) {
                                  widget.onRefresh!();
                                }
                              },
                            ),
                          ),
                        );
                        await _fetchAchievements();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    if (hasUnclaimed)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100, // Fixed height
          child: achievements.isEmpty
              ? const Center(child: Text("No achievements unlocked yet."))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 25),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    var userAchievement = achievements[index];
                    return AchievementCard(
                      title: userAchievement['achievement']['title'] ??
                          'No Title', // Handle null case
                      imageUrl: userAchievement['achievement']['image'],
                      unlocked: userAchievement['unlocked'] ?? false,
                      isCollected: userAchievement['is_collected'] ?? false,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// Achievement Card Widget
class AchievementCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool unlocked;
  final bool isCollected;

  const AchievementCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.unlocked,
    required this.isCollected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFFF),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                )
              : const Icon(Icons.image_not_supported, size: 40),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFAFC1E7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
